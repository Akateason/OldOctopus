//
//  MDImageManager.m
//  Notebook
//
//  Created by teason23 on 2019/3/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDImageManager.h"
#import <SDWebImage/SDWebImageManager.h>
#import <XTReq/XTReq.h>
#import "XTCloudHandler.h"

@interface MDImageManager ()

@end

@implementation MDImageManager
XT_SINGLETON_M(MDImageManager)

- (UIImage *)imagePlaceHolder {
    return [UIImage imageNamed:@"test"] ;
}

- (void)imageWithUrlStr:(NSString *)urlStr
               complete:(void(^)(UIImage *image))complete {
    
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:urlStr] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (!error) {
            complete(image) ;
        }
    }] ;
}




/**
 action: 'https://shimodev.com/octopus-api/files',
 headers: {
 Authorization: `Basic ${Base64.encode(userRecordName + ':' + '123456')}`
 }
 */
- (void)uploadImage:(UIImage *)image
           progress:(nullable void (^)(float))progressValueBlock
            success:(void (^)(NSURLResponse *response, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))fail {

//    NSString *url = @"https://shimodev.com/octopus-api/files" ;
    NSString *url = @"https://172.17.4.66:3000/octopus-api/files" ;
    NSData *data = UIImageJPEGRepresentation(image, 1) ;
    
    NSString *strToEnc = STR_FORMAT(@"%@:123456",[XTIcloudUser userInCacheSyncGet].userRecordName) ;
    NSString *code = STR_FORMAT(@"Basic %@",[strToEnc base64EncodedString]) ;
    NSDictionary *header = @{@"Authorization" : code} ;
    
    [XTRequest uploadFileWithData:data urlStr:url header:header progress:^(float flt) {

    } success:^(NSURLResponse *response, id responseObject) {

    } failure:^(NSURLSessionDataTask *task, NSError *error) {


    }] ;
    
    
}

@end
