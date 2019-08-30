//
//  IapUtil.m
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "IapUtil.h"
#import <XTlib/XTlib.h>
#import "OctRequestUtil.h"


@implementation IapUtil

- (void)setup {
    NSSet *dataSet = [[NSSet alloc] initWithObjects:k_IAP_ID_MONTH,k_IAP_ID_YEAR, nil] ;
    [[XTIAP sharedInstance] setup:dataSet] ;
    [XTIAP sharedInstance].isManuallyFinishTransaction = YES ;
}

static NSString *const kUD_Iap_ExpireDate = @"kUD_Iap_ExpireDate" ;
+ (void)saveIapSubscriptionDate:(long long)tick {
    if (!tick) return ;
    XT_USERDEFAULT_SET_VAL(@(tick), kUD_Iap_ExpireDate) ;
}

// 获得iap超出时间 如果本地没有 去服务端调
+ (void)fetchIapSubscriptionDate:(void(^)(long long tick))fetchBlk {
    long long localTick = [XT_USERDEFAULT_GET_VAL(kUD_Iap_ExpireDate) longLongValue] ;
    if (localTick > 0) {
        fetchBlk(localTick) ;
    }
    else {
        // ask iap expire date for server
        [OctRequestUtil getIapInfo:^(long long tick, BOOL success) {
            if (success) {
                XT_USERDEFAULT_SET_VAL(@(tick), kUD_Iap_ExpireDate) ;
                fetchBlk(tick) ;
            }
            else {
                fetchBlk(0) ;
            }
        }] ;
    }
}

+ (void)geteIapStateFromSever {
    [OctRequestUtil getIapInfo:^(long long tick, BOOL success) {
        if (success) {
            XT_USERDEFAULT_SET_VAL(@(tick), kUD_Iap_ExpireDate) ;
        }
        else {
        }
    }] ;
}

// 是否vip
+ (void)iapVipUserIsValid:(void(^)(BOOL isValid))completionBlk {
    [self fetchIapSubscriptionDate:^(long long tick) {
        
        if (k_Is_Internal_Testing) {
            completionBlk( YES ) ;
            return ; // 测试状态下默认全部打开
        }
            
        
        tick = tick / 1000. ;
        long long nowTick = [[NSDate date] xt_getTick] ;
        NSLog(@"vip %lld - now %lld", tick, nowTick) ;
        completionBlk( nowTick <= tick ) ;
    }] ;
}

// 是否vip同步 , 如果没有,则去请求一把.并存本地
+ (BOOL)isIapVipFromLocalAndRequestIfLocalNotExist {
    if (k_Is_Internal_Testing) return YES ; // 测试状态下默认全部打开
    
    long long localTick = [XT_USERDEFAULT_GET_VAL(kUD_Iap_ExpireDate) longLongValue] ;
    if (localTick > 0) {
        localTick = localTick / 1000. ;
        long long nowTick = [[NSDate date] xt_getTick] ;
        if (nowTick <= localTick) {
            DDLogDebug(@"是vip");
        }
//        NSLog(@"vip %lld - now %lld 是否vip %d 截止日:%@", localTick, nowTick, nowTick <= localTick, [NSDate xt_getStrWithTick:localTick]) ;
        return nowTick <= localTick ;
    }
    
    [self fetchIapSubscriptionDate:^(long long tick) {}] ;
    return NO ;
}

- (void)buy:(NSString *)identifier {
    // Request Products
    [[XTIAP sharedInstance] requestProductWithID:identifier complete:^(SKProduct *product) {
        
        [[XTIAP sharedInstance] buyProduct:product] ;
    }] ;
}

- (void)productInfo:(NSString *)identifier complete:(void(^)(SKProduct *product))completion {
    [[XTIAP sharedInstance] requestProductWithID:identifier complete:^(SKProduct *product) {
        NSLog(@"Price: %@",[[XTIAP sharedInstance] getLocalePrice:product]) ;
        NSLog(@"Title: %@",product.localizedTitle) ;
        if (completion) completion(product) ;
    }] ;
}



@end
