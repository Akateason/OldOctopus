//
//  IapUtil.m
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "IapUtil.h"
#import <XTlib/XTlib.h>



@implementation IapUtil

- (void)setup {
    if (![IAPShare sharedHelper].iap) {
//        NSSet *dataSet = [[NSSet alloc] initWithObjects:@"iap.octopus.month",@"iap.octopus.year",@"iap.test", nil] ;
        NSSet *dataSet = [[NSSet alloc] initWithObjects:k_IAP_ID_MONTH,k_IAP_ID_YEAR, nil] ;
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet] ;
    }
    
#ifdef DEBUG
    [IAPShare sharedHelper].iap.production = NO;
#else
    [IAPShare sharedHelper].iap.production = YES;
#endif

//    NSLog(@"purchasedProducts %@",[IAPShare sharedHelper].iap.purchasedProducts);
}

static NSString *const kUD_Iap_ExpireDate = @"kUD_Iap_ExpireDate" ;
+ (void)saveIapSubscriptionDate:(long long)tick {
    if (!tick) return ;
    XT_USERDEFAULT_SET_VAL(@(tick), kUD_Iap_ExpireDate) ;
}

// todo 如果本地没有 去服务端调
+ (void)fetchIapSubscriptionDate:(void(^)(long long tick))fetchBlk {
    long long localTick = [XT_USERDEFAULT_GET_VAL(kUD_Iap_ExpireDate) longLongValue] ;
    if (localTick > 0) {
        fetchBlk(localTick) ;
    }
    else {
        fetchBlk(0) ; // 暂时
    }
}

// 是否vip
+ (void)iapVipUserIsValid:(void(^)(BOOL isValid))completionBlk {
    [self fetchIapSubscriptionDate:^(long long tick) {

        tick = tick / 1000. ;
        long long nowTick = [[NSDate date] xt_getTick] ;
        NSLog(@"vip %lld - now %lld", tick, nowTick) ;
        completionBlk( nowTick <= tick ) ;
    }] ;
}

- (void)buy:(NSString *)identifier {
    // Request Products
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response) {

        if (response > 0 ) {
            for (SKProduct *product in [IAPShare sharedHelper].iap.products) {
                if ([product.productIdentifier isEqualToString:identifier]) {
                    NSLog(@"Price: %@",[[IAPShare sharedHelper].iap getLocalePrice:product]) ;
                    NSLog(@"Title: %@",product.localizedTitle);
                    
                    // buy
                    [[IAPShare sharedHelper].iap buyProduct:product onCompletion:^(SKPaymentTransaction* trans){  // 通过appdelegate中 updatedTransactions 监听, 防止漏单.
                        if (trans.error) {
                            NSLog(@"Fail %@",[trans.error localizedDescription]) ;
                        }
                        else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                            
                        }
                        else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                            NSLog(@"Fail");
                        }
                    }] ; //end of buy product
                }
            }
        }
        
     }] ;
}



@end
