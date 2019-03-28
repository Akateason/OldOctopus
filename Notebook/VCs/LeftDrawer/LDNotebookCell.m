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

@implementation LDNotebookCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _lbEmoji.backgroundColor = [UIColor redColor] ;

//    _flexGrayWid.constant = 66 ; //distance - 20. ;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)xt_cellHeight {
    return 40 ;
}

- (void)xt_configure:(NoteBooks *)book indexPath:(NSIndexPath *)indexPath {
    
    _lbName.text = book.name ;
    _lbEmoji.text = book.emoji ;
}

- (void)setDistance:(float)distance {
    _flexGrayWid.constant = distance - 20. ;
    
    [self setNeedsDisplay] ;
    [self layoutIfNeeded] ;
}



@end
