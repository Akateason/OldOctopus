//
//  AppDelegate.h
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LaunchingEvents.h"

// 内测模式下, 内购全部打开.
static const int k_Is_Internal_Testing = 1 ;  // 是否打开内测, 0默认关闭,  1打开内测

// 临时 控制 unsplash开关， 以后去掉，一直打开
static const int k_open_Unspash = 1 ;

// 临时 测试 连续购买开关，无论购买与否都可以继续订阅, 默认关闭
static const int k_Subscript_Test_On = 0 ;


@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow          *window;
@property (strong, nonatomic) LaunchingEvents   *launchingEvents ;

@property (nonatomic)         int               padDisplayMode ;
@end


