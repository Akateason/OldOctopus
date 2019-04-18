//
//  BasicVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"

@interface BasicVC ()

@end

@implementation BasicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)addBlurBg {
    BOOL isDarkMode = [[MDThemeConfiguration sharedInstance].currentThemeKey containsString:@"Dark"] ;
    UIBlurEffect *blurEffrct = [UIBlurEffect effectWithStyle:isDarkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight] ;
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct] ;
    visualEffectView.frame = APPFRAME ;
    visualEffectView.alpha = 0.97 ;
    [self.view insertSubview:visualEffectView atIndex:0] ;
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
