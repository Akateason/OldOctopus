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

@interface AppDelegate ()
// <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (void)test {
//    NSString *jsonlist = @"[\"h3\"]" ;
//    NSArray *list = [self.class convertjsonStringToDict:jsonlist] ;
//    NSArray *list = [NSArray yy_modelArrayWithClass:[NSString class] json:jsonlist] ;
    
}





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.launchingEvents = [[LaunchingEvents alloc] init] ;
    [self.launchingEvents setup:application appdelegate:self] ;
    
    [self test] ;
    return YES;
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

- (void)applicationDidBecomeActive:(UIApplication *)application{
    if (![XTIcloudUser userInCacheSyncGet]) {
        [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser *user) {
            [self.launchingEvents pullAll] ;
        }] ;
    }
}


//是否支持屏幕旋转
- (BOOL)shouldAutorotate {
    if (IS_IPAD) {
        return YES ;
    }
    return NO ;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (IS_IPAD) {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight ;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)nowWindow {
    if (IS_IPAD) {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight ;
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
