//
//  OCRUtil.m
//  Notebook
//
//  Created by teason23 on 2019/12/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OCRUtil.h"

@implementation OCRUtil

+ (NSString *)parseResult:(id)result {
    NSMutableString *message = [NSMutableString string] ;
    
    if(result[@"words_result"]){
        if([result[@"words_result"] isKindOfClass:[NSDictionary class]]){
            [result[@"words_result"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                    [message appendFormat:@"%@: %@\n", key, obj[@"words"]];
                }
                else{
                    [message appendFormat:@"%@: %@\n", key, obj];
                }
            }];
        }
        else if([result[@"words_result"] isKindOfClass:[NSArray class]]){
            for(NSDictionary *obj in result[@"words_result"]){
                if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                    [message appendFormat:@"%@\n", obj[@"words"]];
                }
                else{
                    [message appendFormat:@"%@\n", obj];
                }
            }
        }
        
    }
    else{
        [message appendFormat:@"%@", result];
    }
    
    message = [message stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"].mutableCopy ;
    message = [message stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n"].mutableCopy ;
    
    return message ;
}


@end
