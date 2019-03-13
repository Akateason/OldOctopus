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




@interface AppDelegate ()

@end


@implementation AppDelegate


- (void)test {
    
    
    
//    XTCloudHandler *handle = [[XTCloudHandler alloc] init];
    //    [handle iCloudStatus] ;

    //    [handle fetchUser] ;

    //    [handle insert] ;

    //    CKRecordID *recId = [[CKRecordID alloc] initWithRecordName:@"11111"];
    //    CKRecord *rec = [[CKRecord alloc] initWithRecordType:@"TestTargetRefObj" recordID:recId];
    //    [rec setObject:@"嘻嘻" forKey:@"name"];
    //    [handle insert:rec] ;
    //
    //    recId = [[CKRecordID alloc] initWithRecordName:@"11112"];
    //    rec = [[CKRecord alloc] initWithRecordType:@"TestTargetRefObj" recordID:recId];
    //    [rec setObject:@"哈哈" forKey:@"name"];
    //    [handle insert:rec] ;

    //    [handle setReferenceWithReferenceKey:@"book" andSourceRecordID:@"abcxtc" andTargetRecordID:@"11111"] ;

    //    [handle searchReferWithRefID:rec.recordID sourceType:@"Test"] ;


    //    [handle fetchWithId:@"abcxtc"] ;

    //    [handle fetchListWithTypeName:@"Test"] ;

    //    [handle updateWithRecId:@"abcxtc"] ;

    //    [handle deleteWithId:@"abcxtc"] ;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [XTlibConfig sharedInstance].isDebug    = YES;
    [XTFMDBBase sharedInstance].isDebugMode = YES;

    [[XTFMDBBase sharedInstance] configureDBWithPath:XT_DOCUMENTS_PATH_TRAIL_(@"noteDB")];

    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable             = YES; // 控制整个功能是否启用。
    manager.enableAutoToolbar  = NO;  // 控制是否显示键盘上的工具条


        [self test] ;

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
