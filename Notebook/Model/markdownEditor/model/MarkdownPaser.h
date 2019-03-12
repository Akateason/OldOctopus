//
//  MarkdownPaser.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MarkdownModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MarkdownPaser : NSObject
@property (copy, nonatomic) NSArray *currentPaserResultList ;

- (UIFont *)defaultFont ;
- (NSDictionary *)defaultStyle ;
- (NSRegularExpression *)getRegularExpressionFromMarkdownSyntaxType:(MarkdownSyntaxType)v ;
- (NSDictionary *)attributesFromMarkdownSyntaxModel:(MarkdownModel *)model ;


- (NSArray *)syntaxModelsForText:(NSString *)text ;
- (MarkdownModel *)modelForRangePosition:(NSUInteger)position ;
+ (NSString *)stringTitleOfModel:(MarkdownModel *)model ;

@end

NS_ASSUME_NONNULL_END
