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
- (void)hideKeyboard ;
- (MDEKeyboardPhotoView *)toolbarDidSelectPhotoView ;
- (void)toolbarDidSelectUndo ;
- (void)toolbarDidSelectRedo ;

@end


@interface OctToolbar : UIView
@property (nonatomic, weak) id<OctToolbarDelegate> delegate ;

- (void)renderWithModel:(MarkdownModel *)model ;
- (void)refresh ;
@end


