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
    [self nativeCallJSWithFunc:@"tabLeft" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectRightTab {
    [self nativeCallJSWithFunc:@"tabRight" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectSepLine {
    [self nativeCallJSWithFunc:@"sepline" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectUList {
    [self nativeCallJSWithFunc:@"uList" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectOrderlist {
    [self nativeCallJSWithFunc:@"oList" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectTaskList {
    [self nativeCallJSWithFunc:@"tList" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectCodeBlock {
    [self nativeCallJSWithFunc:@"codeBlock" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectQuoteBlock {
    [self nativeCallJSWithFunc:@"quote" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectMathBlock {
    [self nativeCallJSWithFunc:@"mathFormula" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

@end
