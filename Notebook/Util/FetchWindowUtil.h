//
//  FetchWindowUtil.h
//  Notebook
//
//  Created by teason23 on 2020/10/14.
//  Copyright © 2020 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SceneDelegate.h"


NS_ASSUME_NONNULL_BEGIN

@interface FetchWindowUtil : NSObject

+ (UIWindow *)fetchMainWindow;

+ (SceneDelegate *)sceneDelegate;

@end

NS_ASSUME_NONNULL_END
