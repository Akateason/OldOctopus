//
//  MarkdownEditor.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkdownPaser.h"

extern NSString *const  kNOTIFICATION_NAME_EDITOR_DID_CHANGE ;
extern const CGFloat    kMDEditor_FlexValue ;



@interface MarkdownEditor : UITextView <UITextViewDelegate> {
    BOOL    fstTimeLoaded ;
    CGFloat keyboardHeight ;
}
@property (strong, nonatomic) MarkdownPaser *markdownPaser ; // paser with configuration .

- (void)doSomethingWhenUserSelectPartOfArticle:(MarkdownModel *)model ;

- (void)parseTextThenRenderLeftSideAndToobar ;

- (void)setTopOffset:(CGFloat)topOffset ;

@end


