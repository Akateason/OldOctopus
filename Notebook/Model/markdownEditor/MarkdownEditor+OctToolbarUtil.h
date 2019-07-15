//
//  MarkdownEditor+OctToolbarUtil.h
//  Notebook
//
//  Created by teason23 on 2019/5/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownEditor.h"
#import <XTlib/XTlib.h>
#import "OctToolbar.h"


NS_ASSUME_NONNULL_BEGIN

@interface MarkdownEditor (OctToolbarUtil) <OctToolbarDelegate>

- (MarkdownModel *)cleanMarkOfParagraph ;
- (MarkdownModel *)lastOneParagraphMarkdownModel ;
- (MarkdownModel *)lastOneParagraphMarkdownModelWithPosition:(NSUInteger)position ;


@end

NS_ASSUME_NONNULL_END
