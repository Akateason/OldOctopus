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

- (instancetype)initWithType:(NSUInteger)type
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

+ (instancetype)modelWithType:(NSUInteger)type
                        range:(NSRange)range
                          str:(NSString *)str {
    return [[self alloc] initWithType:type
                                range:range
                                  str:str] ;
}

- (NSString *)displayStringForLeftLabel {
    return @"" ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString
                                              {
    NSDictionary *resultDic = MDThemeConfiguration.sharedInstance.editorThemeObj.basicStyle ;
//    UIFont *paragraphFont = configuration.font ;
//    NSUInteger location = self.range.location ;
//    NSUInteger length = self.range.length ;
    
    if (self.type == -1) { // paragraph
        resultDic = @{NSBackgroundColorAttributeName : [[XTColorFetcher sharedInstance] randomColor],} ;
        [attributedString addAttributes:resultDic range:self.range] ;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition {
    return attributedString ;
}


@end
