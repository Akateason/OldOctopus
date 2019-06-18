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

//file:///private/var/mobile/Containers/Data/Application/929D7113-DCE0-4F39-9436-D85BFD644DC6/Documents/Inbox/%E7%BC%96%E8%BE%91%E5%99%A8%E4%BA%A4%E4%BA%92%E8%AE%BE%E8%AE%A1.md
//导入文件,默认导入到当前的笔记本,如果是最近或者垃圾桶,进入暂存区. 导入之后打开此笔记.

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if (url != nil && [url isFileURL]) {
//        if (self.window.rootViewController && [self.window.rootViewController isKindOfClass:[ViewController class]]) {
//            ViewController *VC = (ViewController *)self.window.rootViewController;
//            [VC handleDocumentOpenURL:url];  //handleDocumentOpenURL:公有方法
//        }
        [[NSNotificationCenter defaultCenter] postNotificationName:<#(nonnull NSNotificationName)#> object:<#(nullable id)#>]
        Note *aNote = [[Note alloc] initWithBookID:<#(NSString *)#> content:<#(NSString *)#> title:<#(NSString *)#>]
        
        
    }
    return YES;
}


////是否支持屏幕旋转
//- (BOOL)shouldAutorotate {
//    if (IS_IPAD) {
//        return YES ;
//    }
//    return NO ;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    if (IS_IPAD) {
//        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight ;
//    }
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)nowWindow {
//    if (IS_IPAD) {
//        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight ;
//    }
//    return UIInterfaceOrientationMaskPortrait;
//}

@end
