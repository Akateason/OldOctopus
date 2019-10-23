//
//  URLProtocol.h
//  Notebook
//
//  Created by teason23 on 2019/10/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface URLProtocol : NSURLProtocol

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client;

@end

NS_ASSUME_NONNULL_END
