 //
//  MarkdownVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
// 假导航

#import "MarkdownVC.h"
#import "MarkdownEditor.h"
#import "MarkdownEditor+OctToolbarUtil.h"
#import "XTMarkdownParser+Fetcher.h"
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
@property (strong, nonatomic) MarkdownEditor    *textView ;
@property (strong, nonatomic) OctWebEditor *editor ;
@property (strong, nonatomic) XTCameraHandler   *handler;
@property (strong, nonatomic) ArticleInfoVC     *infoVC ;

@property (strong, nonatomic) Note *aNote ;
@property (copy, nonatomic) NSString *myBookID ;

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
    
    if (self.aNote) self.textView.text = self.aNote.content ;
    
    @weakify(self)
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] takeUntil:self.rac_willDeallocSignal] throttle:.6] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
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
        [self.textView.parser parseTextAndGetModelsInCurrentCursor:self.aNote.content textView:self.textView] ;
        MarkdownModel *model = [self.textView.parser modelForModelListInlineFirst] ;
        [self.textView doSomethingWhenUserSelectPartOfArticle:model] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         [self.textView parseAllTextFinishedThenRenderLeftSideAndToolbar] ;
     }] ;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated] ;
    
    [self.textView renderLeftSideAndToobar] ;
    
    if (!self.aNote) [self.textView becomeFirstResponder] ;
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
    NSString *articleContent = self.textView.text ;
    NSArray *listForBreak = [self.textView.text componentsSeparatedByString:@"\n"] ;
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
        self.textView.text = self.aNote.content ;
        [Note createNewNote:self.aNote] ;
        [self.delegate addNoteComplete:self.aNote] ;
    }
}

- (void)updateMyNote {
    if (!self.aNote) return ;
    
    NSArray *listForBreak = [self.textView.text componentsSeparatedByString:@"\n"] ;
    NSString *title = @"无标题" ;
    for (NSString *str in listForBreak) {
        if (str.length) {
            title = str ;
            break ;
        }
    }
    
    self.aNote.content = self.textView.text ;
    self.aNote.title = title ;
    [Note updateMyNote:self.aNote] ;
    [self.delegate editNoteComplete:self.aNote] ;
}

#pragma mark - UI

- (void)prepareUI {
    [self editor] ;
    self.editor.xt_theme_backgroundColor = k_md_bgColor ;
//    self.textView.xt_theme_textColor = k_md_textColor ;
    
    self.fd_prefersNavigationBarHidden = YES ;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heightForBar.constant = APP_STATUSBAR_HEIGHT + 55 ;
        [self.textView setTopOffset:55] ;
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
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder] ;
    
    [self infoVC] ;
    
    self.infoVC.aNote = self.aNote ;
    self.infoVC.parser = self.textView.parser ;
    WEAK_SELF
    self.infoVC.blkDelete = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES] ;
    } ;
    
    self.infoVC.blkOutput = ^{
        if (weakSelf.textView.isFirstResponder) {
            [weakSelf.textView resignFirstResponder] ;
            [weakSelf.textView parseAllTextFinishedThenRenderLeftSideAndToolbar] ;
            //@issue 预览之前, 把 所有, 左边展示的 mark 去掉 .
        }
        
       dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf snapShotFullScreen] ;
        }) ;
    } ;
    
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:[ArticleInfoVC movingDistance] maskAlpha:0.4 scaleY:1 direction:CWDrawerTransitionFromRight backImage:nil] ;
    [self cw_showDrawerViewController:self.infoVC animationType:0 configuration:conf] ;
}


- (void)snapShotFullScreen {
    self.navArea.hidden = YES ;
    
    CGFloat flexTop = APP_STATUSBAR_HEIGHT + 55 ;
    CGFloat textHeight = self.textView.contentSize.height + flexTop ;
    
    OutputPreviewsNailView *nail = [OutputPreviewsNailView makeANail] ;
    nail.top = textHeight ;
    [self.view addSubview:nail] ;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(APP_WIDTH, textHeight + nail.height), YES, [UIScreen mainScreen].scale) ;
    
    CGPoint savedContentOffset = self.textView.contentOffset;
    CGRect savedFrame = self.textView.frame;
    
    self.textView.mj_offsetY = - 55 ;
    self.textView.frame = CGRectMake(30, 0, self.textView.contentSize.width , self.textView.contentSize.height) ;
    self.view.frame = CGRectMake(0, 0, APP_WIDTH , textHeight + nail.height) ;
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()] ;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
    UIGraphicsEndImageContext() ;
    
    self.navArea.hidden = NO ;
    self.textView.contentOffset = savedContentOffset;
    self.textView.frame = savedFrame;
    self.view.frame = APPFRAME ;
    [nail removeFromSuperview] ;
    nail = nil ;
    
    if (!image) return ;
    
    [self dismissViewControllerAnimated:YES completion:nil] ;
    [OutputPreviewVC showFromCtrller:self imageOutput:image] ;
}

#pragma mark - prop

- (OctWebEditor *)editor {
    if (!_editor) {
        _editor = [[OctWebEditor alloc] initWithFrame:self.view.bounds] ;
        [self.view addSubview:_editor] ;
        [_editor mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop) ;
            } else {
                make.top.equalTo(self.view.xt_viewController.mas_topLayoutGuideBottom) ;
            }
            make.bottom.left.right.equalTo(self) ;
        }] ;
    }
    return _editor ;
}

//- (MarkdownEditor *)textView{
//    if(!_textView){
//        _textView = ({
//            MarkdownEditor * editor = [[MarkdownEditor alloc]init] ;
//            [self.view insertSubview:editor atIndex:0] ;
//            [editor mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.right.equalTo(self.view) ;
//                make.top.equalTo(self.mas_topLayoutGuideBottom) ;
//                make.bottom.equalTo(self.view) ;
//            }] ;
//            editor;
//       });
//    }
//    return _textView;
//}

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
