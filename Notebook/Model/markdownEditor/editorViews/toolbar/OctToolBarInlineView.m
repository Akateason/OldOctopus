//
//  OctToolBarInlineView.m
//  Notebook
//
//  Created by teason23 on 2019/5/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctToolBarInlineView.h"
#import <XTlib/XTlib.h>

@implementation OctToolBarInlineView

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.area1.backgroundColor = [UIColor whiteColor] ;
    self.area2.backgroundColor = [UIColor whiteColor] ;
    self.area3.backgroundColor = [UIColor whiteColor] ;
    self.area4.backgroundColor = [UIColor whiteColor] ;
    
    self.area1.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area2.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area3.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area4.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    
    self.area1.xt_borderWidth = .5 ;
    self.area2.xt_borderWidth = .5 ;
    self.area3.xt_borderWidth = .5 ;
    self.area4.xt_borderWidth = .5 ;
    
    self.area1.xt_cornerRadius = 6 ;
    self.area2.xt_cornerRadius = 6 ;
    self.area3.xt_cornerRadius = 6 ;
    self.area4.xt_cornerRadius = 6 ;
    
    
    
}




@end
