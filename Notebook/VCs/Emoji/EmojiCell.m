//
//  EmojiCell.m
//  Notebook
//
//  Created by teason23 on 2019/7/9.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "EmojiCell.h"
#import <XTlib/XTlib.h>
#import "EmojiJson.h"


@implementation EmojiCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)xt_configure:(EmojiJson *)model {
    [super xt_configure:model] ;
    
    self.lbEmoji.text = model.emoji ;
}



@end
