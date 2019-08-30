//
//  OcBookCell.m
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcBookCell.h"
#import "BookBgView.h"

@interface OcBookCell ()
@property (strong, nonatomic) BookBgView *bookBgView ;
@end

@implementation OcBookCell

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.bookBgView = [[BookBgView alloc] initWithSize:YES book:nil] ;
    [self.viewForBookIcon addSubview:self.bookBgView] ;
    [self.bookBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.viewForBookIcon) ;
    }] ;
    
    self.viewForBookIcon.backgroundColor = nil ;
    
    self.viewOnSelected.alpha = 0 ;
    self.viewOnSelected.xt_theme_imageColor = k_md_themeColor ;
    
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = .7 ;
    [self addGestureRecognizer:longPressGr] ;
}

- (void)longPressToDo:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.delegate) [self.delegate longPressed:self.xt_indexPath] ;
    }
}


- (void)xt_configure:(NoteBooks *)book indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:book indexPath:indexPath] ;
    
    self.lbName.text = book.name ;
    [self.bookBgView configBook:book] ;
    
    if (book.isOnSelect == NO) {
        self.viewOnSelected.alpha = 0 ;
        self.lbName.textColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .6) ;
    }
    else {
        self.viewOnSelected.transform = CGAffineTransformMakeScale(1.3, 1.3) ;
        [UIView animateWithDuration:.4 animations:^{
            self.lbName.textColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .8) ;
            self.viewOnSelected.alpha = 1 ;
            self.viewOnSelected.transform = CGAffineTransformIdentity ;
        } completion:^(BOOL finished) {
            
        }] ;
    }
}


@end
