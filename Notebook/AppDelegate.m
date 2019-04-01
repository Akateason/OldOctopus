//
//  AppDelegate.m
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "AppDelegate.h"
#import <XTlib/XTlib.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "XTCloudHandler.h"
#import "MDImageManager.h"



@interface AppDelegate ()

@end


@implementation AppDelegate


- (void)test {
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications] ;
    
    [self setupDB] ;
    [self setupNaviStyle] ;
    [self setupIqKeyboard] ;
    
    [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser * _Nonnull user) {
        NSLog(@"user : %@", [user yy_modelToJSONString]) ;
    }] ;
    
    [[XTCloudHandler sharedInstance] saveSubscription] ;
    
    [self test] ;

    return YES;
}

- (void)setupDB {
    [XTlibConfig sharedInstance].isDebug    = YES;
    [XTFMDBBase sharedInstance].isDebugMode = YES;
    [[XTFMDBBase sharedInstance] configureDBWithPath:XT_DOCUMENTS_PATH_TRAIL_(@"noteDB")];
}

- (void)setupNaviStyle {
    [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor whiteColor] ;
}

- (void)setupIqKeyboard {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable             = YES; // 控制整个功能是否启用。
    manager.enableAutoToolbar  = NO;  // 控制是否显示键盘上的工具条
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    NSString *alertBody = cloudKitNotification.alertBody;
    NSString *alertLocalizationKey = cloudKitNotification.alertLocalizationKey ;
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
        CKRecordID *recordID = [(CKQueryNotification *)cloudKitNotification recordID] ;
        // todo Update ID
        if ([alertLocalizationKey isEqualToString:@"Note_Changed"]) {
            
        }
        else if ([alertLocalizationKey isEqualToString:@"NoteBook_Changed"]) {
            
        }
    }
//    Update views or notify the user according to the record changes.
    
    
    
}


@end
