//
//  OctRequestUtil.m
//  Notebook
//
//  Created by teason23 on 2019/7/5.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctRequestUtil.h"
#import "XTCloudHandler.h"
#import <XTlib/XTlib.h>

@implementation OctRequestUtil

+ (NSString *)requestLinkWithNail:(NSString *)urlNail {
    NSString *head ;
#ifdef DEBUG
    head = @"https://shimodev.com/octopus-api/" ;
#else
    head = @"https://shimo.im/octopus-api/" ;
#endif
    return [head stringByAppendingString:urlNail] ;
}

+ (void)getShareHtmlLink:(NSString *)html
                complete:(void (^)(NSString *urlString))completion {
    
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding] ;
    NSString *url = [self requestLinkWithNail:@"files?uploadType=html"] ;
//    @"https://shimo.im/octopus-api/files?uploadType=html" ;

    NSString *strToEnc = STR_FORMAT(@"%@:123456",[XTIcloudUser userInCacheSyncGet].userRecordName?:@"Default") ;
    NSString *code = STR_FORMAT(@"Basic %@",[strToEnc base64EncodedString]) ;
    NSDictionary *header = @{@"Authorization" : code} ;
    [XTRequest uploadFileWithData:data urlStr:url header:header progress:^(float flt) {
        
    } success:^(NSURLResponse *response, id responseObject) {
        NSString *url = responseObject[@"key"] ;
        if (!url) {
            // failed
            completion(nil) ;
        }
        else { // success .
            url = [[self formalLinkHead] stringByAppendingString:url] ;
            completion(url) ;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil) ;
    }] ;
}

+ (void)uploadImage:(UIImage *)image
           progress:(nullable void (^)(float progress))progressValueBlock
           complete:(void (^)(NSString *urlString))completion {
    
//    NSString *url = @"https://shimo.im/octopus-api/files?uploadType=media" ;
    NSString *url = [self requestLinkWithNail:@"files?uploadType=media"] ;
    NSData *data = UIImageJPEGRepresentation(image, 1) ;
    NSString *strToEnc = STR_FORMAT(@"%@:123456",[XTIcloudUser userInCacheSyncGet].userRecordName?:@"Default") ;
    NSString *code = STR_FORMAT(@"Basic %@",[strToEnc base64EncodedString]) ;
    NSDictionary *header = @{@"Authorization" : code,
                             @"Content-Type":@"image/jpeg"} ;
    
    [XTRequest uploadFileWithData:data urlStr:url header:header progress:^(float flt) {
        
    } success:^(NSURLResponse *response, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *url = responseObject[@"key"] ;
            if (!url) {
                // upload failed
                completion(nil) ;
            }
            else { // success .
                url = [[self formalLinkHead] stringByAppendingString:url] ;
                completion(url) ;
            }
        }) ;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil) ;
    }] ;
}

+ (NSString *)formalLinkHead {
//    return @"https://octopus.smcdn.cn/" ;
#ifdef DEBUG
    return @"https://octopus-dev.smcdn.cn/" ;
#else
    return @"https://octopus.smcdn.cn/" ;
#endif
}


/**
 验证码 校验

 @param code          测试码  octopus_test_code
 @param completion
 return {count = 0;}
 */
+ (void)verifyCode:(NSString *)code
        completion:(void(^)(bool success))completion {
    
    NSString *device = IS_IPAD ? @"ipados" : @"ios" ;
    NSString *url = [self requestLinkWithNail:XT_STR_FORMAT(@"codes/verify/%@?system=%@",code,device)] ;
    
    [XTRequest reqWithUrl:url mode:XTRequestMode_POST_MODE header:nil parameters:nil rawBody:nil hud:NO success:^(id json, NSURLResponse *response) {
        completion(YES) ;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(NO) ;
    }] ;
}


// iap expire Date . setter getter
+ (void)getIapInfo:(void(^)(long long tick, BOOL success))complete {
    if (![XTIcloudUser hasLogin]) {
        // 未登录
        return ;
    }
    
    NSString *url = [self requestLinkWithNail:@"users/subscribe"] ;
    NSString *strToEnc = STR_FORMAT(@"%@:123456",[XTIcloudUser userInCacheSyncGet].userRecordName?:@"Default") ;
    NSString *code = STR_FORMAT(@"Basic %@",[strToEnc base64EncodedString]) ;
    NSDictionary *header = @{@"Authorization" : code} ;
    
    [XTRequest reqWithUrl:url mode:XTRequestMode_GET_MODE header:header parameters:nil rawBody:nil hud:NO success:^(id json, NSURLResponse *response) {
        long long tick = [json[@"expired_at"] longLongValue] ;
//        NSLog(@"expired_at %lld",tick) ;
        complete(tick, YES) ;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        complete(0, NO) ;
    }] ;
}



/**
 setIapInfoExpireDateTick

 return
 {
 "expired_at" = 123;
 "user_id" = "_074e9bb2241e7f6cb71878cb5a543325";
 }
 */
+ (void)setIapInfoExpireDateTick:(long long)tick complete:(void(^)(BOOL success))complete {
    if (![XTIcloudUser hasLogin]) {
        // 未登录
        return ;
    }

    NSString *url = [self requestLinkWithNail:@"users/subscribe"] ;
    NSString *strToEnc = STR_FORMAT(@"%@:123456",[XTIcloudUser userInCacheSyncGet].userRecordName?:@"Default") ;
    NSString *code = STR_FORMAT(@"Basic %@",[strToEnc base64EncodedString]) ;
    NSDictionary *header = @{@"Authorization" : code,
                             @"Content-Type":@"application/json"
                             } ;
    
    NSDictionary *bodyDic = @{@"expired_at":@(tick)} ;
    NSString *bodyString = [bodyDic yy_modelToJSONString] ;
    
    [XTRequest reqWithUrl:url mode:XTRequestMode_POST_MODE header:header parameters:nil rawBody:bodyString hud:NO success:^(id json, NSURLResponse *response) {
        complete(YES) ;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        complete(NO) ;
    }] ;
}

+ (void)saveOrders:(NSString *)body complete:(void(^)(BOOL success))complete {
    if (![XTIcloudUser hasLogin]) {
        // 未登录
        return ;
    }
    
    NSString *url = [self requestLinkWithNail:@"orders"] ;
    NSString *strToEnc = STR_FORMAT(@"%@:123456",[XTIcloudUser userInCacheSyncGet].userRecordName?:@"Default") ;
    NSString *code = STR_FORMAT(@"Basic %@",[strToEnc base64EncodedString]) ;
    NSDictionary *header = @{@"Authorization" : code,
                             @"Content-Type":@"application/json"
                             } ;
    [XTRequest reqWithUrl:url mode:XTRequestMode_POST_MODE header:header parameters:nil rawBody:body hud:NO success:^(id json, NSURLResponse *response) {
        complete(YES) ;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        complete(NO) ;
    }] ;
}


@end
