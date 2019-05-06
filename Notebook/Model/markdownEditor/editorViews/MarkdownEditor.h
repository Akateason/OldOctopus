//
//  MarkdownEditor.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTMarkdownParser.h"

extern NSString *const  kNOTIFICATION_NAME_EDITOR_DID_CHANGE ;
extern const CGFloat    kMDEditor_FlexValue ;



@interface MarkdownEditor : UITextView <UITextViewDelegate> {
    BOOL    fstTimeLoaded ;
    CGFloat keyboardHeight ;
}
@property (strong, nonatomic) XTMarkdownParser *parser ; // parser with configuration .

- (void)doSomethingWhenUserSelectPartOfArticle:(MarkdownModel *)model ;

- (void)renderLeftSideAndToobar ;
- (void)parseAllTextFinishedThenRenderLeftSideAndToolbar ;

- (void)setTopOffset:(CGFloat)topOffset ;

@end


