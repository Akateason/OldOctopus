//
//  ArticleInfoVC.m
//  Notebook
//
//  Created by teason23 on 2019/4/15.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "ArticleInfoVC.h"
#import "MarkdownPaser.h"


@interface ArticleInfoVC ()

@end

@implementation ArticleInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topHeight.constant = 55 + APP_STATUSBAR_HEIGHT ;
    
    for (UILabel *lb in self.lbCollectForKeys) {
        lb.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    }
    for (UILabel *lb in self.lvCollectionForVals) {
        lb.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    }
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.btOutput.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.btDelete.xt_theme_textColor = k_md_themeColor ;
    
    self.topArea.xt_theme_backgroundColor = k_md_bgColor ;
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)] ;
    [self.view addGestureRecognizer:recognizer] ;
    
    self.rightForRightCorner.constant = APP_WIDTH - self.distance + self.imgRight.width + 20 ;
    
    [self bind] ;
}

- (void)bind {
    NoteBooks *book = [NoteBooks xt_findFirstWhere:XT_STR_FORMAT(@"icRecordName == '%@'",self.aNote.noteBookId)] ;
    self.lbBookName.text = book.displayBookName ;
    self.lbCreateTime.text = [NSDate xt_getStrWithTick:self.aNote.xt_createTime format:kTIME_STR_FORMAT_YYYY_MM_dd_HH_mm] ;
    self.lbUpdateTime.text = [NSDate xt_getStrWithTick:self.aNote.xt_updateTime format:kTIME_STR_FORMAT_YYYY_MM_dd_HH_mm] ;
    self.lbCountOfWord.text = @(self.parser.countForWord).stringValue ;
    self.lbCountOfCharactor.text = @(self.parser.countForCharactor).stringValue ;
    self.lbCountOfPara.text = @(self.parser.countForPara).stringValue ;
}

- (void)handleSwipeFrom:(id)gesture {
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

- (IBAction)btOutputAction:(id)sender {


    if (self.blkOutput) self.blkOutput() ;
}

- (IBAction)btDeleteAction:(id)sender {
    // Delete Note
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"确认要删除此文章吗?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
        if (btnIndex == 1) {
            self.aNote.isDeleted = YES ;
            [Note updateMyNote:self.aNote] ;
            [self dismissViewControllerAnimated:YES completion:^{}] ;
            
            self.blkDelete() ;
        }
    }] ;
}








/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
