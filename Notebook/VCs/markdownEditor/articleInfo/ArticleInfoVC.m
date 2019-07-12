//
//  ArticleInfoVC.m
//  Notebook
//
//  Created by teason23 on 2019/4/15.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "ArticleInfoVC.h"
#import "XTMarkdownParser.h"
#import "UIViewController+CWLateralSlide.h"
#import "WebModel.h"

@interface ArticleInfoVC ()

@end

@implementation ArticleInfoVC

+ (CGFloat)movingDistance {
    if (IS_IPAD) return 280 ;
    return  48. / 75. * APP_WIDTH ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.imgRight.hidden = YES ;
//    self.btOutput.hidden = YES ;
    
    
    self.wid_rightPart.constant = [self.class movingDistance] ;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.3] ;
    self.bgView.xt_theme_backgroundColor = k_md_bgColor ;
    
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
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)] ;
    [self.view addGestureRecognizer:recognizer] ;
    
    [self bind] ;
}

- (void)setWebInfo:(WebModel *)webInfo {
    _webInfo = webInfo ;
    
    [self bind] ;
}


- (void)bind {
    NoteBooks *book = [NoteBooks xt_findFirstWhere:XT_STR_FORMAT(@"icRecordName == '%@'",self.aNote.noteBookId)] ;
    self.lbBookName.text = book.displayBookName ?: @"暂存区" ;
    self.lbCreateTime.text = [NSDate xt_getStrWithTick:self.aNote.createDateOnServer format:kTIME_STR_FORMAT_YYYY_MM_dd_HH_mm] ;
    self.lbUpdateTime.text = [NSDate xt_getStrWithTick:self.aNote.modifyDateOnServer format:kTIME_STR_FORMAT_YYYY_MM_dd_HH_mm] ;
    self.lbCountOfWord.text = @(self.webInfo.wordCount.word).stringValue ;
    self.lbCountOfCharactor.text = @(self.webInfo.wordCount.character).stringValue ;
    self.lbCountOfPara.text = @(self.webInfo.wordCount.paragraph).stringValue ;
}

- (void)handleSwipeFrom:(id)gesture {
    
    [UIView animateWithDuration:.4 animations:^{
        self.bgView.left = APP_WIDTH ;
        self.view.alpha = 0.1 ;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview] ;
        self.bgView.left = APP_WIDTH - self.wid_rightPart.constant ;
    }] ;
}

- (IBAction)btOutputAction:(id)sender {
    if (self.blkOutput) self.blkOutput() ;
}

- (IBAction)btDeleteAction:(id)sender {
    // Delete Note
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"确认要将此文章放入垃圾桶?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
        if (btnIndex == 1) {
            self.aNote.isDeleted = YES ;
            [Note updateMyNote:self.aNote] ;
            [self dismissViewControllerAnimated:YES completion:^{
                
            }] ;
            
            self.blkDelete() ;
        }
    }] ;
}

@end
