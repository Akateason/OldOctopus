//
//  MDNavVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDNavVC.h"
#import <XTlib/XTlib.h>

@interface MDNavVC ()

@end

@implementation MDNavVC

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    UIImage *backBtn = [UIImage imageNamed:@"nav_back_item" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    self.navigationBar.backIndicatorImage = backBtn;
    self.navigationBar.backIndicatorTransitionMaskImage = backBtn;
    self.navigationBar.topItem.title = @"";
    self.navigationBar.tintColor = UIColorHex(@"222222") ;
    self.navigationBar.backgroundColor = [UIColor whiteColor] ;
    
    
    self.navigationBar.barTintColor = [UIColor whiteColor] ;
    UIImage *whiteLine = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(APP_WIDTH, 2)] ;
    [self.navigationBar setBackgroundImage:whiteLine forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new] ;

}

@end
