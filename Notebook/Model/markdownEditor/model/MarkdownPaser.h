//
//  MarkdownPaser.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MarkdownModel.h"

extern NSRegularExpression* NSRegularExpressionFromMarkdownSyntaxType(MarkdownSyntaxType v);
extern NSDictionary* AttributesFromMarkdownSyntaxType(MarkdownSyntaxType v);
extern NSDictionary* Md_defaultStyle(void) ;


NS_ASSUME_NONNULL_BEGIN

@interface MarkdownPaser : NSObject
- (NSArray *)syntaxModelsForText:(NSString *) text;

@end

NS_ASSUME_NONNULL_END
