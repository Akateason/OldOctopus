//
//  LDNotebookCell.m
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "LDNotebookCell.h"
#import <XTlib/XTlib.h>
#import "NoteBooks.h"
#import "MDThemeConfiguration.h"
#import "Note.h"

@implementation LDNotebookCell

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.selectionStyle = 0 ;
    self.imgView.hidden = YES ;
    self.imgView.xt_theme_imageColor = k_md_iconColor ;
    self.leftRedView.xt_theme_backgroundColor = k_md_themeColor ;
    self.xt_theme_backgroundColor = k_md_drawerColor ;
    self.lbName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
}

+ (CGFloat)xt_cellHeight {
    return 48. ;
}

- (void)xt_configure:(NoteBooks *)book indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:book indexPath:indexPath] ;
    
    _lbName.text = book.name ;
    if (book.vType == Notebook_Type_trash) {
        _lbName.text = XT_STR_FORMAT(@"垃圾桶 (%d)",[Note xt_countWhere:@"isDeleted == 1 AND icRecordName NOT LIKE 'mac-note%%'"]) ;
    }
    
    NBEmoji *emjObj = [NBEmoji yy_modelWithJSON:book.emoji] ;
    _lbEmoji.text = emjObj.native ;
    
    if (book.vType == Notebook_Type_notebook) {
        self.imgView.hidden = YES ;
        self.lbEmoji.hidden = NO ;
    }
    else if (book.vType != Notebook_Type_notebook) {
        self.imgView.hidden = NO ;
        self.lbEmoji.hidden = YES ;
        self.imgView.image = [UIImage imageNamed:book.emoji] ;
    }
    
    self.bgViewOnChoose.xt_theme_backgroundColor = book.isOnSelect ? XT_MAKE_theme_color(k_md_themeColor, .05) : nil ;
    self.leftRedView.hidden = !book.isOnSelect ;
    
    self.lbName.xt_theme_textColor = book.isOnSelect ? XT_MAKE_theme_color(k_md_textColor, .8)
    :  XT_MAKE_theme_color(k_md_textColor, .6) ;
    if (book.vType == Notebook_Type_add) self.lbName.xt_theme_textColor = k_md_themeColor ;
    self.imgView.xt_theme_imageColor = (book.vType == Notebook_Type_add) ? k_md_themeColor : k_md_iconColor ;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init] ;
        _imgView.contentMode = UIViewContentModeScaleAspectFit ;
        [self addSubview:_imgView] ;
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.lbEmoji) ;
            make.size.mas_equalTo(CGSizeMake(24, 24)) ;
        }] ;
    }
    return _imgView ;
}

- (void)shineOnce:(void(^)(void))completion {
    [self changeOnSelected:NO] ;
    
    [UIView animateWithDuration:.4 animations:^{
        [self changeOnSelected:YES] ;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.4 animations:^{
            [self changeOnSelected:NO] ;
        } completion:^(BOOL finished) {
            completion() ;
        }] ;
        
    }] ;
}

- (void)changeOnSelected:(BOOL)isOnSelect {
    self.bgViewOnChoose.xt_theme_backgroundColor = isOnSelect ? XT_MAKE_theme_color(k_md_themeColor, .05) : nil ;
    self.leftRedView.hidden = !isOnSelect ;
    self.lbName.xt_theme_textColor = isOnSelect ? XT_MAKE_theme_color(k_md_textColor, .8)
    :  XT_MAKE_theme_color(k_md_textColor, .6) ;
}

@end
