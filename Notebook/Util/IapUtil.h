//
//  IapUtil.h
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IAPHelper/IAPHelper.h>
#import <IAPShare.h>
#import <XYIAPKit/XYIAPKit.h>

// 共享沙盒密钥
static NSString *const kAPP_SHARE_SECRET = @"5498d6de8ace4f52acd789f795ee9a81" ;
static NSString *const k_IAP_ID_MONTH = @"iap.octopus.month" ;
static NSString *const k_IAP_ID_YEAR  = @"iap.octopus.year" ;


@interface IapUtil : NSObject
- (void)setup ;

- (void)buy:(NSString *)identifier ;
- (void)productInfo:(NSString *)identifier complete:(void(^)(SKProduct *product))completion ;

+ (void)saveIapSubscriptionDate:(long long)tick ;

// 获得iap超出时间 如果本地没有 去服务端调
+ (void)fetchIapSubscriptionDate:(void(^)(long long tick))fetchBlk ;

// 每次启动, 调一把 以服务端为准
+ (void)geteIapStateFromSever ;



// 是否vip异步
+ (void)iapVipUserIsValid:(void(^)(BOOL isValid))completionBlk ;
// 是否vip同步
+ (BOOL)isIapVipFromLocalAndRequestIfLocalNotExist ;


@end


