//
//  LaunchingEvents.h
//  Notebook
//
//  Created by teason23 on 2019/4/11.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kNotificationSyncCompleteAllPageRefresh ;

@class UIApplication ;



@interface LaunchingEvents : NSObject

- (void)setup:(UIApplication *)application ;

- (void)setupRemoteNotification:(UIApplication *)application ;

- (void)setupDB ;

- (void)setupNaviStyle ;

- (void)setupIqKeyboard ;

- (void)setupIcloudEvent ;

- (void)pullOrSync ;

- (void)createDefaultBookAndNotes ;

- (void)icloudSync:(void(^)(void))completeBlk ;

@end


