//
//  SearchEmptyVC.m
//  Notebook
//
//  Created by teason23 on 2019/4/17.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SearchEmptyVC.h"

@interface SearchEmptyVC ()

@end

@implementation SearchEmptyVC

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.view.xt_theme_backgroundColor = nil ;
    self.lbWord.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .2) ;
}

@end
