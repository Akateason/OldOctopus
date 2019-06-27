//
//  SetGeneralVC.m
//  Notebook
//
//  Created by teason23 on 2019/6/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SetGeneralVC.h"
#import "SettingNavBar.h"

@interface SetGeneralVC ()

@end

@implementation SetGeneralVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    
}

- (void)prepareUI {
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    self.fd_prefersNavigationBarHidden = YES ;    
    
    [SettingNavBar addInController:self] ;
    
    
    
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
