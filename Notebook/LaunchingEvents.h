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

@class UIApplication, AppDelegate ;



@interface LaunchingEvents : NSObject 
@property (strong, nonatomic) AppDelegate *appDelegate ;
- (void)setup:(UIApplication *)application appdelegate:(AppDelegate *)appDelegate ;
- (void)icloudSync:(void(^)(void))completeBlk ;
- (void)pullAll ;

- (void)setupAlbumn ;

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *,id> *)options ;
@end


