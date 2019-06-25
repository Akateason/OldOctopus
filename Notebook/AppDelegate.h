//
//  AppDelegate.h
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LaunchingEvents.h"

// 控制wkWebview default 0 加载本地 , 1 加载线上
static const int g_isLoadWebViewOnline = 1 ;


@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LaunchingEvents *launchingEvents ;
@end

