//
//  UnsplashRequest.m
//  Notebook
//
//  Created by teason23 on 2019/9/24.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "UnsplashRequest.h"
#import "UnsplashPhoto.h"

static NSString *const kAccessToken_unsplash = @"Client-ID a7eee99fade2de33b35293e74baa6fe6d79c45445d0e2d9938c8ecf5676e1ed6" ;
static NSString *const kBaseUrl_unsplash = @"https://api.unsplash.com/" ;


@implementation UnsplashRequest

+ (void)photos:(void(^)(NSArray *list))result {
    NSString *url = STR_FORMAT(@"%@photos",kBaseUrl_unsplash) ;
    [XTRequest reqWithUrl:url mode:(XTRequestMode_GET_MODE) header:self.defaultHeader parameters:nil rawBody:nil hud:NO success:^(id json, NSURLResponse *response) {
        
        NSArray *list = [NSArray yy_modelArrayWithClass:UnsplashPhoto.class json:json] ;
        result(list) ;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        result(nil) ;
    }] ;
}

+ (void)search:(NSString *)text
          page:(NSInteger)page
         count:(NSInteger)count
        result:(void(^)(NSArray *list))result {
    NSString *url = STR_FORMAT(@"%@search/photos",kBaseUrl_unsplash) ;
    NSDictionary *param = @{@"query":text,
                            @"page":@(page),
                            @"per_page":@(count),
                            } ;
    [XTRequest reqWithUrl:url mode:(XTRequestMode_GET_MODE) header:self.defaultHeader parameters:param rawBody:nil hud:NO success:^(id json, NSURLResponse *response) {
        NSArray *list = [NSArray yy_modelArrayWithClass:UnsplashPhoto.class json:json] ;
        result(list) ;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        result(nil) ;
    }] ;
}

+ (void)trackDownload:(NSString *)photoID {
    NSString *url = STR_FORMAT(@"%@photos/%@/download",kBaseUrl_unsplash,photoID) ;
    
    [XTRequest reqWithUrl:url mode:(XTRequestMode_GET_MODE) header:self.defaultHeader parameters:nil rawBody:nil hud:NO completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        
    }] ;
}

+ (NSDictionary *)defaultHeader {
    return @{@"Authorization":kAccessToken_unsplash} ;
}



@end
