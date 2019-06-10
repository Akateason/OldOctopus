 //
//  MarkdownVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
// 假导航

#import "MarkdownVC.h"
#import "OctWebEditor.h"
#import <XTlib/XTPhotoAlbum.h>
#import "AppDelegate.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
#import "ArticleInfoVC.h"
#import "OutputPreviewVC.h"
#import "OutputPreviewsNailView.h"
#import "UIViewController+CWLateralSlide.h"



@interface MarkdownVC ()
@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet UIView *navArea;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBar;

@property (strong, nonatomic) OctWebEditor      *editor ;
@property (strong, nonatomic) XTCameraHandler   *handler;
@property (strong, nonatomic) ArticleInfoVC     *infoVC ;

@property (strong, nonatomic) Note              *aNote ;
@property (copy, nonatomic)   NSString          *myBookID ;

@property (nonatomic) BOOL thisArticleHasChanged ;
@end

@implementation MarkdownVC

#pragma mark - Life

+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
                fromCtrller:(UIViewController *)ctrller {
    
    MarkdownVC *vc = [MarkdownVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"MarddownVC"] ;
    vc.aNote = note ;
    vc.delegate = ctrller ;
    vc.myBookID = bookID ;
    [ctrller.navigationController pushViewController:vc animated:YES] ;
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    if (self.aNote) {
        self.editor.aNote = self.aNote ;
    }

    @weakify(self)
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_CHANGE object:nil] takeUntil:self.rac_willDeallocSignal] throttle:.6] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        // Update Your Note
        [self updateMyNote] ;
        if (!self.thisArticleHasChanged) self.thisArticleHasChanged = YES ;
    }] ;

    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationSyncCompleteAllPageRefresh object:nil] takeUntil:self.rac_willDeallocSignal] throttle:3] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        // Sync your note
        if (!self.aNote) return ;
        
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
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated] ;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
    
    if (self.aNote) {
        // Update Your Note
        if (self.thisArticleHasChanged) [self updateMyNote] ;
    }
    else {
        // Create New Note
        [self createNewNote] ;
    }
}

#pragma mark - Func

- (void)createNewNote {
    @weakify(self)
    [self.editor getMarkdown:^(NSString *markdown) {
        @strongify(self)
        NSString *articleContent = markdown ;
        NSArray *listForBreak = [markdown componentsSeparatedByString:@"\n"] ;
        NSString *title = @"无标题" ;
        for (NSString *str in listForBreak) {
            if (str.length) {
                title = str ;
                break ;
            }
        }
        
        if (articleContent && articleContent.length) {
            Note *newNote = [[Note alloc] initWithBookID:self.myBookID content:articleContent title:title] ;
            self.aNote = newNote ;
            [Note createNewNote:self.aNote] ;
            [self.delegate addNoteComplete:self.aNote] ;
        }
    }] ;
    
}

- (void)updateMyNote {
    if (!self.aNote) return ;
    
    @weakify(self)
    [self.editor getMarkdown:^(NSString *markdown) {
        @strongify(self)
        NSArray *listForBreak = [markdown componentsSeparatedByString:@"\n"] ;
        NSString *title = @"无标题" ;
        for (NSString *str in listForBreak) {
            if (str.length) {
                title = str ;
                break ;
            }
        }
        
        self.aNote.content = markdown ;
        self.aNote.title = title ;
        [Note updateMyNote:self.aNote] ;
        [self.delegate editNoteComplete:self.aNote] ;
    }] ;
    
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
    [self.btBack xt_enlargeButtonsTouchArea] ;
    [self.btMore xt_enlargeButtonsTouchArea] ;
    
    self.navArea.backgroundColor = nil ;
    
    self.topBar.backgroundColor = nil ;

    [self.topBar setNeedsDisplay] ;
    [self.topBar layoutIfNeeded] ;
    [self.topBar oct_addBlurBg] ;
    
    [self registGesture] ;
}

- (void)registGesture {
    __weak typeof(self)weakSelf = self;
    [self cw_registerShowIntractiveWithEdgeGesture:NO transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        if (direction == CWDrawerTransitionFromRight) { // 右侧滑出
            [weakSelf moreAction:nil];
        }
    }];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES] ;
}

- (IBAction)moreAction:(id)sender {
    [self.editor nativeCallJSWithFunc:@"hideKeyboard" json:nil completion:^(BOOL isComplete) {
    }] ;

    [self infoVC] ;
    
    self.infoVC.aNote = self.aNote ;
    self.infoVC.webInfo = self.editor.webInfo ;
    WEAK_SELF
    self.infoVC.blkDelete = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES] ;
    } ;
    
    // 预览
//    self.infoVC.blkOutput = ^{
//        if (weakSelf.textView.isFirstResponder) {
//            [weakSelf.textView resignFirstResponder] ;
//            [weakSelf.textView parseAllTextFinishedThenRenderLeftSideAndToolbar] ;
//            //@issue 预览之前, 把 所有, 左边展示的 mark 去掉 .
//        }
//       dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf snapShotFullScreen] ;
//        }) ;
//    } ;
    
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:[ArticleInfoVC movingDistance] maskAlpha:0.4 scaleY:1 direction:CWDrawerTransitionFromRight backImage:nil] ;
    [self cw_showDrawerViewController:self.infoVC animationType:0 configuration:conf] ;
}


//- (void)snapShotFullScreen {
//    self.navArea.hidden = YES ;
//
//    CGFloat flexTop = APP_STATUSBAR_HEIGHT + 55 ;
//    CGFloat textHeight = self.textView.contentSize.height + flexTop ;
//
//    OutputPreviewsNailView *nail = [OutputPreviewsNailView makeANail] ;
//    nail.top = textHeight ;
//    [self.view addSubview:nail] ;
//
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(APP_WIDTH, textHeight + nail.height), YES, [UIScreen mainScreen].scale) ;
//
//    CGPoint savedContentOffset = self.textView.contentOffset;
//    CGRect savedFrame = self.textView.frame;
//
//    self.textView.mj_offsetY = - 55 ;
//    self.textView.frame = CGRectMake(30, 0, self.textView.contentSize.width , self.textView.contentSize.height) ;
//    self.view.frame = CGRectMake(0, 0, APP_WIDTH , textHeight + nail.height) ;
//
//    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()] ;
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
//    UIGraphicsEndImageContext() ;
//
//    self.navArea.hidden = NO ;
//    self.textView.contentOffset = savedContentOffset;
//    self.textView.frame = savedFrame;
//    self.view.frame = APPFRAME ;
//    [nail removeFromSuperview] ;
//    nail = nil ;
//
//    if (!image) return ;
//
//    [self dismissViewControllerAnimated:YES completion:nil] ;
//    [OutputPreviewVC showFromCtrller:self imageOutput:image] ;
//}

#pragma mark - prop

- (OctWebEditor *)editor {
    if (!_editor) {
        _editor = [[OctWebEditor alloc] init] ;
        [self.view insertSubview:_editor atIndex:0] ;
        [_editor mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            } else {
                make.top.equalTo(self.view.xt_viewController.mas_topLayoutGuideBottom) ;
            }
            make.bottom.left.right.equalTo(self.view) ;
        }] ;
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

@end
