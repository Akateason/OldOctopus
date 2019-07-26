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



@interface AppDelegate () <SKPaymentTransactionObserver>

@end

@implementation AppDelegate





- (void)test {
//    NSString *jsonlist = @"[\"h3\"]" ;
//    NSArray *list = [self.class convertjsonStringToDict:jsonlist] ;
//    NSArray *list = [NSArray yy_modelArrayWithClass:[NSString class] json:jsonlist] ;
    
    [IapUtil iapVipUserIsValid:^(BOOL isValid) {
        
    }] ;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"transactionState %ld",(long)transaction.transactionState) ;
        
        if (transaction.transactionState == SKPaymentTransactionStatePurchased
            ) {
            
            [[IAPShare sharedHelper].iap checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] AndSharedSecret:kAPP_SHARE_SECRET onCompletion:^(NSString *response, NSError *error) {
                
                //Convert JSON String to NSDictionary
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

                        
                        // 调api 成功后, 设置本地的 更新时间
                        [IapUtil saveIapSubscriptionDate:expirationDateMs] ;
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ;
                        
                    }
                    else {
                        NSLog(@"Fail");
                    }
                }
                else {
                    NSLog(@"Fail, %@",error);
                }
            }] ;
        }
        else if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ;
        }
        else {
            
        }
    }
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (IS_IPAD) [[UIApplication sharedApplication] setStatusBarHidden:YES] ;
    
    // iap
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self] ; // 处理iap回调
    IapUtil *iap = [IapUtil new] ;
    [iap setup] ;
    
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
 
