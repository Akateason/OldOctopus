//
//  MDHeadModel.h
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkdownModel.h"
#import <XTlib/XTlib.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDHeadModel : MarkdownModel

+ (void)makeHeaderWithSize:(NSString *)mark
                    editor:(MarkdownEditor *)editor ;
    
@end

NS_ASSUME_NONNULL_END
