//
//  TestVC.m
//  Notebook
//
//  Created by teason23 on 2019/6/5.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "TestVC.h"

#import "HomeVC.h"
#import "LeftDrawerVC.h"
#import "MDNavVC.h"
#import "NHSlidingController.h"

@interface TestVC ()

@end

@implementation TestVC

+ (UIViewController *)getMe {
//    HomeVC *homeVC = [HomeVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"HomeVC"] ;
//    MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:homeVC] ;
//
//    LeftDrawerVC *leftVC = [LeftDrawerVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"LeftDrawerVC"] ;
//    leftVC.delegate = homeVC ;
//    homeVC.leftVC = leftVC ;
//
////    NHSlidingController *slidingController = [[NHSlidingController alloc] initWithTopViewController:navVC bottomViewController:leftVC slideDistance:HomeVC.movingDistance] ;
//
//    TestVC *testVC = [TestVC new] ;
//
//    NHSlidingController *slidingController = [[NHSlidingController alloc] initWithTopViewController:testVC bottomViewController:navVC slideDistance:400] ;
//    NHSlidingController *slideVC = [[NHSlidingController alloc] initWithTopViewController:slidingController bottomViewController:leftVC slideDistance:600] ;
//    return slideVC ;
    
    return nil ;
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
