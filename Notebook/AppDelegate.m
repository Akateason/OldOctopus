//
//  AppDelegate.m
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "AppDelegate.h"
#import <XTlib/XTlib.h>
#import "XTCloudHandler.h"
#import "Note.h"
#import "GlobalDisplaySt.h"
#import "HomePadVC.h"
#import "HomeVC.h"
#import "OctWebEditor.h"
#import "OctGuidingVC.h"
#import "MDNavVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "OctMBPHud.h"
#import "IapUtil.h"
#import "OctRequestUtil.h"

@interface AppDelegate () <SKPaymentTransactionObserver>

@end

@implementation AppDelegate

- (void)test {
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"transactionState %ld",(long)transaction.transactionState) ;
        
        if (transaction.transactionState == SKPaymentTransactionStatePurchased
            ) {
            
#ifdef DEBUG
            [[IAPShare sharedHelper].iap checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] AndSharedSecret:kAPP_SHARE_SECRET onCompletion:^(NSString *response, NSError *error) {
                [self dealReciept:response transaction:transaction error:error] ;
            }] ;
#else
            [[IAPShare sharedHelper].iap checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] onCompletion:^(NSString *response, NSError *error) {
                [self dealReciept:response transaction:transaction error:error] ;
            }] ;
#endif
        }
        else if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ;
        }
        else if (transaction.transactionState == SKPaymentTransactionStatePurchasing) {
            [[OctMBPHud sharedInstance] hide] ;
        }
    }
}

- (void)dealReciept:(NSString *)response
        transaction:(SKPaymentTransaction *)transaction
              error:(NSError *)error {
    
    if (!error) {
        NSDictionary* rec = [IAPShare toJSON:response];
        if ([rec[@"status"] integerValue] == 0) {
            [[IAPShare sharedHelper].iap provideContentWithTransaction:transaction];
            NSLog(@"SUCCESS %@",response);
            NSLog(@"Pruchases %@",[IAPShare sharedHelper].iap.purchasedProducts);
            
            NSDictionary *dictLatestReceiptsInfo = rec[@"latest_receipt_info"];
            long long int expirationDateMs = [[dictLatestReceiptsInfo valueForKeyPath:@"@max.expires_date_ms"] longLongValue] ; // 结束时间
            long long requestDateMs = [rec[@"receipt"][@"request_date_ms"] longLongValue] ;//请求时间
            NSLog(@"%lld--%lld", expirationDateMs, requestDateMs) ;
            NSDate *resExpiraDate = [NSDate xt_getDateWithTick:(expirationDateMs / 1000.0)] ;
            NSLog(@"新订单截止到 : %@", resExpiraDate) ;
            
            // 调api 成功后, 再设置本地的 更新时间
            [OctRequestUtil setIapInfoExpireDateTick:expirationDateMs complete:^(BOOL success) {
                
                if (success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_iap_purchased_done object:nil] ;
                    
                    // finish transaction .
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ;
                    // 设置本地
                    [IapUtil saveIapSubscriptionDate:expirationDateMs] ;
                    // hud
                    //                                [SVProgressHUD showSuccessWithStatus:@"订阅成功"] ;
                }
            }] ;
        }
        else {
            NSLog(@"Fail") ;
            [SVProgressHUD showErrorWithStatus:@"购买失败, 请检查网络"] ;
        }

    }
    else {
        NSLog(@"Fail, %@",error) ;
        [SVProgressHUD showErrorWithStatus:@"购买失败, 请检查网络"] ;
    }
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (IS_IPAD) [[UIApplication sharedApplication] setStatusBarHidden:YES] ;
    
    // iap observer
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self] ; // 处理iap回调
    IapUtil *iap = [IapUtil new] ;
    [iap setup] ;
    [IapUtil geteIapStateFromSever] ;
    
    // lauching events
    self.launchingEvents = [[LaunchingEvents alloc] init] ;
    [self.launchingEvents setup:application appdelegate:self] ;

    //
    if (![XTIcloudUser userInCacheSyncGet]) {
        [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser *user) {
            [self.launchingEvents pullAll] ;
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
    
    
    [[GlobalDisplaySt sharedInstance] correctCurrentCondition:self.window.rootViewController] ;

    if ([self.window.rootViewController isKindOfClass:MDNavVC.class]) return ; // guiding

    OctGuidingVC *guidVC = [OctGuidingVC getMe] ;
    if (guidVC != nil) {
        MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:guidVC] ;
        self.window.rootViewController = navVC ;
        [self.window makeKeyAndVisible] ;
        
        [self.launchingEvents setupAlbumn] ;
    }
    else {
        [self setupRootWIndow] ;
    }
}

- (void)setupRootWIndow {
    int displayMode = [GlobalDisplaySt sharedInstance].displayMode ;
    if (self.padDisplayMode == displayMode) return ;
    
    if (displayMode == GDST_Home_2_Column_Verical_default) {
        self.window.rootViewController = [HomeVC getMe] ;
        [self.window makeKeyAndVisible] ;
    }
    else if (displayMode == GDST_Home_3_Column_Horizon) {
        self.window.rootViewController = [HomePadVC getMe] ;
        [self.window makeKeyAndVisible] ;
    }
    self.padDisplayMode = displayMode ;
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
 
