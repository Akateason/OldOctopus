//
//  MarkdownVC.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
#import "HomeEmptyPHView.h"
#import "OctWebEditor.h"

static NSString *const kNote_pad_Editor_OnClick = @"kNote_pad_Editor_OnClick" ;
static NSString *const kNote_pad_Editor_PullBack = @"kNote_pad_Editor_PullBack" ;

@protocol MarkdownVCDelegate <NSObject>
- (void)addNoteComplete:(Note *)aNote ;
- (void)editNoteComplete:(Note *)aNote ;
- (NSString *)currentBookID ;
@end

@protocol MarkdownVCPanGestureDelegate <NSObject>
- (BOOL)oct_gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer ;
- (void)oct_panned:(UIPanGestureRecognizer *)recognizer ;
@end

@protocol MDVC_PadVCPanGestureDelegate <NSObject>
- (void)pad_panned:(UIPanGestureRecognizer *)recognizer ;
@end

@interface MarkdownVC : BasicVC
@property (weak, nonatomic) id<MarkdownVCPanGestureDelegate>    oct_panDelegate ;
@property (weak, nonatomic) id<MDVC_PadVCPanGestureDelegate>    pad_panDelegate ;
@property (nonatomic)       BOOL                                canBeEdited ;
@property (weak, nonatomic) id<MarkdownVCDelegate>              delegate ;
@property (strong, nonatomic) HomeEmptyPHView                   *emptyView ;
@property (strong, nonatomic) OctWebEditor                      *editor ;

+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
                fromCtrller:(UIViewController *)ctrller ;

- (void)setupWithNote:(Note *)note
               bookID:(NSString *)bookID
          fromCtrller:(UIViewController *)ctrller ;

- (void)leaveOut ;

+ (CGFloat)getEditorLeftIpad ;

@end


