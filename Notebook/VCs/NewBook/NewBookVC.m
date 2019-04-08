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

@end

@implementation NewBookVC

+ (instancetype)showMeFromCtrller:(UIViewController *)ctrller
                          changed:(void(^)(NSString *emoji, NSString *bookName))blkChanged
                           cancel:(void(^)(void))blkCancel
{
    
    NewBookVC *vc = [NewBookVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"NewBookVC"] ;
    [[UIApplication sharedApplication].delegate.window addSubview:vc.view] ;
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([UIApplication sharedApplication].delegate.window) ;
    }] ;
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
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:.9] ;
    
    self.lbTitle.textColor = [MDThemeConfiguration sharedInstance].textColor;
    self.underline.backgroundColor = [MDThemeConfiguration sharedInstance].themeColor ;
    [self.btCreate setTitleColor:[MDThemeConfiguration sharedInstance].themeColor forState:0] ;
    [self.btCancel setTitleColor:[MDThemeConfiguration sharedInstance].textColor forState:0] ;
    self.btCancel.alpha = .4 ;
    
    self.lbEmoji.userInteractionEnabled = YES ;
    NSArray *booklist = [NoteBooks xt_findWhere:@"isDeleted == 0"] ;
    self.lbEmoji.text = [EmojiJson randomADistinctEmojiWithBooklist:booklist] ;

    WEAK_SELF
    [self.lbEmoji bk_whenTapped:^{
        weakSelf.lbEmoji.text = [EmojiJson randomADistinctEmojiWithBooklist:booklist] ;
    }] ;
}

- (IBAction)cancel:(id)sender {
    [self.view removeFromSuperview] ;
}

- (IBAction)create:(id)sender {
   [self.view removeFromSuperview] ;
}

@end
