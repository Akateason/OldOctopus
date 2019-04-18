 //
//  MarkdownVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
// 假导航

#import "MarkdownVC.h"
#import "MarkdownEditor.h"
#import "MarkdownEditor+UtilOfToolbar.h"
#import <XTlib/XTPhotoAlbum.h>
#import "AppDelegate.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
#import "ArticleInfoVC.h"
#import <UIViewController+CWLateralSlide.h>

@interface MarkdownVC ()
@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet UIView *navArea;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBar;
@property (strong, nonatomic) MarkdownEditor    *textView ;
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
    [super viewDidLoad];
    
    if (self.aNote) {
        self.textView.text = self.aNote.content ;
    }
    
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
        self.aNote = [Note xt_findFirstWhere: XT_STR_FORMAT(@"icRecordName == '%@'",self.aNote.icRecordName)] ;
        
        NSArray *modellist = [self.textView.markdownPaser parseText:self.aNote.content position:self.textView.selectedRange.location textView:self.textView] ; // create models
        MarkdownModel *model = [self.textView.markdownPaser modelForModelListInlineFirst:modellist] ;
        [self.textView doSomethingWhenUserSelectPartOfArticle:model] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         [self.textView parseTextThenRenderLeftSideAndToobar] ;
     }] ;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated] ;
    
    [self.textView parseTextThenRenderLeftSideAndToobar] ;
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
    NSString *title = [[self.textView.text componentsSeparatedByString:@"\n"] firstObject] ?: self.textView.text ;
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
    
    self.aNote.content = self.textView.text ;
    self.aNote.title = [[self.textView.text componentsSeparatedByString:@"\n"] firstObject] ?: self.textView.text ;
    [Note updateMyNote:self.aNote] ;
    [self.delegate editNoteComplete:self.aNote] ;
}



#pragma mark - UI

- (void)prepareUI {
    [self textView] ;
    self.textView.xt_theme_backgroundColor = k_md_bgColor ;
    self.textView.xt_theme_textColor = k_md_textColor ;
    
    self.fd_prefersNavigationBarHidden = YES ;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heightForBar.constant = APP_STATUSBAR_HEIGHT + 55 ;
        [self.textView setTopOffset:55] ;
    }) ;
    
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    @weakify(self)
    [self cw_registerShowIntractiveWithEdgeGesture:YES transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        @strongify(self)
        if (direction == CWDrawerTransitionFromRight) [self moreAction:nil] ;
    }] ;
    
    self.btBack.xt_theme_imageColor = k_md_iconColor ;
    self.btMore.xt_theme_imageColor = k_md_iconColor ;
    
    self.navArea.backgroundColor = nil ;
    self.topBar.backgroundColor = nil ;
    [self.topBar oct_addBlurBg] ;
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES] ;
}

- (IBAction)moreAction:(id)sender {
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder] ;
    
    [self infoVC] ;
    self.infoVC.distance = self.movingDistance ;
    self.infoVC.aNote = self.aNote ;
    self.infoVC.parser = self.textView.markdownPaser ;
    WEAK_SELF
    self.infoVC.blkDelete = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES] ;
    } ;
    self.infoVC.blkOutput = ^{
       dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf snapShotFullScreen] ;
        }) ;
    } ;
    
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:self.movingDistance maskAlpha:0.1 scaleY:1 direction:CWDrawerTransitionFromRight backImage:nil] ;
    self.infoVC.view.width = self.movingDistance ;
    [self cw_showDrawerViewController:self.infoVC animationType:0 configuration:conf] ;
}


- (void)snapShotFullScreen {
    UIImage* image = nil;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，调整清晰度。
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(APP_WIDTH, self.textView.contentSize.height), YES, [UIScreen mainScreen].scale) ;

    CGPoint savedContentOffset = self.textView.contentOffset;
    CGRect savedFrame = self.textView.frame;
    self.textView.contentOffset = CGPointZero;
    self.textView.frame = CGRectMake(30, 0, self.textView.contentSize.width , self.textView.contentSize.height) ;
    self.view.frame = CGRectMake(0, 0, APP_WIDTH , self.textView.contentSize.height) ;
    self.navArea.hidden = YES ;
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()] ;
    image = UIGraphicsGetImageFromCurrentImageContext() ;
    UIGraphicsEndImageContext() ;
    
    self.navArea.hidden = NO ;
    self.textView.contentOffset = savedContentOffset;
    self.textView.frame = savedFrame;
    self.view.frame = APPFRAME ;
    
    if (!image) return ;
    
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init] ;
    [lib saveImage:image toAlbum:@"小章鱼" completionBlock:^(NSError *error) {
        if (error) return ;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"已经保存到本地相册"] ;
        }) ;
    }] ;
}

#pragma mark - prop

- (MarkdownEditor *)textView{
    if(!_textView){
        _textView = ({
            MarkdownEditor * editor = [[MarkdownEditor alloc]init] ;
            [self.view insertSubview:editor atIndex:0] ;
            [editor mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.view) ;
                
                make.top.equalTo(self.mas_topLayoutGuideBottom) ;
                make.bottom.equalTo(self.view) ;
            }] ;
            editor;
       });
    }
    return _textView;
}

- (ArticleInfoVC *)infoVC{
    if(!_infoVC){
        _infoVC = ({
            ArticleInfoVC * object = [ArticleInfoVC getCtrllerFromNIBWithBundle:[NSBundle bundleForClass:self.class]] ;
            object;
       });
    }
    return _infoVC;
}

- (CGFloat)movingDistance {
    return  48. / 75. * APP_WIDTH ;
}

@end
