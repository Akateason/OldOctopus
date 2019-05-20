//
//  LaunchingEvents.h
//  Notebook
//
//  Created by teason23 on 2019/4/11.
//  Copyright © 2019 teason23. All rights reserved.
//


#define OCTUPUS_DB_Location         XT_LIBRARY_PATH_TRAIL_(@"noteDB")


#import <Foundation/Foundation.h>

extern NSString *const kNotificationSyncCompleteAllPageRefresh ;
extern NSString *const kFirstTimeLaunch ;

@class UIApplication, AppDelegate ;



@interface LaunchingEvents : NSObject
@property (strong, nonatomic) AppDelegate *appDelegate ;

- (void)setup:(UIApplication *)application
  appdelegate:(AppDelegate *)appDelegate ;

- (void)setupRemoteNotification:(UIApplication *)application ;

- (void)setupDB ;

- (void)setupNaviStyle ;

- (void)setupIqKeyboard ;

- (void)setupIcloudEvent ;

- (void)pullOrSync ;

- (void)createDefaultBookAndNotes ;

- (void)icloudSync:(void(^)(void))completeBlk ;

- (void)uploadAllLocalDataIfNotUploaded ;

@end


