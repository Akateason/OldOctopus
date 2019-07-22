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
#import "OctWebEditor+OctToolbarUtil.h"

@implementation OctWebEditor (BlockBoardUtil)

- (void)toolbarDidSelectLeftTab {
    [self nativeCallJSWithFunc:@"tabLeft" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectRightTab {
    [self nativeCallJSWithFunc:@"tabRight" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectSepLine {
    [self nativeCallJSWithFunc:@"sepline" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectUList {
    [self nativeCallJSWithFunc:@"uList" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectOrderlist {
    [self nativeCallJSWithFunc:@"oList" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectTaskList {
    [self nativeCallJSWithFunc:@"tList" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectCodeBlock {
    [self nativeCallJSWithFunc:@"codeBlock" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectQuoteBlock {
    [self nativeCallJSWithFunc:@"quote" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectMathBlock {
    [self nativeCallJSWithFunc:@"mathFormula" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectTable {
    [self.toolBar reset] ;
    
    @weakify(self)
    [TableCreatorView showOnView:self window:self.window keyboardHeight:self->keyboardHeight callback:^(BOOL isConfirm, NSString * _Nonnull line, NSString * _Nonnull column) {
        @strongify(self)
        if (!isConfirm) {
//            [self openKeyboard] ;
            return ;
        }
        
        int lineCount = [line intValue] ?: 2 ;
        int columnCount = [column intValue] ?: 3 ;
    
        NSDictionary *dic = @{@"rows":@(lineCount),@"columns":@(columnCount)} ;
        [self nativeCallJSWithFunc:@"table" json:dic completion:^(NSString *val, NSError *error) {
            
        }] ;
    }] ;
    
    

}

- (void)toolbarDidSelectHtml {
    [self nativeCallJSWithFunc:@"htmlBlock" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectVegaChart {
    [self nativeCallJSWithFunc:@"vegaChart" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectFlowChart {
    [self nativeCallJSWithFunc:@"flowChart" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectSequnceDiag {
    [self nativeCallJSWithFunc:@"seqDiagram" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectMermaid {
    [self nativeCallJSWithFunc:@"mermaid" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

@end
