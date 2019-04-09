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


@class MarkdownEditor ;

NS_ASSUME_NONNULL_BEGIN

@interface MarkdownModel : NSObject
@property (nonatomic) NSRange               range ;
@property (nonatomic) NSUInteger            type ;  // synax type or inline type
@property (copy, nonatomic) NSString        *str ;
@property (nonatomic) BOOL                  isOnEditState ; // yes - edit, no - preview  . state for display


// construct
- (instancetype)initWithType:(NSUInteger)type
                       range:(NSRange)range
                         str:(NSString *)str ;

+ (instancetype)modelWithType:(NSUInteger)type
                        range:(NSRange)range
                          str:(NSString *)str ;

// ********* rewrite in subcls ********* //

- (NSString *)displayStringForLeftLabel ;

// RENDER preview state
- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString
                                              config:(MDThemeConfiguration *)configuration ;

// RENDER edit state
- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                           config:(MDThemeConfiguration *)configuration ;

// ********* rewrite in subcls ********* //

@end

NS_ASSUME_NONNULL_END
