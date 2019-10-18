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


// 处理收据结果,处理订阅时间
- (void)dealRecieptTransaction:(SKPaymentTransaction *)transaction
                    expireTick:(long long)tick
                      complete:(BOOL)complete
{
    DLogINFO(@"处理订单 : %@", transaction.transactionIdentifier) ;

    if (complete) {
        NSDate *resExpiraDate = [NSDate xt_getDateWithTick:(tick / 1000.0)] ;
        DLogINFO(@"新订单截止到 : %@", resExpiraDate) ;
        if (!tick && !complete) {
            DLogERR(@"拿不到收据 : %@",transaction) ;
            // finish transaction
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ; //
            return ;
        }
        
        if ([resExpiraDate compare:[NSDate date]] == NSOrderedAscending) {
            DLogERR(@"订单已经过期 : %@",transaction) ;
            // finish transaction
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ; // 如果不成功，下次还会接受到此transaction .
            return ;
        }

        // success
        // 设置本地
        [IapUtil saveIapSubscriptionDate:tick] ;
        // 订阅成功之后 pull all
        [self.launchingEvents pullAll] ;
        // finish transaction
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ; // 如果不成功，下次还会接受到此transaction .
        // Notificate
        [[NSNotificationCenter defaultCenter] postNotificationName:kNote_iap_purchased_done object:nil] ;
        DLogINFO(@"订单订阅成功 : %@", transaction.transactionIdentifier) ;
    }
    else {
        DLogERR(@"验证收据失败 transaction : %@",transaction) ;
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ; // 如果不成功，下次还会接受到此transaction .
    }
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    if (IS_IPAD) [[UIApplication sharedApplication] setStatusBarHidden:YES] ;
    
    IapUtil *iap = [IapUtil new] ;
    [iap setup] ;
    [IapUtil geteIapStateFromSever] ;
    
    // SKPaymentQueue callback
    [XTIAP sharedInstance].g_transactionBlock = ^(SKPaymentTransaction *transaction) {
        DLogINFO(@"transaction UPDATE id : %@",transaction.transactionIdentifier) ;
        
//        [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ;
        
        if (transaction.transactionState == SKPaymentTransactionStatePurchased
            ) {
            NSLog(@"%@ purchased",transaction.transactionIdentifier) ;
            [IapUtil askCheckReceiptApiComplete:^(BOOL success, long long tick) {
                [self dealRecieptTransaction:transaction expireTick:tick complete:success] ;
            }] ;
        }
        else if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            NSLog(@"%@ restored",transaction.transactionIdentifier) ;
            [IapUtil askCheckReceiptApiComplete:^(BOOL success, long long tick) {
                [self dealRecieptTransaction:transaction expireTick:tick complete:success] ;
            }] ;
        }
        else if (transaction.transactionState == SKPaymentTransactionStatePurchasing) {
            [[OctMBPHud sharedInstance] hide] ;
            NSLog(@"%@ purchasing",transaction.transactionIdentifier) ;
        }
        else if (transaction.transactionState == SKPaymentTransactionStateDeferred) {
            NSLog(@"%@ deferred",transaction.transactionIdentifier) ;
        }
        else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            NSLog(@"%@ failed",transaction.transactionIdentifier) ;
            DLogERR(@"订阅失败error : %@", transaction.error) ;
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction] ;
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
 
