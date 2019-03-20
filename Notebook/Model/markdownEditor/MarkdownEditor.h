//
//  MarkdownEditor.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkdownPaser.h"

NS_ASSUME_NONNULL_BEGIN

@interface MarkdownEditor : UITextView <UITextViewDelegate>
@property (strong, nonatomic) MarkdownPaser *markdownPaser ; // paser with configuration .

- (void)insertPhoto:(UIImage *)image ;

@end

NS_ASSUME_NONNULL_END
