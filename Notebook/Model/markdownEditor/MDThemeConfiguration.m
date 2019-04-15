//
//  MDThemeConfiguration.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDThemeConfiguration.h"
#import <XTlib/XTlib.h>

static NSString *const kUDIdentiferOfTheme = @"MDThemeConfiguration_UD_id" ;

@interface MDThemeConfiguration ()

@end

@implementation MDThemeConfiguration

XT_SINGLETON_M(MDThemeConfiguration)

- (void)setup {
    NSString *theme = XT_USERDEFAULT_GET_VAL(kUDIdentiferOfTheme) ;
    [self changeTheme:theme?:@"themeDefault"] ;
}

- (void)changeTheme:(NSString *)theme {
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:theme ofType:@"json"] ;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    self.dicForConfig = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    self.editorThemeObj = nil ;
    [self editorThemeObj] ;
    
    [self setStatusBarBlackOrWhite:[self.dicForConfig[@"statusBarIsWhite"] boolValue]] ;
    self.navBarColor = UIColorHex(self.dicForConfig[@"navBarColor"]) ;
    self.navTextColor = UIColorHex(self.dicForConfig[@"navTextColor"]) ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForThemeColorDidChanged object:nil] ;
}

- (void)setStatusBarBlackOrWhite:(BOOL)isWhite {
    [UIApplication sharedApplication].statusBarStyle = isWhite ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault ;
}

- (NSDictionary *)dicForConfig {
    if (!_dicForConfig) {
        NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"themeDefault" ofType:@"json"] ;
        NSData *data = [[NSData alloc] initWithContentsOfFile:path] ;
        _dicForConfig = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] ;
    }
    return _dicForConfig ;
}

- (MDEditorTheme *)editorThemeObj {
    if (!_editorThemeObj) {
        _editorThemeObj = [MDEditorTheme new] ;
    }
    return _editorThemeObj ;
}

@end
