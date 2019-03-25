//
//  MDToolbar.h
//  Notebook
//
//  Created by teason23 on 2019/3/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkdownModel.h"



// H - // B I U S // photo link // ul ol tl // code quote // undo redo //

@protocol MDToolbarDelegate <NSObject>

- (void)toolbarDidSelectRemoveTitle ;
- (void)toolbarDidSelectH1 ;
- (void)toolbarDidSelectH2 ;
- (void)toolbarDidSelectH3 ;
- (void)toolbarDidSelectH4 ;
- (void)toolbarDidSelectH5 ;
- (void)toolbarDidSelectH6 ;
- (void)toolbarDidSelectSepLine ;

- (void)toolbarDidSelectBold ;
- (void)toolbarDidSelectItalic ;
//- (void)toolbarDidSelectUnderline ;
- (void)toolbarDidSelectDeletion ;

- (void)toolbarDidSelectPhoto ;
- (void)toolbarDidSelectLink ;

- (void)toolbarDidSelectUList ;
- (void)toolbarDidSelectOrderlist ;
- (void)toolbarDidSelectTaskList ;

- (void)toolbarDidSelectCodeBlock ;
- (void)toolbarDidSelectQuoteBlock ;

- (void)toolbarDidSelectUndo ;
- (void)toolbarDidSelectRedo ;
@end


typedef enum : NSUInteger {
    MDB_H ,
    
    MDB_H1 ,
    MDB_H2 ,
    MDB_H3 ,
    MDB_H4 ,
    MDB_H5 ,
    MDB_H6 ,
    MDB_Sepline ,
    
    MDB_B ,
    MDB_I ,
//    MDB_U ,
    MDB_D ,
    
    MDB_Photo ,
    MDB_Link ,
    
    MDB_UL ,
    MDB_OL ,
    MDB_TL ,
    
    MDB_Code ,
    MDB_Quote ,
    
    MDB_Undo ,
    MDB_Redo ,
    
    MDB_flex
} MDToolbar_Buttons_Types ;


@interface MDToolbar : UIView

@property (weak, nonatomic) id <MDToolbarDelegate> mdt_delegate ;

// H - // B I U S // photo link // ul ol tl // code quote // undo redo //
- (instancetype)initWithConfigList:(NSArray *)list ;

- (void)renderWithModel:(MarkdownModel *)model ;

@end


