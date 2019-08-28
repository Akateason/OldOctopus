//
//  NoteInfoVC.m
//  Notebook
//
//  Created by teason23 on 2019/8/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "NoteInfoVC.h"

typedef void(^BlkOutput)(NoteInfoVC *infoVC) ;
typedef void(^BlkRemove)(NoteInfoVC *infoVC) ;

@interface NoteInfoVC ()
@property (copy, nonatomic) BlkOutput blkOutput ;
@property (copy, nonatomic) BlkRemove blkRemove ;

@property (strong, nonatomic) Note      *note ;
@property (strong, nonatomic) WebModel  *webModel ;
@end

@implementation NoteInfoVC

+ (instancetype)showFromCtrller:(UIViewController *)fromVC
                           note:(Note *)note
                       webModel:(WebModel *)webModel
                 outputCallback:(void(^)(NoteInfoVC *infoVC))outputBlk
                 removeCallBack:(void(^)(NoteInfoVC *infoVC))removeBlk {
    
    NoteInfoVC *vc = [NoteInfoVC getCtrllerFromStory:@"Home" controllerIdentifier:@"NoteInfoVC"] ;
    fromVC.definesPresentationContext = YES;
    vc.note = note ;
    vc.webModel = webModel ;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext ;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve ;
    vc.blkOutput = outputBlk ;
    vc.blkRemove = removeBlk ;
    [fromVC presentViewController:vc animated:YES completion:^{}] ;
    return vc ;
}


- (void)prepareUI {
    self.view.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    self.hud.xt_theme_backgroundColor = k_md_bgColor ;
    self.hud.xt_cornerRadius = 13. ;
    self.hud.xt_maskToBounds = YES ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.btClose.xt_theme_imageColor = k_md_iconColor ;
    [self.btClose xt_enlargeButtonsTouchArea] ;
    
    self.topBar.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconBorderColor, .03) ;
    
    self.topBar.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.topBar.layer.shadowOffset = CGSizeMake(0, .5) ;
    self.topBar.layer.shadowOpacity = 0 ;
    self.topBar.layer.shadowRadius = 10 ;
    
    for (UIView *line in self.seperatelineGroup) {
        line.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .2) ;
    }
    
    for (UILabel *lb in self.infoTitlesGroup) {
        lb.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    }
    
    [self.btOutput setTitleColor:XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .8) forState:0] ;
    [self.btOutput xt_setImagePosition:(XTBtImagePositionTop) spacing:6.] ;
    [self.btRemove setTitleColor:UIColorHex(@"f17b88") forState:0] ;
    [self.btRemove xt_setImagePosition:(XTBtImagePositionTop) spacing:6.] ;
    
    for (UILabel *lb in self.infoValuesGroup) {
        lb.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    }
    
    WEAK_SELF
    [self.btOutput bk_addEventHandler:^(id sender) {
        weakSelf.blkOutput(weakSelf) ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btRemove bk_addEventHandler:^(id sender) {
        weakSelf.blkRemove(weakSelf) ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btClose bk_addEventHandler:^(id sender) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    if (IS_IPAD) {
        self.width_hud.constant = 325. ;
        self.height_hud.constant = 424. ;
        self.bottom_hud.constant = (APP_HEIGHT - self.height_hud.constant) / 2. ;
    }
    else {
        self.width_hud.constant = APP_WIDTH ;
        self.height_hud.constant = 424. ;
        self.bottom_hud.constant = -13. ;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    NoteBooks *book = [NoteBooks xt_findFirstWhere:XT_STR_FORMAT(@"icRecordName == '%@'",self.note.noteBookId)] ;
    self.lbNoteBookLocation.text = book.displayBookName ?: @"暂存区" ;
    
    self.lbCreateTime.text = [NSDate xt_getStrWithTick:self.note.createDateOnServer format:kTIME_STR_FORMAT_YYYY_MM_dd_HH_mm] ;
    self.lbUpdateTime.text = [NSDate xt_getStrWithTick:self.note.modifyDateOnServer format:kTIME_STR_FORMAT_YYYY_MM_dd_HH_mm] ;
    self.lbWord.text = @(self.webModel.wordCount.word).stringValue ;
    self.lbCharacter.text = @(self.webModel.wordCount.character).stringValue ;
    self.lbParagraph.text = @(self.webModel.wordCount.paragraph).stringValue ;
    
}




@end
