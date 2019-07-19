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
    [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectH1 {
    if ([self typeBlkListHasThisType:MarkdownSyntaxH1]) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"1" completion:^(NSString *val, NSError *error) {
        }] ;
    }
}

- (void)toolbarDidSelectH2 {
    if ([self typeBlkListHasThisType:MarkdownSyntaxH2]) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"2" completion:^(NSString *val, NSError *error) {
        }] ;
    }
}

- (void)toolbarDidSelectH3 {
    if ([self typeBlkListHasThisType:MarkdownSyntaxH3]) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"3" completion:^(NSString *val, NSError *error) {
        }] ;
    }
}

- (void)toolbarDidSelectH4 {
    if ([self typeBlkListHasThisType:MarkdownSyntaxH4]) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(NSString *val, NSError *error) {
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"4" completion:^(NSString *val, NSError *error) {
        }] ;
    }
}

- (void)toolbarDidSelectH5 {
    if ([self typeBlkListHasThisType:MarkdownSyntaxH5]) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(NSString *val, NSError *error) {
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"5" completion:^(NSString *val, NSError *error) {
        }] ;
    }
}

- (void)toolbarDidSelectH6 {
    if ([self typeBlkListHasThisType:MarkdownSyntaxH6]) {
        [self nativeCallJSWithFunc:@"paragraph" json:nil completion:^(NSString *val, NSError *error) {
        }] ;
    }
    else {
        [self nativeCallJSWithFunc:@"titleWithSize" json:@"6" completion:^(NSString *val, NSError *error) {
        }] ;
    }
}

- (void)toolbarDidSelectBold {
    [self nativeCallJSWithFunc:@"bold" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectItalic {
    [self nativeCallJSWithFunc:@"italic" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectDeletion {
    [self nativeCallJSWithFunc:@"deletionLine" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectInlineCode {
    [self nativeCallJSWithFunc:@"inlineCode" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectLink {
    [self nativeCallJSWithFunc:@"addLink" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectUnderline {
    [self nativeCallJSWithFunc:@"underline" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

@end
