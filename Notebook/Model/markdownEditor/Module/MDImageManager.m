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
#import "MDThemeConfiguration.h"

@interface MDImageManager ()

@end

@implementation MDImageManager

- (UIImage *)imagePlaceHolder {        
    return [UIImage imageWithColor:XT_MD_THEME_COLOR_KEY_A(k_md_textColor, .04) size:CGSizeMake(680, 382.5)] ;
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
 https://shimodev.com/octopus-api/files?uploadType=media
 headers: {
 Authorization: `Basic ${Base64.encode(userRecordName + ':' + '123456')}`
 Content-Type:image/jpeg
 }
 */
- (void)uploadImage:(UIImage *)image
           progress:(nullable void (^)(float progress))progressValueBlock
            success:(void (^)(NSURLResponse *response, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))fail {

    NSString *url = @"https://shimodev.com/octopus-api/files?uploadType=media" ;
//    NSString *url = @"http://172.17.4.66:9001/files?uploadType=media" ;
    NSData *data = UIImageJPEGRepresentation(image, 1) ;
    
    NSString *strToEnc = STR_FORMAT(@"%@:123456",[XTIcloudUser userInCacheSyncGet].userRecordName) ;
    NSString *code = STR_FORMAT(@"Basic %@",[strToEnc base64EncodedString]) ;
    NSDictionary *header = @{@"Authorization" : code,
                             @"Content-Type":@"image/jpeg"
                             } ;
    
    [XTRequest uploadFileWithData:data urlStr:url header:header progress:^(float flt) {
        progressValueBlock(flt) ;
    } success:^(NSURLResponse *response, id responseObject) {
        success(response, responseObject) ;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        fail(task, error) ;
    }] ;    
}

@end
