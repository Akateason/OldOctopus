//
//  MDToolbar.h
//  Notebook
//
//  Created by teason23 on 2019/3/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkdownModel.h"

NS_ASSUME_NONNULL_BEGIN

// H - // B I U S // photo link // ul ol tl // code quote // undo redo //

@protocol MDToolbarDelegate <NSObject>

- (void)toolbarDidSelectH1 ;
- (void)toolbarDidSelectH2 ;
- (void)toolbarDidSelectH3 ;
- (void)toolbarDidSelectH4 ;
- (void)toolbarDidSelectH5 ;
- (void)toolbarDidSelectH6 ;

- (void)toolbarDidSelectBold ;
- (void)toolbarDidSelectItalic ;
- (void)toolbarDidSelectDeletion ;

- (void)toolbarDidSelectLink ;
- (void)toolbarDidSelectPhoto ;

- (void)toolbarDidSelectOrderlist ;
- (void)toolbarDidSelectUList ;
- (void)toolbarDidSelectTaskList ;

- (void)toolbarDidSelectQuoteBlock ;
- (void)toolbarDidSelectCodeBlock ;
- (void)toolbarDidSelectSepLine ;

@end

@interface MDToolbar : UIView

@property (weak, nonatomic) id <MDToolbarDelegate> delegate ;

- (void)renderWithModel:(MarkdownModel *)model ;

@end

NS_ASSUME_NONNULL_END
