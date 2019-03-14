//
//  MDThemeConfiguration.h
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface MDThemeConfiguration : NSObject

@property (strong, nonatomic) UIFont *font ;
@property (nonatomic) int fontSize ;
@property (strong, nonatomic) UIFont *boldFont ;
@property (strong, nonatomic) UIFont *italicFont ;
@property (strong, nonatomic) UIFont *boldItalicFont ;
@property (copy, nonatomic) NSDictionary *basicStyle ;
@property (copy, nonatomic) NSDictionary *markStyle ;

@property (strong, nonatomic) UIColor *textColor ;
@property (strong, nonatomic) UIColor *markColor ;
@property (strong, nonatomic) UIColor *codeTextBGColor ;
@property (strong, nonatomic) UIColor *quoteTextColor ;

@end

NS_ASSUME_NONNULL_END
