//
//  OctToolbar.h
//  Notebook
//
//  Created by teason23 on 2019/5/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XTlib/XTlib.h>

@class MDEKeyboardPhotoView, MarkdownModel, MarkdownEditor ;
@protocol OctToolbarDelegate <NSObject>

- (CGFloat)keyboardHeight ;
- (void)hideKeyboard ;
- (MDEKeyboardPhotoView *)toolbarDidSelectPhotoView ;
- (void)toolbarDidSelectUndo ;
- (void)toolbarDidSelectRedo ;
- (UIView *)fromEditor ;
- (void)subscription ;

@end


@interface OctToolbar : UIView

@property (nonatomic, weak) id<OctToolbarDelegate> delegate ;
@property (nonatomic) int       selectedPosition ;
@property (nonatomic) BOOL      smartKeyboardState ;

@property (weak, nonatomic) IBOutlet UIButton *btShowKeyboard ;
@property (weak, nonatomic) IBOutlet UIButton *btInlineStyle ;
@property (weak, nonatomic) IBOutlet UIButton *btList ;
@property (weak, nonatomic) IBOutlet UIButton *btPhoto ;
@property (weak, nonatomic) IBOutlet UIButton *btUndo ;
@property (weak, nonatomic) IBOutlet UIButton *btRedo ;
@property (weak, nonatomic) IBOutlet UIButton *btHideKeyboard ;

- (void)renderWithParaType:(NSArray *)paraList inlineList:(NSArray *)inlineList ;
- (void)renderWithModel:(MarkdownModel *)model ;
- (void)reset ;
- (void)refresh ;
- (void)hideAllBoards ;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *toolbarBts;


@end


