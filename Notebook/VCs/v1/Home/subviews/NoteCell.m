//
//  NoteCell.m
//  Notebook
//
//  Created by teason23 on 2019/3/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "NoteCell.h"
#import <XTlib/XTlib.h>
#import "Note.h"
#import "XTCloudHandler.h"
#import "MDThemeConfiguration.h"
#import "MdInlineModel.h"


@implementation NoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = 0 ;
    self.area.xt_theme_backgroundColor = IS_IPAD ? XT_MAKE_theme_color(k_md_midDrawerPadColor, 1) : k_md_bgColor ;
    self.xt_theme_backgroundColor = IS_IPAD ? XT_MAKE_theme_color(k_md_midDrawerPadColor, 1) : k_md_bgColor ;

    _lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    _lbContent.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    _lbDate.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    _img_isTop.hidden = YES ;
    
}

- (void)setUserSelected:(BOOL)userSelected {
    if (_userSelected == YES && userSelected == YES) return ; // 修复一直闪烁的问题

    _userSelected = userSelected ;
    
    if (IS_IPAD) {
        self.area.xt_theme_backgroundColor =  userSelected ? XT_MAKE_theme_color(k_md_drawerSelectedColor, 1) : XT_MAKE_theme_color(k_md_midDrawerPadColor, 1) ;
    }
    else {
        self.area.xt_theme_backgroundColor =  userSelected ? XT_MAKE_theme_color(k_md_textColor, 0.03) : k_md_bgColor ;
    }
    
    if (!userSelected) return ;
    
    self.lbTitle.alpha = 0. ;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.lbTitle.alpha = 1 ;
                     }
                     completion:nil] ;

    self.lbTitle.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1) ;
    [UIView animateWithDuration:.07
                     animations:^{
                         self.lbTitle.layer.transform = CATransform3DIdentity ;
                     }
                     completion:nil] ;
    
    self.lbDate.alpha = 0. ;
    self.lbContent.alpha = 0. ;
    [UIView animateWithDuration:1.
                     animations:^{
                         self.lbDate.alpha = 1. ;
                         self.lbContent.alpha = 1. ;
                     }] ;
}



static int kLimitCount = 70 ;

- (void)xt_configure:(Note *)note indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:note indexPath:indexPath] ;
    
    NSString *title = [Note filterMD:note.title] ;
    if (!title || !title.length) title = @"未命名的笔记" ;
    _lbTitle.text = title ;
    NSString *content = [Note filterMD:note.content] ;
    if (!content || !content.length) content = @"美好的故事，从小章鱼开始..." ;
    if (content.length > kLimitCount) content = [[content substringToIndex:kLimitCount] stringByAppendingString:@" ..."] ;
    _lbContent.attributedText = [[NSAttributedString alloc] initWithString:content] ;
    
    _lbDate.text = [[NSDate xt_getDateWithTick:note.modifyDateOnServer] xt_timeInfo] ;
    _img_isTop.hidden = !note.isTop ;
}

- (void)trashMode:(BOOL)isTrashmode {
    if (isTrashmode) {
        _lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
        _lbContent.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    }
    else {
        _lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
        _lbContent.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    }
}

+ (CGFloat)xt_cellHeight {
    return 120 ;
}

- (void)setTextForSearching:(NSString *)textForSearching {
    _textForSearching = textForSearching ;
    
    if ([self.lbTitle.text containsString:textForSearching]) {
        self.lbTitle.text = self.lbTitle.text ;
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.lbTitle.text] ;
        NSArray <NSValue *> *listRange = [self.lbTitle.text xt_searchAllRangesWithText:textForSearching] ;
        [listRange enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = obj.rangeValue ;
            NSDictionary * resultDic = @{NSBackgroundColorAttributeName : XT_GET_MD_THEME_COLOR_KEY_A(k_md_themeColor, .3) ,
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
            NSDictionary * resultDic = @{NSBackgroundColorAttributeName : XT_GET_MD_THEME_COLOR_KEY_A(k_md_themeColor, .3) ,
                                         NSFontAttributeName : self.lbContent.font
                                         };
            [attr addAttributes:resultDic range:range] ;
        }] ;
        self.lbContent.attributedText = attr ;
    }
}

@end
