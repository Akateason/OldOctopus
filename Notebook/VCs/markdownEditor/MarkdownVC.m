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
#import <XTlib/XTPhotoAlbum.h>
#import "AppDelegate.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
#import <UIViewController+CWLateralSlide.h>
#import "XTMarkdownParser+Fetcher.h"

@interface MarkdownVC ()
@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet UIView *navArea;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBar;
@property (strong, nonatomic) MarkdownEditor    *textView ;
@property (strong, nonatomic) XTCameraHandler   *handler;

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
    [self.btBack xt_enlargeButtonsTouchArea] ;
    [self.btMore xt_enlargeButtonsTouchArea] ;
    
    self.navArea.backgroundColor = nil ;
    
    self.topBar.backgroundColor = nil ;

    [self.topBar setNeedsDisplay] ;
    [self.topBar layoutIfNeeded] ;
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES] ;
}

- (IBAction)moreAction:(id)sender {
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

- (CGFloat)movingDistance {
    return  48. / 75. * APP_WIDTH ;
}

@end
