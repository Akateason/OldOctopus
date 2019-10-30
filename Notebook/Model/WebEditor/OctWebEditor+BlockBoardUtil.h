//
//  OctWebEditor+BlockBoardUtil.h
//  Notebook
//
//  Created by teason23 on 2019/6/4.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor.h"

NS_ASSUME_NONNULL_BEGIN

@interface OctWebEditor (BlockBoardUtil)
- (void)toolbarDidSelectUList ;
- (void)toolbarDidSelectOrderlist ;

- (void)toolbarDidSelectLeftTab ;
- (void)toolbarDidSelectRightTab ;

- (void)toolbarDidSelectTaskList ;
- (void)toolbarDidSelectQuoteBlock ;

- (void)toolbarDidSelectSepLine ;

- (void)toolbarDidSelectCodeBlock ;
- (void)toolbarDidSelectMathBlock ;

- (void)toolbarDidSelectTable ;
- (void)toolbarDidSelectHtml ;
- (void)toolbarDidSelectVegaChart ;
- (void)toolbarDidSelectFlowChart ;
- (void)toolbarDidSelectSequnceDiag ;
- (void)toolbarDidSelectMermaid ;
@end

NS_ASSUME_NONNULL_END
