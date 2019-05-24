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

static const int kSizeH1 = 30 ;
static const int kSizeH2 = 28 ;
static const int kSizeH3 = 26 ;
static const int kSizeH4 = 24 ;
static const int kSizeH5 = 22 ;
static const int kSizeH6 = 20 ;


NS_ASSUME_NONNULL_BEGIN

@interface MDHeadModel : MarkdownModel

+ (void)makeHeaderWithSize:(NSString *)mark
                    editor:(MarkdownEditor *)editor ;



+ (int)keyboardEnterTypedInTextView:(MarkdownEditor *)textView
                    modelInPosition:(MarkdownModel *)aModel
            shouldChangeTextInRange:(NSRange)range ;

@end

NS_ASSUME_NONNULL_END
