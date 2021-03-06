//
//  OctRequestUtil.h
//  Notebook
//
//  Created by teason23 on 2019/7/5.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class XTImageItem ;

NS_ASSUME_NONNULL_BEGIN

@interface OctRequestUtil : NSObject

+ (void)getShareHtmlLink:(NSString *)html
                complete:(void (^)(NSString *urlString))completion ;

+ (void)uploadImage:(XTImageItem *)image
           progress:(nullable void (^)(float progress))progressValueBlock
           complete:(void (^)(NSString *urlString))completion ;


/**
 验证码 校验
 
 @param code          测试码  octopus_test_code
 @param completion
 return {count = 0;}
 */
+ (void)verifyCode:(NSString *)code
        completion:(void(^)(bool success))completion ;


// iap
+ (void)getIapInfo:(void(^)(long long tick, BOOL success))complete ;

//todo deprecated
+ (void)setIapInfoExpireDateTick:(long long)tick
                        complete:(void(^)(BOOL success))complete ;

// 后台验证订单
+ (void)checkReciptOnServer:(NSString *)receipt64
              in_debug_mode:(BOOL)in_debug_mode
                   complete:(void(^)(BOOL success, long long tick))complete ;


// 保存订单信息
+ (void)saveOrders:(NSString *)body complete:(void(^)(BOOL success))complete ;

// 恢复购买 后台 api, 根据返回值处理, 如果成功则更新本地, 不成功启动本地restore.
//+ (void)restoreOnServer ;

@end

NS_ASSUME_NONNULL_END
