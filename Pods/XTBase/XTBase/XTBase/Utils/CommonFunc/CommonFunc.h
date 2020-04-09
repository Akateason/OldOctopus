//
//  CommonFunc.h
//  SuBaoJiang
//
//  Created by apple on 15/6/18.
//  Copyright (c) 2015年 teason. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CommonFunc : NSObject


#pragma mark - Get top
+ (UIViewController *)topVC ;
+ (UIWindow *)topWindow ;


#pragma mark - App Info
+ (NSDictionary *)getAppInfo ;
+ (NSString *)getAppName;
+ (NSString *)getVersionStrOfMyAPP;
+ (NSString *)getBuildVersion;

#pragma mark - Device Info
- (NSString *)getDeviceName ;
+ (BOOL)getIsIpad ;
+ (void)shutDownAppWithCtrller:(UIViewController *)ctrller;

@end
