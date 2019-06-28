//
//  SetGeneralVC.m
//  Notebook
//
//  Created by teason23 on 2019/6/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SetGeneralVC.h"
#import "SettingNavBar.h"
#import "SettingCell.h"

@interface SetGeneralVC ()
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation SetGeneralVC

+ (instancetype)getMe {
    SetGeneralVC *vc = [SetGeneralVC getCtrllerFromStory:@"Main" controllerIdentifier:@"SetGeneralVC"] ;
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)prepareUI {
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    self.fd_prefersNavigationBarHidden = YES ;    
    
    [SettingNavBar addInController:self] ;
    
    
    
}

@end
