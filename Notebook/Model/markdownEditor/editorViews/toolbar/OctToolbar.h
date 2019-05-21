//
//  OctToolbar.h
//  Notebook
//
//  Created by teason23 on 2019/5/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MDEKeyboardPhotoView, MarkdownModel ;
@protocol OctToolbarDelegate <NSObject>

- (CGFloat)keyboardHeight ;

- (void)showOriginKeyboard ;
- (void)hideKeyboard ;
- (void)toolbarDidSelectBoardInline ;
- (void)toolbarDidSelectBoardBlock ;
- (MDEKeyboardPhotoView *)toolbarDidSelectPhotoView ;
- (void)toolbarDidSelectUndo ;
- (void)toolbarDidSelectRedo ;




// board 2
- (void)toolbarDidSelectUList ;
- (void)toolbarDidSelectOrderlist ;

- (void)toolbarDidSelectLeftTab ;
- (void)toolbarDidSelectRightTab ;

- (void)toolbarDidSelectTaskList ;
- (void)toolbarDidSelectQuoteBlock ;

- (void)toolbarDidSelectSepLine ;

- (void)toolbarDidSelectCodeBlock ;
- (void)toolbarDidSelectLink ;

@end


@interface OctToolbar : UIView
@property (nonatomic, weak) id<OctToolbarDelegate> delegate ;

- (void)renderWithModel:(MarkdownModel *)model ;
- (void)refresh ;
@end


