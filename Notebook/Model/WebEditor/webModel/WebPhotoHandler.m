//
//  WebPhotoHandler.m
//  Notebook
//
//  Created by teason23 on 2019/6/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "WebPhotoHandler.h"

@implementation WebPhotoHandler

@end


@implementation WebPhoto

+ (NSDictionary *)modelPropertiesSqliteKeywords {
    return @{@"localPath":@"UNIQUE"} ;
}

@end
