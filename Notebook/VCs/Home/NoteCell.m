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


@implementation NoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = 0 ;
    self.area.backgroundColor = UIColorRGBA(255, 255, 255, .8) ;
    
    
    self.area.layer.backgroundColor = UIColorRGBA(255, 255, 255, .8).CGColor ;
    self.area.layer.cornerRadius = 4;
    self.area.layer.shadowColor = UIColorRGBA(0, 0, 0, .06).CGColor ;
    self.area.layer.shadowOffset = CGSizeMake(0,2);
    self.area.layer.shadowOpacity = 1;
    self.area.layer.shadowRadius = 6;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)xt_configure:(Note *)note indexPath:(NSIndexPath *)indexPath {
    _lbTitle.text = note.title ;
    _lbContent.text = note.content ;
    _lbDate.text = [note.record.modificationDate xt_timeInfo] ;
}

+ (CGFloat)xt_cellHeight {
    return 118 ;
}


@end
