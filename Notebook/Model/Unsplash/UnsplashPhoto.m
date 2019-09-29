//
//  UnsplashPhoto.m
//  Notebook
//
//  Created by teason23 on 2019/9/24.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "UnsplashPhoto.h"

@implementation UnsplashPhoto

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"photoId" : @"id", } ;
}

// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    _url_reqular = dic[@"urls"][@"regular"];
    _url_small = dic[@"urls"][@"small"];
    _url_thumb = dic[@"urls"][@"thumb"];
    _userName = dic[@"user"][@"username"];
    
    if (!_alt_description) _alt_description = @"" ;
    
    return YES;
}


@end
