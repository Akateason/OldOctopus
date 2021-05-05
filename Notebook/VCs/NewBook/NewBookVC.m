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


@interface NewBookVC ()
@property (strong, nonatomic) NoteBooks *aBook ;
@end

@implementation NewBookVC

+ (instancetype)showMeFromCtrller:(UIViewController *)ctrller
                          changed:(void(^)(NSString *emoji, NSString *bookName))blkChanged
                           cancel:(void(^)(void))blkCancel {
    return [self showMeFromCtrller:ctrller editBook:nil changed:blkChanged cancel:blkCancel] ;
}

+ (instancetype)showMeFromCtrller:(UIViewController *)ctrller
                         editBook:(NoteBooks *)book
                          changed:(void(^)(NSString *emoji, NSString *bookName))blkChanged
                           cancel:(void(^)(void))blkCancel {
    
    NewBookVC *vc = [NewBookVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"NewBookVC"] ;
    if (book != nil) vc.aBook = book ;
    
    [[UIApplication sharedApplication].delegate.window addSubview:vc.view] ;
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([UIApplication sharedApplication].delegate.window) ;
    }] ;
    @weakify(vc)
    [vc.btCreate xt_addEventHandler:^(id sender) {
        @strongify(vc)
        blkChanged(vc.lbEmoji.text, vc.tfName.text) ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    [vc.btCancel xt_addEventHandler:^(id sender) {
        blkCancel();
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.view.backgroundColor = nil ; //    
    [self.view oct_addBlurBg] ;
    
    [self.tfName becomeFirstResponder] ;
    
    self.lbTitle.xt_theme_textColor = k_md_textColor ;
    self.underline.xt_theme_backgroundColor = k_md_themeColor ;
    self.btCreate.xt_theme_textColor = XT_MAKE_theme_color(k_md_themeColor, 1) ;
    self.btCancel.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    self.tfName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    @weakify(self)
    [self.tfName.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        if (x.length > 0)
            self.btCreate.xt_theme_textColor = XT_MAKE_theme_color(k_md_themeColor, 1) ;
        else
            self.btCreate.xt_theme_textColor = XT_MAKE_theme_color(k_md_themeColor, .5) ;
        
        self.btCreate.enabled = x.length > 0 ;
    }] ;
    
    
    UIColor *phColor = [MDThemeConfiguration.sharedInstance themeColor:XT_MAKE_theme_color(k_md_textColor, .4)] ;
    [self.tfName setValue:phColor forKeyPath:@"_placeholderLabel.textColor"] ;
    
    self.lbEmoji.userInteractionEnabled = YES ;
    NSArray *booklist = [NoteBooks xt_findWhere:@"isDeleted == 0"] ;
    self.lbEmoji.text = [EmojiJson randomADistinctEmojiWithBooklist:booklist] ;

    WEAK_SELF
    [self.lbEmoji xt_whenTapped:^{
        weakSelf.lbEmoji.text = [EmojiJson randomADistinctEmojiWithBooklist:booklist] ;
    }] ;
    
    if (self.aBook) {
        self.lbEmoji.text = self.aBook.displayEmoji ;
        self.lbTitle.text = @"编辑笔记本" ;
        self.tfName.text = self.aBook.name ;
        [self.btCreate setTitle:@"更新" forState:0] ;
    }
}

- (IBAction)cancel:(id)sender {
    [self.view removeFromSuperview] ;
}

- (IBAction)create:(id)sender {
   [self.view removeFromSuperview] ;
}

@end
