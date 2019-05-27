//
//  OctToolbarBlockView.h
//  Notebook
//
//  Created by teason23 on 2019/5/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KeyboardViewButton, MarkdownModel ;

@protocol OctToolbarBlockViewDelegate <NSObject>
- (void)toolbarDidSelectUList ;
- (void)toolbarDidSelectOrderlist ;

- (void)toolbarDidSelectLeftTab ;
- (void)toolbarDidSelectRightTab ;

- (void)toolbarDidSelectTaskList ;
- (void)toolbarDidSelectQuoteBlock ;

- (void)toolbarDidSelectSepLine ;

- (void)toolbarDidSelectCodeBlock ;
- (void)toolbarDidSelectMathBlock ;
@end


@interface OctToolbarBlockView : UIView
@property (weak, nonatomic) id<OctToolbarBlockViewDelegate> blkBoard_Delegate ;

@property (weak, nonatomic) IBOutlet UIView *area1;
@property (weak, nonatomic) IBOutlet UIView *area2;
@property (weak, nonatomic) IBOutlet UIView *area3;
@property (weak, nonatomic) IBOutlet UIView *area4;
@property (weak, nonatomic) IBOutlet UIView *area5;
@property (weak, nonatomic) IBOutlet UIView *area6;

@property (weak, nonatomic) IBOutlet KeyboardViewButton *btUlist;
@property (weak, nonatomic) IBOutlet KeyboardViewButton *btOlist;

@property (weak, nonatomic) IBOutlet KeyboardViewButton *btLeftTab;
@property (weak, nonatomic) IBOutlet KeyboardViewButton *btRightTabg;
@property (weak, nonatomic) IBOutlet KeyboardViewButton *btTaskList;
@property (weak, nonatomic) IBOutlet KeyboardViewButton *btQuote;

@property (weak, nonatomic) IBOutlet KeyboardViewButton *btSepline;
@property (weak, nonatomic) IBOutlet KeyboardViewButton *btCodeBlock;
@property (weak, nonatomic) IBOutlet KeyboardViewButton *btMath;

- (void)addMeAboveKeyboardViewWithKeyboardHeight:(float)keyboardHeight ;
- (void)renderWithModel:(MarkdownModel *)model ;
- (void)clearUI ;
@end


