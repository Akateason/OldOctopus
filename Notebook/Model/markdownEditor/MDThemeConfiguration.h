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

#define XT_MAKE_theme_color(_key_,_a_)           [[_key_ stringByAppendingString:@","] stringByAppendingString:@(_a_).stringValue]


#define XT_MD_THEME_COLOR_KEY(__key__)           [[MDThemeConfiguration sharedInstance] colorWithThemeKey:__key__]
#define XT_MD_THEME_COLOR_KEY_A(__key__,__a__)   [[MDThemeConfiguration sharedInstance] colorWithThemeKey:__key__ alpha:__a__]





@interface MDThemeConfiguration : NSObject
XT_SINGLETON_H(MDThemeConfiguration)

- (void)changeTheme:(NSString *)theme ;

@property (strong, nonatomic)   MDEditorTheme   *editorThemeObj ;
@property (copy,   nonatomic)   NSDictionary    *dicForColors ;

- (UIColor *)colorWithThemeKey:(NSString *)key alpha:(float)alpha ;
- (UIColor *)colorWithThemeKey:(NSString *)key ;
@end


