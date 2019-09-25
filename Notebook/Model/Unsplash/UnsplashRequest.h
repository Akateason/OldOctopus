//
//  UnsplashRequest.h
//  Notebook
//
//  Created by teason23 on 2019/9/24.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnsplashRequest : NSObject


+ (void)photos:(void(^)(NSArray *list))result ;

+ (void)search:(NSString *)text
          page:(NSInteger)page
         count:(NSInteger)count
        result:(void(^)(NSArray *list))result ;

+ (void)trackDownload:(NSString *)photoID ;


@end

NS_ASSUME_NONNULL_END
