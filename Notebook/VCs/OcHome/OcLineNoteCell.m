//
//  OcLineNoteCell.m
//  Notebook
//
//  Created by teason23 on 2019/12/16.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcLineNoteCell.h"

@implementation OcLineNoteCell

- (void)awakeFromNib {
    [super awakeFromNib] ;
        
    _topLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_bgColor, .04) ;
    _bottomLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_bgColor, .04) ;
    _btMore.xt_theme_imageColor = k_md_iconColor ;
    self.xt_theme_backgroundColor = k_md_bgColor ;
    
    _lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    _lbDesc.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    _lbDate.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    

    
}



- (void)xt_configure:(Note *)note indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:note indexPath:indexPath] ;
    
    NSString *title = [Note filterMD:note.title] ;
    if (!title || !title.length) title = @"未命名的笔记" ;
    _lbTitle.text = title ;
    _lbDate.text = [[NSDate xt_getDateWithTick:note.modifyDateOnServer] xt_timeInfo] ;
//    NoteBooks *book = [NoteBooks getBookWithBookID:note.noteBookId] ;
//    [self.bookBg configBook:book] ;
//
//    BOOL hasPic = note.previewPicture && note.previewPicture.length > 0 ;
//    _img.hidden = !hasPic ;
//    _sepLine.hidden = _lbContent.hidden = _bgShadow.hidden = hasPic ;
//
//    if (hasPic) {
//        NSArray *list = [WebModel convertjsonStringToJsonObj:note.previewPicture] ;
//        [self loadImageListloop:list index:0 indexPath:indexPath note:note] ;
//    }
//    else {
//        [self renderClearTextState:note] ;
//    }
//
//    self.topMark.hidden = !note.isTop ;
//
//    self.img.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_iconColor, 0.1) ;
//    self.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .06) ;
//
//    [self setNeedsLayout] ;
//    [self layoutIfNeeded] ;
}


@end
