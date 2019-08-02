 //
//  MarkdownVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
// 假导航

#import "MarkdownVC.h"
#import <XTlib/XTPhotoAlbum.h>
#import "AppDelegate.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
#import "ArticleInfoVC.h"
#import "OutputPreviewVC.h"
#import "OutputPreviewsNailView.h"
#import "OctWebEditor+OctToolbarUtil.h"
#import <WebKit/WebKit.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "GlobalDisplaySt.h"
#import "HomePadVC.h"
#import "NHSlidingController.h"
#import "HomeVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "OctRequestUtil.h"
#import "OctShareCopyLinkView.h"
#import "OctMBPHud.h"
#import "HomeTrashEmptyPHView.h"
#import "SearchVC.h"
#import "MDEKeyboardPhotoView.h"

@interface MarkdownVC () <WKScriptMessageHandler>
@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet UIView *navArea;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBar;
@property (weak, nonatomic) IBOutlet UIButton *btShare;


@property (strong, nonatomic) XTCameraHandler   *cameraHandler ;
@property (strong, nonatomic) ArticleInfoVC     *infoVC ;

@property (strong, nonatomic) Note              *aNote ;
@property (copy, nonatomic)   NSString          *myBookID ;
@property (strong, nonatomic) WKWebView         *webView ;
@property (strong, nonatomic) UIView            *snapBgView ;
@property (strong, nonatomic) OutputPreviewsNailView *nail ;
@property (nonatomic)         float             snapDuration ;

@property (nonatomic)         BOOL              isInTrash ;
@property (nonatomic)         BOOL              isInShare ;
@property (nonatomic)         BOOL              isNewFromIpad ;

@property (strong, nonatomic) RACSubject        *outputPhotoSubject ;
@property (nonatomic)         BOOL              isSnapshoting ;
@end

@implementation MarkdownVC

+ (CGFloat)getEditorLeftIpad {
    return - [GlobalDisplaySt sharedInstance].containerSize.width / 4. + 65. ;
}

#pragma mark - Life
// 当 bookID == nil 时, 笔记在暂存区创建
//
+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
                fromCtrller:(UIViewController *)ctrller {
    
    return  [self newWithNote:note
                       bookID:bookID
          isCreateNewFromIpad:NO
                  fromCtrller:ctrller] ;
}

+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
        isCreateNewFromIpad:(BOOL)newFromIpad
                fromCtrller:(UIViewController *)ctrller {
    
    MarkdownVC *vc = [MarkdownVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"MarkdownVC"] ;
    vc.aNote = note ;
    vc.isNewFromIpad = newFromIpad ;
    if (newFromIpad) {
        vc.editor.aNote = note ;
        vc.editor.left = [self.class getEditorLeftIpad] ;
        vc.canBeEdited = NO ;
    }
    else {
        if (note) {
            vc.editor.aNote = note ;
        }
        else {
            vc.editor.aNote = [[Note alloc] initWithBookID:nil content:nil title:nil] ;
        }
        vc.canBeEdited = YES ;
    }
    vc.delegate = (id <MarkdownVCDelegate>)ctrller ;
    vc.myBookID = bookID ;
    [vc.editor.toolBar reset] ;
    if ([GlobalDisplaySt sharedInstance].displayMode != GDST_Home_3_Column_Horizon) {
        [ctrller.navigationController pushViewController:vc animated:YES] ;
    }
    return vc ;
}

- (void)setupWithNote:(Note *)note
               bookID:(NSString *)bookID
          fromCtrller:(UIViewController *)ctrller {
    
    self.aNote = note ;
    if (ctrller != nil) self.delegate = (id <MarkdownVCDelegate>)ctrller ;
    self.myBookID = bookID ;
    self.emptyView.hidden = note != nil ;
    self.isNewFromIpad = (note == nil) ? 1 : 0 ;
    self.editor.aNote = note ?: [Note new] ;
    self.editor.left = [self.class getEditorLeftIpad] ;
    self.canBeEdited = [GlobalDisplaySt sharedInstance].gdst_level_for_horizon == -1 ;
    [self.editor.toolBar reset] ;
}

- (void)setupWithNote:(Note *)note
               bookID:(NSString *)bookID {
    [self setupWithNote:note bookID:bookID fromCtrller:nil] ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.view.xt_maskToBounds = YES ;
    
    @weakify(self)
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_CHANGE object:nil] takeUntil:self.rac_willDeallocSignal] throttle:.6] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon && [GlobalDisplaySt sharedInstance].gdst_level_for_horizon != -1) return ;
        
        // Update Your Note
        [self updateMyNote] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_User_Open_Camera object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        @weakify(self)
        [self.cameraHandler openCameraFromController:self takePhoto:^(UIImage *imageResult) {
            if (!imageResult) return;
            
            @strongify(self)
            [self.editor sendImageLocalPathWithImage:imageResult] ;
        }] ;
    }] ;
    
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationSyncCompleteAllPageRefresh object:nil] takeUntil:self.rac_willDeallocSignal] throttle:3] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        // Sync your note
        if (!self.aNote || self.aNote.content.length <= 1 ) return ;
        
        NSLog(@"Sync your note") ;
        
        __block Note *noteFromIcloud = [Note xt_findFirstWhere: XT_STR_FORMAT(@"icRecordName == '%@'",self.aNote.icRecordName)] ;
        if ([noteFromIcloud.content isEqualToString:self.aNote.content]) return ; // 如果内容一样,不处理
        
        self.aNote = noteFromIcloud ;
        self.editor.aNote = noteFromIcloud ;
        [self.editor renderNote] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         self.editor.themeStr = [MDThemeConfiguration sharedInstance].currentThemeKey ;
         [self.editor changeTheme] ;
     }] ;
    
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_Make_Big_Photo object:nil] throttle:.5] deliverOnMainThread] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        NSString *json = x.object ;
        [self snapShotFullScreen:json] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNoteSlidingSizeChanging object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return ;
        
        [self.editor setSideFlex] ;
        
        self.editor.bottom = self.view.bottom ;
        self.editor.top = APP_STATUSBAR_HEIGHT ;
        self.editor.width = [GlobalDisplaySt sharedInstance].containerSize.width ;
        self.editor.height = [GlobalDisplaySt sharedInstance].containerSize.height - APP_STATUSBAR_HEIGHT ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_book_Changed object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return ;
        
        NoteBooks *book = x.object ;
        if (
            ![self.aNote.noteBookId isEqualToString:book.icRecordName]
            &&
            [GlobalDisplaySt sharedInstance].gdst_level_for_horizon != -1
            && !self.isNewFromIpad
            ) {
            [self clearArticleInIpad] ;
        }
        
        self.emptyView.isTrash = (book.vType == Notebook_Type_trash) ;
        self.isInTrash = (book.vType == Notebook_Type_trash) ;
        self.btBack.hidden = (book.vType == Notebook_Type_trash) ;
        
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_SearchVC_On_Window object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        // 搜索开启时, 右边和垃圾桶一样处理 .        
        bool isOn = [x.object boolValue] ;
        self.emptyView.isTrash = isOn ;
        self.isInTrash = isOn ;
        self.btBack.hidden = isOn ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_Send_Share_Html object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        self.isInShare = YES ;
        [[OctMBPHud sharedInstance] hide] ;
        
        @weakify(self)
        NSString *html = x.object ;
        [OctRequestUtil getShareHtmlLink:html complete:^(NSString * _Nonnull urlString) {
            @strongify(self)
            if (urlString) {
                NSLog(@"getShareHtmlLink : %@", urlString) ;
                [self.editor hideKeyboard] ;
                
                @weakify(self)
                [OctShareCopyLinkView showOnView:self.view
                                            link:urlString
                                        complete:^(BOOL ok) {
                    @strongify(self)
                    self.isInShare = NO ;
                    if (ok) {
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                        pasteboard.string = urlString ;
                        [SVProgressHUD showSuccessWithStatus:@"分享链接已经复制到剪贴板"] ;
                    }
                }] ;
            }
        }] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Delete_Note_In_Pad object:nil] deliverOnMainThread] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self clearArticleInIpad] ;
    }] ;
    
    [[[[RACObserve([GlobalDisplaySt sharedInstance], gdst_level_for_horizon)
       deliverOnMainThread]
       takeUntil:self.rac_willDeallocSignal]
      throttle:.3]
     subscribeNext:^(id  _Nullable x) {
         @strongify(self)
         int num = [x intValue] ;
         if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return ;
         
         self.canBeEdited = num == -1 ;
         [UIView animateWithDuration:.1 animations:^{
             if (num == -1) self.btBack.transform = CGAffineTransformScale(self.btBack.transform, -1, 1) ;
             else self.btBack.transform = CGAffineTransformIdentity ;
         }] ;
         
         if (self.aNote == nil || self.editor.aNote == nil || self.editor.aNote.content.length < 1) {
             if (num == -1) {
                 [self setupWithNote:nil bookID:self.delegate.currentBookID] ;
                 
                 [UIView animateWithDuration:.1 animations:^{
                     [self moveRelativeViewsOnState:YES] ;
                 } completion:^(BOOL finished) {
                     
                 }] ;
                 
                 self.emptyView.hidden = YES ;
                 self.editor.webViewHasSetMarkdown = YES ;
             }
             else {
                 self.emptyView.hidden = NO ;
             }
         }
         
         if (num != -1) {
             [self.editor hideKeyboard] ;
         }
        
     }] ;
    
    [[[self.outputPhotoSubject throttle:.4] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        
        if (!self.isSnapshoting) return ;
//        NSLog(@"wwwww : %@", x) ;
        
        float textHeight = [x floatValue] ;
        if ( textHeight < APP_HEIGHT) textHeight += 100. ;

        self.snapDuration = .4 + (float)textHeight / (float)APP_HEIGHT * .35 ;
        
        CGSize snapSize = CGSizeMake(APP_WIDTH, textHeight) ;
        self.snapBgView.frame = CGRectMake(0, 0, APP_WIDTH , textHeight) ;
        [self.snapBgView setNeedsLayout] ;
        [self.snapBgView layoutIfNeeded] ;
        self.webView.height = textHeight ;
        [self.webView setNeedsLayout] ;
        [self.webView layoutIfNeeded] ;
        

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.snapDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            UIGraphicsBeginImageContextWithOptions(snapSize, true,  [UIScreen mainScreen].scale) ;
            [self.snapBgView.layer renderInContext:UIGraphicsGetCurrentContext()] ;
            __block UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
            UIGraphicsEndImageContext() ;

            dispatch_async(dispatch_get_main_queue(), ^{
                self.webView.hidden = YES ;
                [self.webView removeFromSuperview] ;
                self->_webView = nil ;

                UIImageView *imageView = [[UIImageView alloc] initWithImage:image] ;
                [self.snapBgView addSubview:imageView] ;
                imageView.height = textHeight ;

                self.nail = [OutputPreviewsNailView makeANail] ;
                self.nail.top = textHeight ;
                [self.snapBgView addSubview:self.nail] ;
                self.snapBgView.frame = CGRectMake(0, 0, APP_WIDTH , textHeight + self.nail.height) ;
                image = [UIImage getImageFromView:self.snapBgView] ;


                [self.nail removeFromSuperview] ;
                self.nail = nil ;
                [imageView removeFromSuperview] ;
                imageView = nil ;
                [self.snapBgView removeFromSuperview] ;
                self.snapBgView = nil ;

                self.editor.hidden = NO ;
                self.navArea.hidden = NO ;
                
                [[OctMBPHud sharedInstance] hide] ;
                
                if (!image) return ;
                [OutputPreviewVC showFromCtrller:self imageOutput:image] ;
                
            }) ;
        }) ;
    }] ;
    
    
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) {
        id target = self.navigationController.interactivePopGestureRecognizer.delegate ;
        // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
        pan.delegate = (id<UIGestureRecognizerDelegate>)self;
        [self.view addGestureRecognizer:pan];
        // 禁止使用系统自带的滑动手势
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    else { // ipad大
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        pan.delegate = (id<UIGestureRecognizerDelegate>)self;
        [self.view addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)] ;
        [self.view addGestureRecognizer:tap] ;
    }
}

- (void)tapped:(UIGestureRecognizer *)recog {
    if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon == -1) return ;
    if (self.isInTrash) return ;
    
    if (!self.emptyView.hidden) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNote_new_Note_In_Pad object:nil] ;
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNote_pad_Editor_OnClick object:nil] ;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return YES ;
    if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon != 1) return YES ;
    
    return [self.oct_panDelegate oct_gestureRecognizerShouldBegin:gestureRecognizer] ;
}

// 此方法返回YES时，手势事件会一直往下传递，不论当前层次是否对该事件进行响应
- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}



- (void)panned:(UIPanGestureRecognizer *)recognizer {
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return ;
    if (self.isInShare) return ;
    
//    CGPoint offset = [recognizer translationInView:self.view] ;
//    NSLog(@"offset : %@", NSStringFromCGPoint(offset)) ;
    CGFloat velocity = [recognizer velocityInView:self.view].x ;
    
    if (self.isInTrash && velocity < 0 && [GlobalDisplaySt sharedInstance].gdst_level_for_horizon == 0) return ; // 垃圾桶 不能新建
//    NSLog(@"dddd : %d",[GlobalDisplaySt sharedInstance].gdst_level_for_horizon) ;
    
    switch ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon) {
        // 里层
        case -1: [self.pad_panDelegate pad_panned:recognizer] ; break;
        case 0: { // 中层
            if (velocity > 0) { //
                NSLog(@"👉") ;
                [self.oct_panDelegate oct_panned:recognizer] ; // 外层
            }
            else { //
                NSLog(@"👈") ;
                [self.pad_panDelegate pad_panned:recognizer] ; // 里层
            }
        } break;
        // 外层
        case  1: [self.oct_panDelegate oct_panned:recognizer] ; break;
        
        default: break;
    }
}

- (void)handleNavigationTransition:(id)ges {} // 调用系统自带滑动手势的target的action方法







- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
    
    if (self.isNewFromIpad && !self.isSnapshoting) {
        self.editor.left = [self.class getEditorLeftIpad] ;
        // self.canBeEdited = NO ; 在webview第一次初始化之后,设置才有用.
    }
    
    if (self.isSnapshoting) {
        self.isSnapshoting = NO ;
        self.editor.left = 0 ;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
    
    [self leaveOut] ;
}

#define XT_HIDE_HUD        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
[[OctMBPHud sharedInstance] hide] ;\
});\

#define XT_HIDE_HUD_RETURN  {dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
[[OctMBPHud sharedInstance] hide] ;\
});\
return;}

- (void)leaveOut {
    [self.editor.toolBar reset] ;
    self.editor.toolBar = nil ;
    
    if ([GlobalDisplaySt sharedInstance].isInNewBookVC) {
        return ;
    }
    
    if (!self.editor.webViewHasSetMarkdown) {
        [self.editor leavePage] ;
        XT_HIDE_HUD
        return ;
    }
    
    [[OctMBPHud sharedInstance] show] ;
    
    @weakify(self)
    [self.editor getMarkdown:^(NSString *markdown) {
        @strongify(self)
        self.editor.aNote.content = markdown ;
        
        if (self.editor.articleAreTheSame) {
            [self.editor leavePage] ;
            XT_HIDE_HUD
            return ;
        }
        
        if (self.aNote) {
            // Update Your Note
            [self updateMyNote] ;
        }
        else {
            // Create New Note
            [self createNewNote] ;
        }
        
        [self.editor leavePage] ;
    }] ;
}






#pragma mark - Func

- (void)createNewNote {
    NSString *markdown = self.editor.aNote.content ;
    NSString *title = [Note getTitleWithContent:markdown] ;
    if (markdown && markdown.length) {
        Note *newNote = [[Note alloc] initWithBookID:self.myBookID content:markdown title:title] ;
        self.aNote = newNote ;
        [Note createNewNote:self.aNote] ;
        XT_USERDEFAULT_SET_VAL(newNote.icRecordName, kUDCached_lastNote_RecID) ;
        [self.delegate addNoteComplete:self.aNote] ;
        
    }
    XT_HIDE_HUD
}

- (void)updateMyNote {
    if (!self.aNote) XT_HIDE_HUD_RETURN
    if (!self.editor.webViewHasSetMarkdown) XT_HIDE_HUD_RETURN
    if (self.editor.articleAreTheSame) XT_HIDE_HUD_RETURN
    if (![self.editor.aNote.icRecordName isEqualToString:self.aNote.icRecordName]) XT_HIDE_HUD_RETURN
    
    NSString *markdown = self.editor.aNote.content ;
    NSString *title = [Note getTitleWithContent:markdown] ;
    
    self.aNote.content = markdown ;
    self.aNote.title = title ;
    [Note updateMyNote:self.aNote] ;
    [self.delegate editNoteComplete:self.aNote] ;
    XT_HIDE_HUD
}

- (void)clearArticleInIpad {
    self.emptyView.hidden = NO ;
    
    NSDictionary *dic = @{@"markdown":@"", @"isRenderCursor": @0 } ;
    [self.editor nativeCallJSWithFunc:@"setMarkdown" json:dic completion:^(NSString *val, NSError *error) {}] ;
    [self.editor leavePage] ;
    self.editor.aNote = nil ;
}


#pragma mark - UI

- (void)prepareUI {
    [self editor] ;
    
    self.editor.xt_theme_backgroundColor = k_md_bgColor ;
    self.editor.themeStr = [MDThemeConfiguration sharedInstance].currentThemeKey ;
    
    self.fd_prefersNavigationBarHidden = YES ;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heightForBar.constant = APP_STATUSBAR_HEIGHT + 55 ;        
    }) ;
    
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.btBack.xt_theme_imageColor = k_md_iconColor ;
    self.btMore.xt_theme_imageColor = k_md_iconColor ;
    self.btShare.xt_theme_imageColor = k_md_iconColor ;
    [self.btBack xt_enlargeButtonsTouchArea] ;
    [self.btMore xt_enlargeButtonsTouchArea] ;
    [self.btShare xt_enlargeButtonsTouchArea] ;
    
    self.navArea.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_bgColor, .8) ;
    self.topBar.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_bgColor, .8) ;
    
    if (IS_IPAD) {
        [self.btBack setImage:[UIImage imageNamed:@"nav_back_reverse_item"] forState:0] ;
    }
}

- (IBAction)backAction:(id)sender {
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon) {
        if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon != -1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNote_pad_Editor_OnClick object:nil] ;
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNote_pad_Editor_PullBack object:nil] ;
            [self leaveOut] ;
        }
        return ;
    }
    
    [self.navigationController popViewControllerAnimated:YES] ;
}

- (IBAction)moreAction:(id)sender {
    if (!self.canBeEdited) return ;
    
    [self.editor hideKeyboard] ;

    self.infoVC.view.alpha = 1 ;
    [self.view.window addSubview:self.infoVC.view] ;
    [self.infoVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view) ;
    }] ;
    
    self.infoVC.aNote = self.aNote ;
    self.infoVC.webInfo = self.editor.webInfo ;
    WEAK_SELF
    self.infoVC.blkDelete = ^{
        if (IS_IPAD) {
            [weakSelf clearArticleInIpad] ;
            [weakSelf backAction:nil] ;
        }
        else {
            [weakSelf.navigationController popViewControllerAnimated:YES] ;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ;
    } ;
    
    // 导出预览
    self.infoVC.blkOutput = ^{
        [weakSelf.editor hideKeyboard] ;
        [weakSelf.infoVC.view removeFromSuperview] ;
        
        [weakSelf.editor nativeCallJSWithFunc:@"getPureHtml" json:nil completion:^(NSString *val, NSError *error) {}] ;
    } ;
}

- (void)snapShotFullScreen:(NSString *)htmlString {
//    NSLog(@"sssssss") ;

    [self dismissViewControllerAnimated:YES completion:nil] ;
    
    [[OctMBPHud sharedInstance] show] ;
    
    self.editor.hidden = YES ;
    self.navArea.hidden = YES ;
    
    NSMutableString *tmpStr = [htmlString mutableCopy] ;
    htmlString = [tmpStr stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] ;
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"] ;
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""] ;
    
    NSString *path = XT_DOCUMENTS_PATH_TRAIL_(@"pic.html") ;
    [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil] ;
    NSURL *url = [NSURL fileURLWithPath:path] ;
    
    if (!self.snapBgView.superview) {
        self.snapBgView.frame = self.view.bounds ;
        [self.view addSubview:self.snapBgView] ;
    }
    
    if (!self.webView.superview) {
        [self.snapBgView addSubview:self.webView] ;
    }
    
    if (!self.isSnapshoting) {
        self.isSnapshoting = YES ;
        
        [self.webView loadFileURL:url allowingReadAccessToURL:url] ;
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *body = message.body ;       // 就是 JS 调用 Native 时，传过来的 value
    NSLog(@"%@", body) ;
    NSDictionary *ret = [WebModel convertjsonStringToJsonObj:body] ;
    NSString *func = ret[@"method"] ;
    NSDictionary *jsonDic = ret[@"params"] ;
    NSLog(@"WebViewBridge func : %@\njson : %@",func,jsonDic) ;
    
    if ([func isEqualToString:@"snapshotHeight"]) {
        float textHeight = [ret[@"params"] floatValue] ;
        [self.outputPhotoSubject sendNext:@(textHeight)] ;
//        [self.outputPhotoSubject sendCompleted] ;
//        NSLog(@"fffffff") ;
    }
}

- (IBAction)shareAction:(id)sender {
    [self.editor hideKeyboard] ;
    [[OctMBPHud sharedInstance] show] ;
    [self.editor getShareHtml] ;
}


#pragma mark - NHSlidingControllerAnimateDelegate <NSObject>

- (void)animateMoveState:(BOOL)drawerOpened {
    if (drawerOpened) {
        float newWid = ([GlobalDisplaySt sharedInstance].containerSize.width - kWidth_ListView - HomeVC.movingDistance) / 2. ;
        self.emptyView.centerX = newWid ;
    }
    else {
        float newWid = ([GlobalDisplaySt sharedInstance].containerSize.width - kWidth_ListView) / 2. ;
        self.emptyView.centerX = newWid ;
    }
}

#pragma mark - HomePadVCDelegate <NSObject>

- (void)moveRelativeViewsOnState:(bool)stateOn {

    // normal
    if (stateOn) {
        self.emptyView.centerX = self.view.centerX ;
        self.editor.left = 0 ;
    }
    else {
        float newWid = ([GlobalDisplaySt sharedInstance].containerSize.width - kWidth_ListView) / 2. ;
        self.emptyView.centerX = newWid ;
        
        self.editor.left = [MarkdownVC getEditorLeftIpad] ;
    }

}

#pragma mark - prop

- (void)setCanBeEdited:(BOOL)canBeEdited {
    _canBeEdited = canBeEdited ;
    
    [[OctWebEditor sharedInstance] setEditable:canBeEdited] ;
}

- (OctWebEditor *)editor {
    if (!_editor) {
        _editor = [OctWebEditor sharedInstance] ;
        _editor.bottom = self.view.bottom ;
        _editor.left = self.view.left ;
        _editor.top = APP_STATUSBAR_HEIGHT ;
        _editor.width = self.view.width ;
        _editor.height = self.view.height - APP_STATUSBAR_HEIGHT ;
        
        [self.view insertSubview:_editor atIndex:0] ;
    }
    return _editor ;
}

- (ArticleInfoVC *)infoVC{
    if(!_infoVC){
        _infoVC = ({
            ArticleInfoVC *infoVC = [ArticleInfoVC getCtrllerFromNIBWithBundle:[NSBundle bundleForClass:self.class]] ;
            infoVC;
       });
    }
    return _infoVC;
}

- (UIViewController *)fromCtrller {
    return self ;
}

- (HomeEmptyPHView *)emptyView {
    if (!_emptyView) {
        _emptyView = [HomeEmptyPHView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _emptyView.height = APP_HEIGHT - self.topBar.bottom ;
        _emptyView.left = self.view.left ;
        _emptyView.top = self.topBar.bottom ;
        _emptyView.width = [GlobalDisplaySt sharedInstance].containerSize.width - kWidth_ListView ;
        _emptyView.lbPh.textAlignment = NSTextAlignmentCenter ;
        [self.view addSubview:_emptyView] ;
        _emptyView.hidden = YES ;
    }
    _emptyView.height = APP_HEIGHT - self.topBar.bottom ;
    // _emptyView.left = self.view.left ;
    _emptyView.top = self.topBar.bottom ;
    _emptyView.width = [GlobalDisplaySt sharedInstance].containerSize.width - kWidth_ListView ;
    return _emptyView ;
}

- (XTCameraHandler *)cameraHandler {
    if (!_cameraHandler) {
        _cameraHandler = [[XTCameraHandler alloc] init] ;
    }
    return _cameraHandler ;
}


- (RACSubject *)outputPhotoSubject{
    if(!_outputPhotoSubject){
        _outputPhotoSubject = ({
            RACSubject * object = [[RACSubject alloc] init];
            object;
       });
    }
    return _outputPhotoSubject;
}

- (WKWebView *)webView{
    if(!_webView){
        _webView = ({
            WKWebViewConfiguration *config = [WKWebViewConfiguration new] ;
            [config.preferences setValue:@"TRUE" forKey:@"allowFileAccessFromFileURLs"] ;
            
            WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config] ;
            webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
            webView.backgroundColor = XT_GET_MD_THEME_COLOR_KEY(k_md_bgColor) ;
            webView.opaque = NO ;
            webView.hidden = NO ;
            [webView.configuration.userContentController addScriptMessageHandler:(id <WKScriptMessageHandler>)self name:@"WebViewBridge"] ;
            webView ;
       });
    }
    return _webView;
}

- (UIView *)snapBgView{
    if(!_snapBgView){
        _snapBgView = ({
            UIView *object = [[UIView alloc] init] ;
            object.frame = self.view.bounds ;
            object.backgroundColor = XT_GET_MD_THEME_COLOR_KEY(k_md_bgColor) ;
            object;
       });
    }
    return _snapBgView;
}
@end
