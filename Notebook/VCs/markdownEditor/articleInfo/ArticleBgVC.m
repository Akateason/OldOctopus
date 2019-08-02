//
//  ArticleBgVC.m
//  Notebook
//
//  Created by teason23 on 2019/7/31.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "ArticleBgVC.h"
#import "BasicVC.h"
#import "XTMarkdownParser.h"
#import "WebModel.h"
#import "GlobalDisplaySt.h"

@interface ArticleBgVC ()

@end

@implementation ArticleBgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) {
        self.topFlex.constant = 55 + APP_STATUSBAR_HEIGHT ;
        self.topFlex2.constant = 15 + APP_STATUSBAR_HEIGHT ;
    }
    
    self.line1.xt_theme_backgroundColor =
    self.line2.xt_theme_backgroundColor =
    XT_MAKE_theme_color(k_md_textColor, .2) ;
    
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    
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
    
    [self.btClose xt_enlargeButtonsTouchArea] ;
    WEAK_SELF
    [self.btClose bk_whenTapped:^{
        [weakSelf.delegate closeBg] ;
    }] ;
    
    [self.view bk_whenTapped:^{
        
    }] ;
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

- (IBAction)btOutputAction:(id)sender {
    [self.delegate output] ;
}

- (IBAction)btDeleteAction:(id)sender {
    [self.delegate removeToTrash] ;
}

@end
