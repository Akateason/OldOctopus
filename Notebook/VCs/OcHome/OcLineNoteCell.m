//
//  OcLineNoteCell.m
//  Notebook
//
//  Created by teason23 on 2019/12/16.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcLineNoteCell.h"
#import "WebModel.h"
#import "OcHomeVC.h"
#import "SearchVC.h"


static int kLimitCount = 70 ;

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
    _container.xt_theme_backgroundColor = k_md_bgColor ;

    _pic.xt_cornerRadius = 4. ;
    
    [self.btMore xt_enlargeButtonsTouchArea] ;
    WEAK_SELF
    [self.btMore bk_addEventHandler:^(id sender) {
        
        [weakSelf.btMore oct_buttonClickAnimationComplete:^{
            id vc = weakSelf.xt_viewController ;
            if ([vc isKindOfClass:[OcHomeVC class]]) {
                [(OcHomeVC *)weakSelf.xt_viewController noteCellDidSelectedBtMore:weakSelf.xt_model fromView:weakSelf.btMore] ;
            }
        }] ;
        
    } forControlEvents:(UIControlEventTouchUpInside)] ;

    
}

- (void)configBook:(NoteBooks *)book {
    if (book.vType != Notebook_Type_notebook) {
        UIImage *image = [UIImage imageNamed:@"ld_bt_staging_s"] ;
        image = [image xt_imageWithTintColor:XT_GET_MD_THEME_COLOR_KEY(k_md_iconColor)] ;
        self.imgBook.image = image ;
        self.imgBook.hidden = NO ;
        self.lbBook.hidden = YES ;
    }
    else {
        self.lbBook.text = book.displayEmoji ;
        self.imgBook.hidden = YES ;
        self.lbBook.hidden = NO ;
    }
}

- (void)xt_configure:(Note *)note indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:note indexPath:indexPath] ;
    
    NSString *title = [Note filterMD:note.title] ;
    if (!title || !title.length) title = @"未命名的笔记" ;
    _lbTitle.text = title ;
    _lbDate.text = [[NSDate xt_getDateWithTick:note.modifyDateOnServer] xt_timeInfo] ;
    NoteBooks *book = [NoteBooks getBookWithBookID:note.noteBookId] ;
    [self configBook:book] ;
    [self renderClearTextState:note] ;


    BOOL hasPic = note.previewPicture && note.previewPicture.length > 0 ;
    _pic.hidden = !hasPic ;
    _tail_desc.constant = _tail_title.constant = hasPic ? 114. : 0. ;

    if (hasPic) {
        NSArray *list = [WebModel convertjsonStringToJsonObj:note.previewPicture] ;
        [self loadImageListloop:list index:0 indexPath:indexPath note:note] ;
    }
    
    self.topMark.hidden = !note.isTop ;
    
    [self setNeedsLayout] ;
    [self layoutIfNeeded] ;
}


- (void)renderClearTextState:(Note *)note {
    _lbDesc.attributedText = [[NSAttributedString alloc] initWithString:[note displayDesciptionString]] ;
}

- (void)loadImageListloop:(NSArray *)list
                    index:(int)index
                indexPath:(NSIndexPath *)indexPath
                     note:(Note *)note {
    
    NSString *strUrl = list[index] ;
    if (!list || !strUrl) {
        [self hiddenPicRenderText:note] ;

        return ;
    }
    
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    NSURL *imgUrl = [NSURL URLWithString:strUrl] ;
    
    @weakify(self)
    [self.pic sd_setImageWithURL:imgUrl completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        @strongify(self)
        
        BOOL notThisRow = indexPath.row != self.xt_indexPath.row ;
        
        if (error != nil || notThisRow) {
            if ([note.icRecordName isEqualToString:((Note *)self.xt_model).icRecordName]) {
                [self hiddenPicRenderText:note] ;
            }
        }
    }] ;
}

- (void)hiddenPicRenderText:(Note *)note {
    BOOL hasPic = NO ;
    self.pic.hidden = !hasPic ;
    
    _tail_desc.constant = _tail_title.constant = hasPic ? 114. : 0. ;
    
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
    if ([self.lbDesc.text containsString:textForSearching]) {
        self.lbDesc.text = self.lbDesc.text ;
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.lbDesc.text] ;
        NSArray <NSValue *> *listRange = [self.lbDesc.text xt_searchAllRangesWithText:textForSearching] ;
        [listRange enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = obj.rangeValue ;
            NSDictionary * resultDic = @{NSBackgroundColorAttributeName : XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ,
                                         NSFontAttributeName : self.lbDesc.font
                                         };
            [attr addAttributes:resultDic range:range] ;
        }] ;
        self.lbDesc.attributedText = attr ;
    }
}

@end
