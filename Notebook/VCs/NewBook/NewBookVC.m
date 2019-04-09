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
