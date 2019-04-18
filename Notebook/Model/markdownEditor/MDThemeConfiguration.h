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
#import "NSObject+XTThemeColor.h"
#import "MDEditorTheme.h"



static NSString *const k_md_textColor = @"textColor" ;
static NSString *const k_md_markColor = @"markColor" ;
static NSString *const k_md_seplineLineColor = @"seplineLineColor" ;
static NSString *const k_md_inlineCodeBGColor = @"inlineCodeBGColor" ;
static NSString *const k_md_quoteTextColor = @"quoteTextColor" ;
static NSString *const k_md_themeColor = @"themeColor" ;
static NSString *const k_md_homeTitleTextColor = @"homeTitleTextColor" ;
static NSString *const k_md_bgColor = @"bgColor" ;
static NSString *const k_md_blackColor = @"blackColor"  ;
static NSString *const k_md_iconColor = @"iconColor" ;
static NSString *const k_md_drawerColor = @"drawerColor" ;


#define XT_MAKE_theme_color(_key_,_a_)           [[_key_ stringByAppendingString:@","] stringByAppendingString:@(_a_).stringValue]


#define XT_MD_THEME_COLOR_KEY(__key__)           UIColorHex([MDThemeConfiguration sharedInstance].dicForConfig[__key__])
#define XT_MD_THEME_COLOR_KEY_A(__key__,__a__)   UIColorHexA([MDThemeConfiguration sharedInstance].dicForConfig[__key__], __a__)





@interface MDThemeConfiguration : NSObject
XT_SINGLETON_H(MDThemeConfiguration)

- (void)setup ;

- (void)changeTheme:(NSString *)theme ;

- (void)setStatusBarBlackOrWhite:(BOOL)isWhite ;
    
- (NSString *)currentThemeKey ;
    
@property (strong, nonatomic)   MDEditorTheme   *editorThemeObj ;
@property (copy,   nonatomic)   NSDictionary    *dicForConfig ;

@property (strong, nonatomic) UIColor *navBarColor ;
@property (strong, nonatomic) UIColor *navTextColor ;

@end


