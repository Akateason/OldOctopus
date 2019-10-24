//
//  OctToolBarInlineView.h
//  Notebook
//
//  Created by teason23 on 2019/5/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OctToolBarInlineViewDelegate <NSObject>
// board 1
- (void)toolbarDidSelectClearToCleanPara ;
- (void)toolbarDidSelectH1 ;
- (void)toolbarDidSelectH2 ;
- (void)toolbarDidSelectH3 ;
- (void)toolbarDidSelectH4 ;
- (void)toolbarDidSelectH5 ;
- (void)toolbarDidSelectH6 ;

- (void)toolbarDidSelectBold ;
- (void)toolbarDidSelectItalic ;
- (void)toolbarDidSelectDeletion ;
- (void)toolbarDidSelectInlineCode ;
- (void)toolbarDidSelectUnderline ;
@end

@class MarkdownModel, KeyboardViewButton ;

@interface OctToolBarInlineView : UIView
@property (weak, nonatomic) id<OctToolBarInlineViewDelegate> inlineBoard_Delegate ;

@property (weak, nonatomic) IBOutlet UIView *area1;
@property (weak, nonatomic) IBOutlet UIView *area2;
@property (weak, nonatomic) IBOutlet UIView *area3;
@property (weak, nonatomic) IBOutlet UIView *area4;
@property (weak, nonatomic) IBOutlet UIView *area5;
@property (weak, nonatomic) IBOutlet UIView *area6;

@property (weak, nonatomic) IBOutlet UIButton *btBold;
@property (weak, nonatomic) IBOutlet UIButton *btItalic;
@property (weak, nonatomic) IBOutlet UIButton *btDeletion;

@property (weak, nonatomic) IBOutlet UIButton *bth1;
@property (weak, nonatomic) IBOutlet UIButton *bth2;
@property (weak, nonatomic) IBOutlet UIButton *bth3;
@property (weak, nonatomic) IBOutlet UIButton *bth4;
@property (weak, nonatomic) IBOutlet UIButton *bth5;
@property (weak, nonatomic) IBOutlet UIButton *bth6;

@property (weak, nonatomic) IBOutlet UIButton *btInlineCode;
@property (weak, nonatomic) IBOutlet UIButton *btParaClean;
@property (weak, nonatomic) IBOutlet UIButton *btUnderline;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *areas;

- (void)addMeAboveKeyboardViewWithKeyboardHeight:(float)keyboardHeight fromCtrller:(UIViewController *)ctrller ;
- (void)renderWithlist:(NSArray *)list ;

- (void)renderWithModel:(MarkdownModel *)model ;
- (void)clearUI ;

@end

NS_ASSUME_NONNULL_END
