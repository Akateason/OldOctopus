//
//  NSObject+XTThemeColor.h
//  Notebook
//
//  Created by teason23 on 2019/4/12.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kNotificationForThemeColorDidChanged = @"kNotificationForThemeColorDidChanged" ;



@interface NSObject (XTThemeColor)
@property (copy, nonatomic) NSString *xt_theme_backgroundColor ;
@property (copy, nonatomic) NSString *xt_theme_textColor ;
@end


