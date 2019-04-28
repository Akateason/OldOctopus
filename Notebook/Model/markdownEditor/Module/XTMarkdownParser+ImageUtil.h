//
//  XTMarkdownParser+ImageUtil.h
//  Notebook
//
//  Created by teason23 on 2019/4/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTMarkdownParser.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTMarkdownParser (ImageUtil)

// get attachment
- (NSTextAttachment *)attachmentStandardFromImage:(UIImage *)image ;

// do when editor launch . (insert img placeholder)
- (NSMutableAttributedString *)readArticleFirstTimeAndInsertImagePHWhenEditorDidLaunching:(NSString *)text
                                                                                 textView:(UITextView *)textView ;

// in parse time . update image or download image.
- (NSMutableAttributedString *)updateImages:(NSString *)text
                                   textView:(UITextView *)textView ;


@end

NS_ASSUME_NONNULL_END
