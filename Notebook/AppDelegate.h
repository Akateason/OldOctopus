//
//  AppDelegate.h
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LaunchingEvents.h"

static const int k_Is_Internal_Testing          = 1 ;  // 是否打开内测, 0默认关闭,  1打开内测
static NSString *const kNote_iap_purchased_done = @"kNote_iap_purchased_done" ;


@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow          *window;
@property (strong, nonatomic) LaunchingEvents   *launchingEvents ;

@property (nonatomic)         int               padDisplayMode ;
@end

