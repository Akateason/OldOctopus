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


@implementation NoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = 0 ;
    self.area.backgroundColor = [UIColor whiteColor] ;
    self.backgroundColor = nil ;
    
    _lbTitle.textColor = [MDThemeConfiguration sharedInstance].darkTextColor ;
    _lbContent.textColor = [MDThemeConfiguration sharedInstance].lightTextColor ;
    _lbDate.textColor = [MDThemeConfiguration sharedInstance].textColor ;
    _lbDate.alpha = .3 ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)xt_configure:(Note *)note indexPath:(NSIndexPath *)indexPath {
    _lbTitle.text = note.title ;
    _lbContent.text = [self filterMarkdownString:note.content] ;
    _lbDate.text = [[NSDate xt_getDateWithTick:note.xt_updateTime] xt_timeInfo] ;
    //[note.record.modificationDate xt_timeInfo] ;
}

+ (CGFloat)xt_cellHeight {
    return 122 ;
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

@end
