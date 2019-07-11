//
//  OctRequestUtil.h
//  Notebook
//
//  Created by teason23 on 2019/7/5.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OctRequestUtil : NSObject

+ (void)getShareHtmlLink:(NSString *)html
                complete:(void (^)(NSString *urlString))completion ;

+ (void)uploadImage:(UIImage *)image
           progress:(nullable void (^)(float progress))progressValueBlock
           complete:(void (^)(NSString *urlString))completion ;


/**
 验证码 校验
 
 @param code          测试码  octopus_test_code
 @param completion
 return {count = 0;}
 */
+ (void)verifyCode:(NSString *)code
        completion:(void(^)(bool success))completion ;

@end

NS_ASSUME_NONNULL_END
