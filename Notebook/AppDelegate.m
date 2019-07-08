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


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)test {
//    NSString *jsonlist = @"[\"h3\"]" ;
//    NSArray *list = [self.class convertjsonStringToDict:jsonlist] ;
//    NSArray *list = [NSArray yy_modelArrayWithClass:[NSString class] json:jsonlist] ;
    
//    OctGuidingVC *guidVC = [OctGuidingVC getMe] ;
//    self.window.rootViewController = guidVC ;
//    [self.window makeKeyAndVisible] ;

    
}





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.launchingEvents = [[LaunchingEvents alloc] init] ;
    [self.launchingEvents setup:application appdelegate:self] ;

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
