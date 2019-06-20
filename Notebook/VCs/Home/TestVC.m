//
//  TestVC.m
//  Notebook
//
//  Created by teason23 on 2019/6/5.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "TestVC.h"
#import "HomeVC.h"
#import "NHSlidingController.h"

@interface TestVC ()

@end

@implementation TestVC

+ (UIViewController *)getMe {
    NHSlidingController *topVC = [HomeVC getMe] ;
    topVC.slideDistance = 100 ;
    
    TestVC *bottomVC = [TestVC new] ;
    
    NHSlidingController *slidingController = [[NHSlidingController alloc] initWithTopViewController:bottomVC bottomViewController:topVC] ;
    slidingController.slideDistance = 300 ;
    return slidingController ;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor] ;
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
