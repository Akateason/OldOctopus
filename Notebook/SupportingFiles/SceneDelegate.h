//
//  SceneDelegate.h
//  Notebook
//
//  Created by teason23 on 2020/10/14.
//  Copyright © 2020 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaunchingEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LaunchingEvents *launchingEvents;
@end

NS_ASSUME_NONNULL_END
