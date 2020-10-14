//
//  LaunchingEvents.h
//  Notebook
//
//  Created by teason23 on 2019/4/11.
//  Copyright © 2019 teason23. All rights reserved.
//


#define OCTUPUS_DB_Location_Dev         XT_LIBRARY_PATH_TRAIL_(@"noteDB")
#define OCTUPUS_DB_Location             XT_LIBRARY_PATH_TRAIL_(@"noteDB_product")


#import <Foundation/Foundation.h>


extern NSString *const kNotificationSyncCompleteAllPageRefresh ;
extern NSString *const kFirstTimeLaunch ;
extern NSString *const kNotificationImportFileIn ;

static NSString *const kUD_OCT_PullAll_Done = @"kUD_OCT_PullAll_Done" ;

@class UIApplication, AppDelegate, SceneDelegate;



@interface LaunchingEvents : NSObject 
@property (strong, nonatomic) OctWebEditor *webEditor;
+ (instancetype)currentEvents;


- (void)setup:(UIWindow *)window scenceDelegate:(SceneDelegate *)sDelegate ;

- (void)icloudSync:(void(^)(void))completeBlk ;
- (void)pullAll ;
- (void)pullAllComplete:(void(^)(void))completion ;

- (void)pullOrSync ;


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *,id> *)options ;
@end


