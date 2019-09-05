//
//  NewBookVC.m
//  Notebook
//
//  Created by teason23 on 2019/4/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "NewBookVC.h"
#import "AppDelegate.h"
#import "EmojiJson.h"
#import "NoteBooks.h"
#import "EmojiChooseVC.h"
#import "UIViewController+SlidingController.h"
#import "NHSlidingController.h"
#import "GlobalDisplaySt.h"


@interface NewBookVC ()
@property (strong, nonatomic) NoteBooks *aBook ;
@end

@implementation NewBookVC

+ (instancetype)showMeFromCtrller:(UIViewController *)ctrller
                         fromView:(UIView *)fromView
                          changed:(void(^)(NSString *emoji, NSString *bookName))blkChanged
                           cancel:(void(^)(void))blkCancel {
    return [self showMeFromCtrller:ctrller fromView:fromView editBook:nil changed:blkChanged cancel:blkCancel] ;
}

+ (instancetype)showMeFromCtrller:(UIViewController *)ctrller
                         fromView:(UIView *)fromView
                         editBook:(NoteBooks *)book
                          changed:(void(^)(NSString *emoji, NSString *bookName))blkChanged
                           cancel:(void(^)(void))blkCancel {
    
    NewBookVC *vc = [NewBookVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"NewBookVC"] ;
    if (book != nil) vc.aBook = book ;
    //vc.slidingController = ctrller.slidingController ;
    
//    vc.modalPresentationStyle = UIModalPresentationPopover ;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext ;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve ;
    ctrller.definesPresentationContext = YES ;
    
    [ctrller presentViewController:vc animated:YES completion:nil] ;
    UIPopoverPresentationController *popVC = vc.popoverPresentationController ;
    popVC.sourceView = fromView ;
    popVC.permittedArrowDirections = 0 ;
    popVC.xt_theme_backgroundColor = k_md_bgColor ;
    
    @weakify(vc)
    [vc.btCreate bk_addEventHandler:^(id sender) {
        @strongify(vc)
        blkChanged(vc.lbEmoji.text, vc.tfName.text) ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    [vc.btCancel bk_addEventHandler:^(id sender) {
        blkCancel();
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    [GlobalDisplaySt sharedInstance].isInNewBookVC = YES ;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.4] ;

    self.hud.xt_cornerRadius = 14. ;
    self.hud.xt_maskToBounds = YES ;
    
    [self.tfName becomeFirstResponder] ;
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    
    self.hud.xt_theme_backgroundColor = k_md_bgColor ;
    self.underline.xt_theme_backgroundColor = k_md_iconColor ;
    [self.btCreate setTitleColor:[UIColor whiteColor] forState:0] ;
    self.btCreate.xt_theme_backgroundColor = k_md_themeColor ;
    self.btCancel.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.btCancel.xt_cornerRadius = self.btCreate.xt_cornerRadius = 8 ;
    self.btCancel.xt_borderWidth = 1 ;
    self.btCancel.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_iconColor, .2) ;
    
    self.tfName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    @weakify(self)
    [self.tfName.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        if (x.length > 0)
            self.btCreate.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_themeColor, 1) ;
        else
            self.btCreate.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_themeColor, .5) ;
        
        self.btCreate.enabled = x.length > 0 ;
    }] ;
    
    
    UIColor *phColor = [MDThemeConfiguration.sharedInstance themeColor:XT_MAKE_theme_color(k_md_textColor, .4)] ;
    self.tfName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"笔记本名" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:phColor}];

    
    self.lbEmoji.userInteractionEnabled = YES ;
    NSArray *booklist = [NoteBooks xt_findWhere:@"isDeleted == 0"] ;
    self.lbEmoji.text = [EmojiJson randomADistinctEmojiWithBooklist:booklist] ;

    WEAK_SELF
    [self.lbEmoji bk_whenTapped:^{
        [weakSelf.tfName resignFirstResponder] ;
        [EmojiChooseVC showMeFrom:weakSelf fromView:weakSelf.lbEmoji] ;
    }] ;
    
    [self.btBg bk_whenTapped:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil] ;
    }] ;
    
    
    if (self.aBook) {
        self.lbEmoji.text = self.aBook.displayEmoji ;
        self.lbTitle.text = @"编辑笔记本" ;
        self.tfName.text = self.aBook.name ;
        [self.btCreate setTitle:@"更新" forState:0] ;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated] ;
    
    [GlobalDisplaySt sharedInstance].isInNewBookVC = NO ;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

- (IBAction)create:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

#pragma mark - EmojiChooseVCDelegate <NSObject>
- (void)selectedEmoji:(EmojiJson *)emoji {
    self.lbEmoji.text = emoji.emoji ;
}



@end
