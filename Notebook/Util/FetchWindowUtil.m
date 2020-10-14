//
//  FetchWindowUtil.m
//  Notebook
//
//  Created by teason23 on 2020/10/14.
//  Copyright © 2020 teason23. All rights reserved.
//

#import "FetchWindowUtil.h"


@implementation FetchWindowUtil

+ (UIWindow *)fetchMainWindow {
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> * scenes = [[UIApplication sharedApplication] connectedScenes];
        for (UIScene *scene in scenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                SceneDelegate *sDelegate = (SceneDelegate *)((UIWindowScene *)scene.delegate);
                return sDelegate.window;
            }
        }
    } else {
        AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate) ;
        return appDelegate.window;
    }
    return nil;
}

+ (SceneDelegate *)sceneDelegate {
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> * scenes = [[UIApplication sharedApplication] connectedScenes];
        for (UIScene *scene in scenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                SceneDelegate *sDelegate = (SceneDelegate *)((UIWindowScene *)scene.delegate);
                return sDelegate;
            }
        }
    } else {
        return nil;
    }
    return nil;
}

@end
