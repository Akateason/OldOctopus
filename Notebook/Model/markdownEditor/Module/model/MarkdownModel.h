//
//  MarkdownModel.h
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MdParserRegexpHeader.h"
#import "MDThemeConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface MarkdownModel : NSObject
@property (nonatomic) NSRange range ;
@property (nonatomic) MarkdownSyntaxType type ;
@property (copy, nonatomic) NSString *str ;


// construct
- (instancetype)initWithType:(MarkdownSyntaxType)type
                       range:(NSRange)range
                         str:(NSString *)str ;

+ (instancetype)modelWithType:(MarkdownSyntaxType)type
                        range:(NSRange)range
                          str:(NSString *)str ;

// rewrite in subcls
- (NSString *)displayStringForLeftLabel ;
- (NSMutableAttributedString *)addForAttributeString:(NSMutableAttributedString *)attributedString
                                              config:(MDThemeConfiguration *)configuration ;

@end

NS_ASSUME_NONNULL_END
