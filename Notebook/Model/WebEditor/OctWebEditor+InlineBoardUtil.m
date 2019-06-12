//
//  OctWebEditor+InlineBoardUtil.m
//  Notebook
//
//  Created by teason23 on 2019/6/4.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor+InlineBoardUtil.h"
#import "MdParserRegexpHeader.h"

@implementation OctWebEditor (InlineBoardUtil)

- (void)toolbarDidSelectClearToCleanPara {
    [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectH1 {
    if (self.typePara == MarkdownSyntaxH1) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(BOOL isComplete) {
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"1" completion:^(BOOL isComplete) {
        }] ;
    }
}

- (void)toolbarDidSelectH2 {
    if (self.typePara == MarkdownSyntaxH2) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(BOOL isComplete) {
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"2" completion:^(BOOL isComplete) {
        }] ;
    }
}

- (void)toolbarDidSelectH3 {
    if (self.typePara == MarkdownSyntaxH3) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(BOOL isComplete) {
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"3" completion:^(BOOL isComplete) {
        }] ;
    }
}

- (void)toolbarDidSelectH4 {
    if (self.typePara == MarkdownSyntaxH4) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(BOOL isComplete) {
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"4" completion:^(BOOL isComplete) {
        }] ;
    }
}

- (void)toolbarDidSelectH5 {
    if (self.typePara == MarkdownSyntaxH5) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(BOOL isComplete) {
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"5" completion:^(BOOL isComplete) {
        }] ;
    }
}

- (void)toolbarDidSelectH6 {
    if (self.typePara == MarkdownSyntaxH6) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(BOOL isComplete) {
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"6" completion:^(BOOL isComplete) {
        }] ;
    }
}

- (void)toolbarDidSelectBold {
    [self nativeCallJSWithFunc:@"bold" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectItalic {
    [self nativeCallJSWithFunc:@"italic" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectDeletion {
    [self nativeCallJSWithFunc:@"deletionLine" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectInlineCode {
    [self nativeCallJSWithFunc:@"inlineCode" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectLink {
    [self nativeCallJSWithFunc:@"addLink" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectUnderline {
    [self nativeCallJSWithFunc:@"underline" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

@end