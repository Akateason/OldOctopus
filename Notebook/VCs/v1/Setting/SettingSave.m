//
//  SettingSave.m
//  Notebook
//
//  Created by teason23 on 2019/6/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SettingSave.h"
#import <XTlib/XTlib.h>

static NSString *const kUD_SettingSave_KEY = @"kUD_SettingSave_KEY_v2" ;

@implementation SettingSave

- (void)save {
    NSString *json = [self yy_modelToJSONString] ;
    XT_USERDEFAULT_SET_VAL(json, kUD_SettingSave_KEY) ;
}

+ (instancetype)fetch {
    NSString *json = XT_USERDEFAULT_GET_VAL(kUD_SettingSave_KEY) ;
    SettingSave *sSave = [SettingSave yy_modelWithJSON:json] ;
    if (!sSave) {
        SettingSave *save = [[SettingSave alloc] init] ;
        save.sort_isNoteUpdateTime = FALSE ;
        save.sort_isBookUpdateTime = TRUE ;
        save.sort_isNewestFirst = TRUE ;
        
        save.editor_autoAddBracket = TRUE ;
        save.editor_lightHeightRate = 1.7 ;
        save.editor_md_ulistSymbol = @"-" ;
        save.editor_isLooseList = TRUE ;
        save.theme_isChangeWithSystemDarkmode = TRUE ;
        
        save.animate_duration = 0 ;
        save.animate_isSpring = FALSE ;
        
        sSave = save ;
    }
    return sSave ;
}

- (CGFloat)currentAnimationDuration {
    CGFloat duration = 0.2 ;
    switch (self.animate_duration) {
        case -1: duration = 0.5 ; break;
        case  0: duration = 0.2 ; break;
        case  1: duration = 0.1 ; break;
    }

    return duration ;
}

@end
