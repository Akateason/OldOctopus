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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.lbWord.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    self.view.xt_theme_backgroundColor = nil ;
//    self.view.xt_theme_backgroundColor = k_md_bgColor ;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
