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
    self.area.xt_theme_backgroundColor = k_md_bgColor ;
    self.xt_theme_backgroundColor = k_md_bgColor ;

    _lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    _lbContent.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    _lbDate.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.area.xt_theme_backgroundColor =  selected ? XT_MAKE_theme_color(k_md_textColor, 0.03) : k_md_bgColor ;
}

static int kLimitCount = 70 ;

- (void)xt_configure:(Note *)note indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:note indexPath:indexPath] ;
    
    _lbTitle.text = [self filterMarkdownString:note.title] ;
    NSString *content = [self filterMarkdownString:note.content] ;
    if (content.length > kLimitCount) content = [[content substringToIndex:kLimitCount] stringByAppendingString:@" ..."] ;
    _lbContent.text = content ;
    _lbDate.text = [[NSDate xt_getDateWithTick:note.xt_updateTime] xt_timeInfo] ;
}

+ (CGFloat)xt_cellHeight {
    return 120 ;
}

- (NSString *)filterMarkdownString:(NSString *)markdownStr {
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"\n" withString:@" "] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"#" withString:@""] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"*" withString:@""] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"_" withString:@""] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"~" withString:@""] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"`" withString:@""] ;
    return markdownStr ;
}




- (void)setTextForSearching:(NSString *)textForSearching {
    _textForSearching = textForSearching ;
    
    if ([self.lbTitle.text containsString:textForSearching]) {
        self.lbTitle.text = self.lbTitle.text ;
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.lbTitle.text] ;
        NSArray <NSNumber *> *listRange = [NSString rangesOfString:self.lbTitle.text referString:textForSearching] ;
        [listRange enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = NSMakeRange([obj intValue], textForSearching.length) ;
            NSDictionary * resultDic = @{NSBackgroundColorAttributeName : XT_MD_THEME_COLOR_KEY_A(k_md_themeColor, .3) ,
                                         NSFontAttributeName : self.lbTitle.font
                                         };
            [attr addAttributes:resultDic range:range] ;
        }] ;
        self.lbTitle.attributedText = attr ;
    }
    if ([self.lbContent.text containsString:textForSearching]) {
        self.lbContent.text = self.lbContent.text ;
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.lbContent.text] ;
        NSArray <NSNumber *> *listRange = [NSString rangesOfString:self.lbContent.text referString:textForSearching] ;
        [listRange enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = NSMakeRange([obj intValue], textForSearching.length) ;
            NSDictionary * resultDic = @{NSBackgroundColorAttributeName : XT_MD_THEME_COLOR_KEY_A(k_md_themeColor, .3) ,
                                         NSFontAttributeName : self.lbContent.font
                                         };
            [attr addAttributes:resultDic range:range] ;
        }] ;
        self.lbContent.attributedText = attr ;
    }
}

@end
