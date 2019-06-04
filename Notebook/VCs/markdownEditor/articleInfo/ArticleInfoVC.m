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


@interface ArticleInfoVC ()

@end

@implementation ArticleInfoVC

+ (CGFloat)movingDistance {
    if (IS_IPAD) return 280 ;
    return  48. / 75. * APP_WIDTH ;
}





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
    
    self.rightForRightCorner.constant = 0 ;
    
    [self bind] ;
    
//    @weakify(self)
//    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
//
//        @strongify(self)
//        [[NSNotificationCenter defaultCenter] postNotificationName:CWLateralSlideTapNoticationKey object:self];
//    }] ;
}

- (void)bind {
    NoteBooks *book = [NoteBooks xt_findFirstWhere:XT_STR_FORMAT(@"icRecordName == '%@'",self.aNote.noteBookId)] ;
    self.lbBookName.text = book.displayBookName ?: @"暂存区" ;
    self.lbCreateTime.text = [NSDate xt_getStrWithTick:self.aNote.createDateOnServer format:kTIME_STR_FORMAT_YYYY_MM_dd_HH_mm] ;
    self.lbUpdateTime.text = [NSDate xt_getStrWithTick:self.aNote.modifyDateOnServer format:kTIME_STR_FORMAT_YYYY_MM_dd_HH_mm] ;
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
