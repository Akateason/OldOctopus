//
//  OctWebEditor+BlockBoardUtil.m
//  Notebook
//
//  Created by teason23 on 2019/6/4.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor+BlockBoardUtil.h"
#import "TableCreatorView.h"
#import <XTlib/XTlib.h>

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

- (void)toolbarDidSelectTable {
    @weakify(self)
    [TableCreatorView showOnView:self window:self.window keyboardHeight:self->keyboardHeight callback:^(BOOL isConfirm, NSString * _Nonnull line, NSString * _Nonnull column) {
        @strongify(self)
        if (!isConfirm) {
            [self becomeFirstResponder] ;
            return ;
        }
        
        int lineCount = [line intValue] ?: 2 ;
        int columnCount = [column intValue] ?: 3 ;
        
        NSDictionary *dic = @{@"rows":@(lineCount),@"columns":@(columnCount)} ;
        [self nativeCallJSWithFunc:@"table" json:[dic yy_modelToJSONString] completion:^(BOOL isComplete) {
    
        }] ;
    }] ;
    
    

}

- (void)toolbarDidSelectHtml {
    [self nativeCallJSWithFunc:@"htmlBlock" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectVegaChart {
    [self nativeCallJSWithFunc:@"vegaChart" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectFlowChart {
    [self nativeCallJSWithFunc:@"flowChart" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectSequnceDiag {
    [self nativeCallJSWithFunc:@"seqDiagram" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectMermaid {
    [self nativeCallJSWithFunc:@"mermaid" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

@end
