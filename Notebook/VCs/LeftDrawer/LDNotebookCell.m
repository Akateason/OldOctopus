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

@implementation LDNotebookCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.selectionStyle = 0 ;
    self.imgView.hidden = YES ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.bgViewOnChoose.backgroundColor = selected ? UIColorHexA(@"000000", .03) : [UIColor clearColor] ;
    self.redMark.hidden = !selected ;
    self.lbName.textColor = selected ? [MDThemeConfiguration sharedInstance].themeColor : UIColorHexA(@"000000", .6) ;
}

+ (CGFloat)xt_cellHeight {
    return 40 ;
}

- (void)xt_configure:(NoteBooks *)book indexPath:(NSIndexPath *)indexPath {
    
    _lbName.text = book.name ;
    _lbEmoji.text = book.emoji ;
    
    if (book.vType == Notebook_Type_notebook) {
        self.imgView.hidden = YES ;
        self.lbEmoji.hidden = NO ;
    }
    else if (book.vType != Notebook_Type_notebook) {
        self.imgView.hidden = NO ;
        self.lbEmoji.hidden = YES ;
        self.imgView.image = [UIImage imageNamed:book.emoji] ;
    }
}

- (void)setDistance:(float)distance {
    _flexGrayWid.constant = distance - 20. ;
}



@end