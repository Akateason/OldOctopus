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
@class MarkdownModel,MDEKeyboardPhotoView ;

NS_ASSUME_NONNULL_BEGIN

@interface MarkdownEditor (UtilOfToolbar) <MDToolbarDelegate>

@property (strong, nonatomic) MDEKeyboardPhotoView *photoView ;

- (MarkdownModel *)cleanMarkOfParagraph ;
- (MarkdownModel *)lastOneParagraphMarkdownModel ;
- (MarkdownModel *)lastOneParagraphMarkdownModelWithPosition:(NSUInteger)position ;

@end

NS_ASSUME_NONNULL_END
