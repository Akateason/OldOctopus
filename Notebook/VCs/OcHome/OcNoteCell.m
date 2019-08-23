//
//  OcNoteCell.m
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

static int kLimitCount = 70 ;

#import "OcNoteCell.h"


@implementation OcNoteCell

- (void)awakeFromNib {
    [super awakeFromNib] ;
    // Initialization code
    
    self.xt_borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.06] ;
    self.xt_borderWidth = .5 ;
    self.xt_cornerRadius = 2 ;
    
    self.bookBg = [[BookBgView alloc] initWithSize:NO book:nil] ;
    [self.bookPHView addSubview:self.bookBg] ;
    [self.bookBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bookPHView) ;
    }] ;
    
    self.bookPHView.backgroundColor = nil ;
}

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
    
    NoteBooks *book = [NoteBooks getBookWithBookID:note.noteBookId] ;
    [self.bookBg configBook:book] ;
    
}





@end
