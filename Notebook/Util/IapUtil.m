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



+ (void)askCheckReceiptApiComplete:(void(^)(BOOL success, long long tick))complete {
    NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] ;
    NSString *receiptBase64 = [self.class base64StringFromData:receiptData length:[receiptData length]] ;
    
#ifdef DEBUG
    [OctRequestUtil checkReciptOnServer:receiptBase64 in_debug_mode:YES complete:complete] ;
#else
    [OctRequestUtil checkReciptOnServer:receiptBase64 in_debug_mode:NO complete:complete] ;
#endif
}

static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
} ;

+ (NSString *)base64StringFromData:(NSData *)data length:(long)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}





@end
