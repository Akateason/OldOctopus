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



@interface MarkdownEditor (UtilOfToolbar) <MDToolbarDelegate>

@property (strong, nonatomic) MDEKeyboardPhotoView *photoView ;

- (MarkdownModel *)cleanMarkOfParagraph ;
- (MarkdownModel *)lastOneParagraphMarkdownModel ;
- (MarkdownModel *)lastOneParagraphMarkdownModelWithPosition:(NSUInteger)position ;


@end


