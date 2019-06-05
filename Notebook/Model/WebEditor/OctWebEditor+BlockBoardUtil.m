//
//  OctWebEditor+BlockBoardUtil.m
//  Notebook
//
//  Created by teason23 on 2019/6/4.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor+BlockBoardUtil.h"

@implementation OctWebEditor (BlockBoardUtil)

- (void)toolbarDidSelectLeftTab {
    JSValue *val = [self nativeCallJSWithFunc:@"tabLeft" json:nil] ;
}

- (void)toolbarDidSelectRightTab {
    JSValue *val = [self nativeCallJSWithFunc:@"tabRight" json:nil] ;
}

- (void)toolbarDidSelectSepLine {
    JSValue *val = [self nativeCallJSWithFunc:@"sepline" json:nil] ;
}

- (void)toolbarDidSelectUList {
    JSValue *val = [self nativeCallJSWithFunc:@"uList" json:nil] ;
}

- (void)toolbarDidSelectOrderlist {
    JSValue *val = [self nativeCallJSWithFunc:@"oList" json:nil] ;
}

- (void)toolbarDidSelectTaskList {
    JSValue *val = [self nativeCallJSWithFunc:@"tList" json:nil] ;
}

- (void)toolbarDidSelectCodeBlock {
    JSValue *val = [self nativeCallJSWithFunc:@"codeBlock" json:nil] ;
}

- (void)toolbarDidSelectQuoteBlock {
    JSValue *val = [self nativeCallJSWithFunc:@"quote" json:nil] ;
}

- (void)toolbarDidSelectMathBlock {
    JSValue *val = [self nativeCallJSWithFunc:@"mathFormula" json:nil] ;
    
}

@end
