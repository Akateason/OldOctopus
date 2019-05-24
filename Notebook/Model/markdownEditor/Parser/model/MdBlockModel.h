//
//  MdBlockModel.h
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkdownModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MdBlockModel : MarkdownModel
+ (void)toolbarEventQuoteBlock:(MarkdownEditor *)editor ;
+ (void)toolbarEventCodeBlock:(MarkdownEditor *)editor ;


+ (int)keyboardEnterTypedInTextView:(MarkdownEditor *)textView
                    modelInPosition:(MarkdownModel *)aModel
            shouldChangeTextInRange:(NSRange)range ;
@end

NS_ASSUME_NONNULL_END
