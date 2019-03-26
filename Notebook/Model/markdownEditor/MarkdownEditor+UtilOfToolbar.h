//
//  MarkdownEditor+UtilOfToolbar.h
//  Notebook
//
//  Created by teason23 on 2019/3/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownEditor.h"
#import <XTlib/XTlib.h>
#import "MDToolbar.h"
@class MarkdownModel ;

NS_ASSUME_NONNULL_BEGIN

@interface MarkdownEditor (UtilOfToolbar) <MDToolbarDelegate>
- (MarkdownModel *)cleanMarkOfParagraph ;


@end

NS_ASSUME_NONNULL_END
