//
//  AppDelegate.m
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "AppDelegate.h"
#import "OctWebEditor.h"
#import "OctGuidingVC.h"
#import "MDNavVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "OctMBPHud.h"
#import "IapUtil.h"
#import "OctRequestUtil.h"
#import <XTIAP/XTIAP.h>
#import "OcHomeVC.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)test {
    
}


// 验证票据
- (void)dealReciept:(NSDictionary *)rec
        transaction:(SKPaymentTransaction *)transaction
              error:(NSError *)error {
    
    if (!error) {
        NSInteger status = [rec[@"status"] integerValue]  ;
        if ( status == 0 ) {
            DLogINFO(@"iap SUCCESS") ;
            NSDictionary *dictLatestReceiptsInfo = rec[@"latest_receipt_info"];
            long long int expirationDateMs = [[dictLatestReceiptsInfo valueForKeyPath:@"@max.expires_date_ms"] longLongValue] ; // 结束时间
            long long requestDateMs = [rec[@"receipt"][@"request_date_ms"] longLongValue] ;//请求时间
            NSLog(@"%lld--%lld", expirationDateMs, requestDateMs) ;
            NSDate *resExpiraDate = [NSDate xt_getDateWithTick:(expirationDateMs / 1000.0)] ;
            DLogINFO(@"新订单截止到 : %@", resExpiraDate) ;
            
            // 调api 成功后, 再设置本地的 更新时间
            WEAK_SELF
            [OctRequestUtil setIapInfoExpireDateTick:expirationDateMs complete:^(BOOL success) {
                
                if (success) {
                    // 保存订单信息
                    NSString *body = [rec yy_modelToJSONString] ;
                    if (body != nil || body.length > 0) {
                        [OctRequestUtil saveOrders:body complete:^(BOOL success) {
                        }] ;
                    }
                    
                    // finish transaction
                    if ([SKPaymentQueue defaultQueue]) {
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ; // 如果不成功，下次还会接受到此transaction .
                    }
                    // 设置本地
                    [IapUtil saveIapSubscriptionDate:expirationDateMs] ;
                    // 订阅成功之后 pull all
                    [weakSelf.launchingEvents pullAll] ;
                    // Notificate
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_iap_purchased_done object:nil] ;
                }
            }] ;
        }
        else {
            DLogERR(@"dealReciept Fail : %@",rec) ;
            NSString *res = XT_STR_FORMAT(@"购买失败, 请检查网络\n%@\n%@",rec,error) ;
            [SVProgressHUD showErrorWithStatus:res] ;
        }

    }
    else {
        DLogERR(@"dealReciept Fail : %@",error) ;
        NSString *res = XT_STR_FORMAT(@"购买失败, 请检查网络\n%@\n%@",rec,error) ;
        [SVProgressHUD showErrorWithStatus:res] ;
    }
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    if (IS_IPAD) [[UIApplication sharedApplication] setStatusBarHidden:YES] ;
    
    IapUtil *iap = [IapUtil new] ;
    [iap setup] ;
    [IapUtil geteIapStateFromSever] ;
    
    // SKPaymentQueue callback
    [XTIAP sharedInstance].g_transactionBlock = ^(SKPaymentTransaction *transaction) {

        DLogERR(@"transactionState %ld",(long)transaction.transactionState) ;
        
        if (transaction.transactionState == SKPaymentTransactionStatePurchased
            ) {
#ifdef DEBUG
            [[XTIAP sharedInstance] checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] sharedSecret:kAPP_SHARE_SECRET excludeOld:NO inDebugMode:YES onCompletion:^(NSDictionary *json, NSError *error) {
                [self dealReciept:json transaction:transaction error:error] ;
            }] ;
#else
            [[XTIAP sharedInstance] checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] sharedSecret:kAPP_SHARE_SECRET excludeOld:NO inDebugMode:NO onCompletion:^(NSDictionary *json, NSError *error) {
                [self dealReciept:json transaction:transaction error:error] ;
            }] ;
#endif
        }
        else if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            if ([SKPaymentQueue defaultQueue]) {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ;
            }
        }
        else if (transaction.transactionState == SKPaymentTransactionStatePurchasing) {
            [[OctMBPHud sharedInstance] hide] ;
        }
        else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            if ([SKPaymentQueue defaultQueue]) {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ;
            }
            DLogERR(@"订阅失败error : %@", transaction.error) ;
        }
    } ;
    
    
    // lauching events
    self.launchingEvents = [[LaunchingEvents alloc] init] ;
    [self.launchingEvents setup:application appdelegate:self] ;
    
    
    // set Root Controller START
    OctGuidingVC *guidVC = [OctGuidingVC getMe] ;
    if (guidVC != nil) {
        MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:guidVC] ;
        self.window.rootViewController = navVC ;
        [self.window makeKeyAndVisible] ;
        
        [self.launchingEvents setupAlbumn] ;
    }
    else {
        UIViewController *vc = [OcHomeVC getMe] ;
        self.window.rootViewController = vc ;
        [self.window makeKeyAndVisible] ;
    }
    // set Root Controller END
    
    
    // 容错处理, 有时会出现icloud用户无法获取的情况(网络问题). 导致第一次无数据.
    NSNumber *num = XT_USERDEFAULT_GET_VAL(kUD_OCT_PullAll_Done) ;
    if ([num intValue] != 1) {
        
        @weakify(self)
        [[[RACSignal interval:10 onScheduler:[RACScheduler mainThreadScheduler]] take:3] subscribeNext:^(NSDate * _Nullable x) {
            @strongify(self)
            NSNumber *num1 = XT_USERDEFAULT_GET_VAL(kUD_OCT_PullAll_Done) ;
            if ([num1 intValue] == 1) return ;
            
            @weakify(self)
            [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser *user) {
                @strongify(self)
                [self.launchingEvents pullAll] ;
            }] ;
        }] ;
    }
    
    [self test] ;
    
    return YES ;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {

    CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    NSString *alertBody = cloudKitNotification.alertBody;
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
        CKRecordID *recordID = [(CKQueryNotification *)cloudKitNotification recordID] ;
    }
    
    [self.launchingEvents icloudSync:^{
        completionHandler(UIBackgroundFetchResultNewData);
    }] ;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [self.launchingEvents icloudSync:^{
        completionHandler(UIBackgroundFetchResultNewData);
    }] ;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

static NSString *const kUD_Guiding_mark = @"kUD_Guiding_mark" ;
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[OctMBPHud sharedInstance] hide] ;

}


//file:///private/var/mobile/Containers/Data/Application/929D7113-DCE0-4F39-9436-D85BFD644DC6/Documents/Inbox/%E7%BC%96%E8%BE%91%E5%99%A8%E4%BA%A4%E4%BA%92%E8%AE%BE%E8%AE%A1.md
//导入文件,默认导入到当前的笔记本,如果是最近或者垃圾桶,进入暂存区. 导入之后打开此笔记.
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self.launchingEvents application:app openURL:url options:options] ;
}


#pragma mark --
#pragma mark - screen rotate

- (BOOL)shouldAutorotate {
    if (IS_IPAD) {
        return YES ;
    }
    return NO ;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (IS_IPAD) {
        return UIInterfaceOrientationMaskAll ;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)nowWindow {
    if (IS_IPAD) {
        return UIInterfaceOrientationMaskAll ;
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
 
