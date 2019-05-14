//
//  MDEditorTheme.h
//  Notebook
//
//  Created by teason23 on 2019/4/12.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static const int kDefaultFontSize = 16 ;

NS_ASSUME_NONNULL_BEGIN

@interface MDEditorTheme : NSObject

@property (strong, nonatomic)   UIFont          *font ;
@property (nonatomic)           int             fontSize ;
@property (strong, nonatomic)   UIFont          *boldFont ;
@property (strong, nonatomic)   UIFont          *italicFont ;
@property (strong, nonatomic)   UIFont          *boldItalicFont ;

@property (copy, nonatomic)     NSDictionary    *basicStyle ;
+ (NSDictionary *)basicStyleWithParaSpacing:(float)paraSpacing ;

@property (copy, nonatomic)     NSDictionary    *markStyle ;
@property (copy, nonatomic)     NSDictionary    *invisibleMarkStyle ;

@property (copy, nonatomic)     NSDictionary    *quoteStyle ;
@property (copy, nonatomic)     NSDictionary    *listInvisibleMarkStyle ;
@property (strong, nonatomic)   NSDictionary    *codeBlockStyle ;

@property (nonatomic)           float           inlineCodeSideFlex ;

@end

NS_ASSUME_NONNULL_END
