//
//  MDThemeConfiguration.h
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <XTlib/XTlib.h>

static const int kDefaultFontSize = 16 ;

NS_ASSUME_NONNULL_BEGIN

@interface MDThemeConfiguration : NSObject
XT_SINGLETON_H(MDThemeConfiguration)

// editor
@property (strong, nonatomic)   UIFont          *font ;
@property (nonatomic)           int             fontSize ;
@property (strong, nonatomic)   UIFont          *boldFont ;
@property (strong, nonatomic)   UIFont          *italicFont ;
@property (strong, nonatomic)   UIFont          *boldItalicFont ;
@property (copy, nonatomic)     NSDictionary *basicStyle ;
@property (copy, nonatomic)     NSDictionary *quoteStyle ;
@property (copy, nonatomic)     NSDictionary *markStyle ;
@property (copy, nonatomic)     NSDictionary *invisibleMarkStyle ;


@property (strong, nonatomic) UIColor *textColor ;
@property (strong, nonatomic) UIColor *markColor ;
@property (strong, nonatomic) UIColor *seplineLineColor ;
@property (strong, nonatomic) NSDictionary *codeBlockStyle ;

@property (strong, nonatomic) UIColor *inlineCodeBGColor ;
@property (strong, nonatomic) UIColor *quoteTextColor ;
@property (strong, nonatomic) UIColor *quoteLeftBarColor ;
@property (strong, nonatomic) UIColor *imagePlaceHolderColor ;

// skin
@property (strong, nonatomic) UIColor *themeColor ;
@property (strong, nonatomic) UIColor *homeTitleTextColor ;
@property (strong, nonatomic) UIColor *darkTextColor ;
@property (strong, nonatomic) UIColor *lightTextColor ;
@property (strong, nonatomic) UIColor *normalTextColor ;
@property (strong, nonatomic) UIColor *homeTableBGColor ;

@end

NS_ASSUME_NONNULL_END
