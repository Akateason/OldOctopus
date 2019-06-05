//
//  OctWebEditor+InlineBoardUtil.m
//  Notebook
//
//  Created by teason23 on 2019/6/4.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor+InlineBoardUtil.h"

@implementation OctWebEditor (InlineBoardUtil)

- (void)toolbarDidSelectClearToCleanPara {
    JSValue *val = [self nativeCallJSWithFunc:@"clearAllFomat" json:nil] ;
}

- (void)toolbarDidSelectH1 {
    JSValue *val = [self nativeCallJSWithFunc:@"titleWithSize" json:@"1"] ;
}

- (void)toolbarDidSelectH2 {
    JSValue *val = [self nativeCallJSWithFunc:@"titleWithSize" json:@"2"] ;
}

- (void)toolbarDidSelectH3 {
    JSValue *val = [self nativeCallJSWithFunc:@"titleWithSize" json:@"3"] ;
}

- (void)toolbarDidSelectH4 {
    JSValue *val = [self nativeCallJSWithFunc:@"titleWithSize" json:@"4"] ;
}

- (void)toolbarDidSelectH5 {
    JSValue *val = [self nativeCallJSWithFunc:@"titleWithSize" json:@"5"] ;
}

- (void)toolbarDidSelectH6 {
    JSValue *val = [self nativeCallJSWithFunc:@"titleWithSize" json:@"6"] ;
}

- (void)toolbarDidSelectBold {
    JSValue *val = [self nativeCallJSWithFunc:@"bold" json:nil] ;
}

- (void)toolbarDidSelectItalic {
    JSValue *val = [self nativeCallJSWithFunc:@"italic" json:nil] ;
}

- (void)toolbarDidSelectDeletion {
    JSValue *val = [self nativeCallJSWithFunc:@"deletionLine" json:nil] ;
}

- (void)toolbarDidSelectInlineCode {
    JSValue *val = [self nativeCallJSWithFunc:@"inlineCode" json:nil] ;
}

- (void)toolbarDidSelectLink {
    JSValue *val = [self nativeCallJSWithFunc:@"addLink" json:nil] ;

}

@end
