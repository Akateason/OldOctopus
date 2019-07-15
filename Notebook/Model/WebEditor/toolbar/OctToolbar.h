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

@end


@interface OctToolbar : UIView
XT_SINGLETON_H(OctToolbar)
@property (nonatomic, weak) id<OctToolbarDelegate> delegate ;
- (void)renderWithParaType:(int)para inlineList:(NSArray *)inlineList ;
- (void)renderWithModel:(MarkdownModel *)model ;
- (void)reset ;
@end


