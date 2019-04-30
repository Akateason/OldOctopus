//
//  MarkdownModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownModel.h"
#import <XTlib/XTlib.h>

@implementation MarkdownModel

- (instancetype)initWithType:(int)type
                       range:(NSRange)range
                         str:(NSString *)str {
    self = [super init];
    if (self) {
        _type   = type;
        _range  = range;
        _str    = str ;
    }
    return self;
}

+ (instancetype)modelWithType:(int)type
                        range:(NSRange)range
                          str:(NSString *)str {
    return [[self alloc] initWithType:type
                                range:range
                                  str:str] ;
}

- (NSString *)displayStringForLeftLabel {
    return @"" ;
}

- (NSUInteger)location {
    return self.range.location ;
}

- (NSUInteger)length {
    return self.range.length ;
}

- (UIFont *)defaultFont {
    return [MDThemeConfiguration sharedInstance].editorThemeObj.font ;
}

- (NSDictionary *)defultStyle {
    return MDThemeConfiguration.sharedInstance.editorThemeObj.basicStyle ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString
                                              {
    if (self.type == -1) { // paragraph
        NSDictionary *resultDic = @{NSBackgroundColorAttributeName : [[XTColorFetcher sharedInstance] randomColor]} ;
        [attributedString addAttributes:resultDic range:self.range] ;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition {
    return attributedString ;
}

@end
