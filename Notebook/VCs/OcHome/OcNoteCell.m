//
//  OcNoteCell.m
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

static int kLimitCount = 70 ;

#import "OcNoteCell.h"
#import "WebModel.h"
#import "OcHomeVC.h"
#import "SearchVC.h"

@implementation OcNoteCell

- (void)awakeFromNib {
    [super awakeFromNib] ;
    // Initialization code
    
    self.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .06) ;
    self.xt_borderWidth = .5 ;
    self.xt_cornerRadius = 2 ;
    
    self.bookBg = [[BookBgView alloc] initWithSize:NO book:nil] ;
    [self.bookPHView addSubview:self.bookBg] ;
    [self.bookBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bookPHView) ;
    }] ;
    self.bookPHView.backgroundColor = nil ;
    
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.sepLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .05) ;
    self.lbContent.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    self.lbDate.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    self.img.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, 0.03) ;
    self.btMore.xt_theme_imageColor = k_md_iconColor ;
    self.xt_theme_backgroundColor = k_md_bgColor ;
//    self.backgroundColor = [UIColor blueColor] ;
    
    [self.btMore xt_enlargeButtonsTouchArea] ;
    WEAK_SELF
    [self.btMore bk_addEventHandler:^(id sender) {
        
        id vc = weakSelf.xt_viewController ;
        if ([vc isKindOfClass:[OcHomeVC class]]) {
            [(OcHomeVC *)weakSelf.xt_viewController noteCellDidSelectedBtMore:weakSelf.xt_model fromView:weakSelf.btMore] ;
        }
        else if ([vc isKindOfClass:[SearchVC class]]) {
            [(SearchVC *)weakSelf.xt_viewController noteCellDidSelectedBtMore:weakSelf.xt_model fromView:weakSelf.btMore] ;
        }
        
    } forControlEvents:(UIControlEventTouchUpInside)] ;
}

- (void)xt_configure:(Note *)note indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:note indexPath:indexPath] ;
    
    NSString *title = [Note filterMD:note.title] ;
    if (!title || !title.length) title = @"未命名的笔记" ;
    _lbTitle.text = title ;
    _lbDate.text = [[NSDate xt_getDateWithTick:note.modifyDateOnServer] xt_timeInfo] ;
    NoteBooks *book = [NoteBooks getBookWithBookID:note.noteBookId] ;
    [self.bookBg configBook:book] ;
    
    BOOL hasPic = note.previewPicture && note.previewPicture.length > 0 ;
    _img.hidden = !hasPic ;
    _sepLine.hidden = _lbContent.hidden = hasPic ;
    
    if (hasPic) {
        NSArray *list = [WebModel convertjsonStringToJsonObj:note.previewPicture] ;
        [_img sd_setImageWithURL:[NSURL URLWithString:list.firstObject]] ;
    }
    else {
        NSString *content = [Note filterMD:note.content] ;
        if (!content || !content.length) content = @"美好的故事，从小章鱼开始..." ;
        if (content.length > kLimitCount) content = [[content substringToIndex:kLimitCount] stringByAppendingString:@" ..."] ;
        _lbContent.attributedText = [[NSAttributedString alloc] initWithString:content] ;
    }
    
    self.topMark.hidden = !note.isTop ;
    
}

- (void)setTextForSearching:(NSString *)textForSearching {
    _textForSearching = textForSearching ;
    
    if ([self.lbTitle.text containsString:textForSearching]) {
        self.lbTitle.text = self.lbTitle.text ;
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.lbTitle.text] ;
        NSArray <NSValue *> *listRange = [self.lbTitle.text xt_searchAllRangesWithText:textForSearching] ;
        [listRange enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = obj.rangeValue ;
            NSDictionary * resultDic = @{NSBackgroundColorAttributeName : XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ,
                                         NSFontAttributeName : self.lbTitle.font
                                         };
            [attr addAttributes:resultDic range:range] ;
        }] ;
        self.lbTitle.attributedText = attr ;
    }
    if ([self.lbContent.text containsString:textForSearching]) {
        self.lbContent.text = self.lbContent.text ;
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.lbContent.text] ;
        NSArray <NSValue *> *listRange = [self.lbContent.text xt_searchAllRangesWithText:textForSearching] ;
        [listRange enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = obj.rangeValue ;
            NSDictionary * resultDic = @{NSBackgroundColorAttributeName : XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ,
                                         NSFontAttributeName : self.lbContent.font
                                         };
            [attr addAttributes:resultDic range:range] ;
        }] ;
        self.lbContent.attributedText = attr ;
    }
}

- (void)setTrashState:(BOOL)trashState {
    if (trashState) {
        self.btMore.hidden = YES ;
        self.img.alpha = self.lbTitle.alpha = self.lbContent.alpha = .4 ;
        self.lbDate.alpha = .3 ;
        self.bookPHView.hidden = YES ;
        self.lead_date.constant = 20. ;
    }
}

@end
