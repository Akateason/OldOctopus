//
//  MarkdownModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownModel.h"

@implementation MarkdownModel

- (instancetype)initWithType:(MarkdownSyntaxType)type
                       range:(NSRange)range
                         str:(NSString *)str {
    self = [super init];
    if (self) {
        _type = type;
        _range = range;
        _str = str ;
    }
    return self;
}

+ (instancetype)modelWithType:(MarkdownSyntaxType)type
                        range:(NSRange)range
                          str:(NSString *)str {
    return [[self alloc] initWithType:type range:range str:str] ;
}



- (NSString *)displayStringForLeftLabel {
    return @"" ;
}

- (NSMutableAttributedString *)addForAttributeString:(NSMutableAttributedString *)attributedString
                                              config:(MDThemeConfiguration *)configuration {
    
//    NSDictionary *resultDic = configuration.basicStyle ;
//    UIFont *paragraphFont = configuration.font ;
//    NSUInteger location = self.range.location ;
//    NSUInteger length = self.range.length ;
    
    return attributedString ;
}

@end
