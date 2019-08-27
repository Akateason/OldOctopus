//
//  MNTBCell.m
//  Notebook
//
//  Created by teason23 on 2019/8/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MNTBCell.h"

@implementation MNTBCell

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.lbName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.sepLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .1) ;
    self.xt_theme_backgroundColor = k_md_bgColor ;
}

- (void)xt_configure:(NoteBooks *)model indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:model indexPath:indexPath] ;
    
    self.lbName.text = model.name ;
    self.lbEmoji.text = model.displayEmoji ;
}






- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
