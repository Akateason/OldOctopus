//
//  MDImageManager.h
//  Notebook
//
//  Created by teason23 on 2019/3/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <XTlib/XTlib.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDImageManager : NSObject
XT_SINGLETON_H(MDImageManager)

- (UIImage *)imagePlaceHolder ;

- (void)imageWithUrlStr:(NSString *)urlStr
               complete:(void(^)(UIImage *image))complete ;


- (void)uploadImage:(UIImage *)image
           progress:(nullable void (^)(float))progressValueBlock
            success:(void (^)(NSURLResponse *response, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))fail ;

@end

NS_ASSUME_NONNULL_END
