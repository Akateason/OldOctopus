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

+ (CGFloat)xt_cellHeight {
    return 40 ;
}

- (void)xt_configure:(NoteBooks *)book indexPath:(NSIndexPath *)indexPath {
    
    _lbName.text = book.name ;
    
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
    
    self.bgViewOnChoose.backgroundColor = book.isOnSelect ? UIColorHexA(@"000000", .03) : [UIColor clearColor] ;
    self.lbName.textColor = book.isOnSelect ? [MDThemeConfiguration sharedInstance].themeColor : UIColorHexA(@"000000", .6) ;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init] ;
        [self addSubview:_imgView] ;
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.lbEmoji) ;
            make.size.mas_equalTo(CGSizeMake(20, 20)) ;
        }] ;
    }
    
    return _imgView ;
}




@end
