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
    [super awakeFromNib];
    
    self.bookBgView = [[BookBgView alloc] initWithSize:YES book:nil] ;
    [self.viewForBookIcon addSubview:self.bookBgView] ;
    [self.bookBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.viewForBookIcon) ;
    }] ;
}

- (void)xt_configure:(NoteBooks *)book indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:book indexPath:indexPath] ;
    
    self.lbName.text = book.name ;
    [self.bookBgView configBook:book] ;
}


@end
