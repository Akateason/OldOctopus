//
//  HiddenUtil.h
//  Notebook
//
//  Created by teason23 on 2019/4/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HiddenUtil : NSObject
+ (void)showAlert ;


+ (void)switchEditorLoadWay:(BOOL)isOnline ;
+ (BOOL)getEditorLoadWay ;


+ (NSString *)developerMacLink ;
+ (void)setDeveloperMacLink:(NSString *)link ;

@end

NS_ASSUME_NONNULL_END
