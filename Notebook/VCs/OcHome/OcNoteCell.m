//
//  OcNoteCell.m
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//



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
    
    self.topMark.xt_theme_imageColor = k_md_themeColor ;
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.sepLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .05) ;
    self.lbContent.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    self.lbDate.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    
    self.img.backgroundColor = [UIColor colorWithWhite:0 alpha:.03] ;
    self.img.xt_borderWidth = .25 ;
    self.img.xt_cornerRadius = 2. ;
    
    self.btMore.xt_theme_imageColor = k_md_iconColor ;
    self.xt_theme_backgroundColor = k_md_bgColor ;
    
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
    
    
    UIImageView *shadowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_cell_shadow"]] ;
    shadowImage.contentMode = UIViewContentModeScaleAspectFill ;
    shadowImage.xt_maskToBounds = YES ;
    [self insertSubview:shadowImage belowSubview:self.lbContent] ;
    [shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.lbContent) ;
        make.top.equalTo(self.sepLine.mas_bottom).offset(12) ;
        make.bottom.equalTo(self.bookPHView.mas_top).offset(-15) ;
    }] ;
    shadowImage.xt_theme_imageColor = k_md_iconBorderColor ;
    self.bgShadow = shadowImage ;
    
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
    _sepLine.hidden = _lbContent.hidden = _bgShadow.hidden = hasPic ;
    
    if (hasPic) {
        NSArray *list = [WebModel convertjsonStringToJsonObj:note.previewPicture] ;
        [self loadImageListloop:list index:0 indexPath:indexPath note:note] ;
    }
    else {
        [self renderClearTextState:note] ;
    }
    
    self.topMark.hidden = !note.isTop ;
    
    self.img.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_iconColor, 0.1) ;
    self.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .06) ;
    
    [self setNeedsLayout] ;
    [self layoutIfNeeded] ;
}

- (void)renderClearTextState:(Note *)note {
  
   _lbContent.attributedText = [[NSAttributedString alloc] initWithString:[note displayDesciptionString]] ;
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
    [self.img sd_setImageWithURL:imgUrl completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
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
    self.img.hidden = !hasPic ;
    self.sepLine.hidden = self.lbContent.hidden = self.bgShadow.hidden = hasPic ;
    [self renderClearTextState:note] ;
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
        self.topMark.hidden = YES ;
    }
}

- (void)setRecentState:(BOOL)recentState {
    _recentState = recentState ;
    
    self.bookPHView.hidden = !recentState ;
    self.lead_date.constant = recentState ? 54. : 20. ;
}

@end
