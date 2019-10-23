//
//  URLProtocol.m
//  Notebook
//
//  Created by teason23 on 2019/10/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "URLProtocol.h"

static NSString * const URLProtocolHandledKey = @"URLProtocolHandledKey";


@interface URLProtocol () <NSURLConnectionDelegate>


@end

@implementation URLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
//    NSLog(@"%s %@", __func__, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
//    NSLog(@"%s %@", __func__, [request valueForHTTPHeaderField:@"field"]);
    //看看是否已经处理过了，防止无限循环
    
    if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
        return NO ;
    }
    else {
        return YES ;
    }
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSLog(@"%@",request.URL.absoluteString) ;
//    NSLog(@"%s %@", __func__, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
//    NSLog(@"%s %@", __func__, [request valueForHTTPHeaderField:@"field"]);
//    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
//    mutableReqeust = [self redirectHostInRequset:mutableReqeust];
    return request;
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if ( self ) {
        
    }
    return self;
}

- (void)startLoading {
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    
    NSString *path = [self getPicFilePath] ;
    if ([XTFileManager isFileExist:path]) {
        NSURLResponse *response = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPicURLResponsePath]] ;
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        
        NSData *dataFile = [NSData dataWithContentsOfFile:path] ;
        [self.client URLProtocol:self didLoadData:dataFile] ;
        [self.client URLProtocolDidFinishLoading:self];
        
        return ;
    }

    
    //打标签，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    

    
    @weakify(self)
    [XTRequest downLoadFileWithSavePath:[self getPicFilePath]
                          fromUrlString:self.request.URL.absoluteString
                                 header:nil
                       downLoadProgress:^(float progressVal) {

    } success:^(NSURLResponse *response, id dataFile) {
        @strongify(self)

        [NSKeyedArchiver archiveRootObject:response toFile:[self getPicURLResponsePath]];
        
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

        [self.client URLProtocol:self didLoadData:dataFile] ;

        [dataFile writeToFile:[self getPicFilePath] atomically:YES] ;
        [self.client URLProtocolDidFinishLoading:self];
        
    } failure:^(NSURLSessionDownloadTask *task, NSError *error) {
        @strongify(self)
        [self.client URLProtocol:self didFailWithError:error];

    }] ;
}

- (void)stopLoading {
//    [self.connection cancel] ;
    
//    [XTRequest cancelAllRequest] ;
}

- (NSString *)getPicFilePath {
    NSString *picUrl = self.request.URL.absoluteString ;
    picUrl = [picUrl MD5] ; // base64会带'/', 影响了folder
    picUrl = XT_DOCUMENTS_PATH_TRAIL_(XT_STR_FORMAT(@"pic/%@",picUrl)) ;
    return picUrl ;
}


- (NSString *)getPicURLResponsePath {
    return [[self getPicFilePath] stringByAppendingString:@"_urlresp"] ;
}


//#pragma mark - NSURLConnectionDelegate

//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    [self.client URLProtocol:self didFailWithError:error];
//}
//
//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
//    if (response != nil) {
//        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
//    }
//    return request;
//}
//
//- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
//    return YES;
//}
//
//- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.client URLProtocol:self didLoadData:data];
//
////    [data writeToFile:[self getPicFilePath] atomically:YES] ;
//    NSError *error ;
//    [data writeToFile:[self getPicFilePath] options:(NSDataWritingAtomic) error:&error] ;
//    if (error) NSLog(@"write err : %@",error) ;
//}
//
//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
//                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
//    return cachedResponse;
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    [self.client URLProtocolDidFinishLoading:self];
//}


@end
