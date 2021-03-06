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
#import <XTlib/XTPhotoAlbum.h>

static NSString *const kNotification_Note_Edited = @"oct_Notification_Note_Edited";

@protocol MarkdownVCDelegate <NSObject>
- (void)addNoteComplete:(Note *)aNote ;
// editNoteComplete:(Note *)aNote  // fix搜索进入首页不回调,这里不用delegate
- (NSString *)currentBookID ;
- (int)currentBookType ;
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
@property (strong, nonatomic) XTCameraHandler                   *cameraHandler ;
@property (strong, nonatomic) RACSubject                        *subjectIpadKeyboardCommand ;
@property (strong, nonatomic) Note                              *aNote ;

@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet UIView *navArea;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForNavBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBar;
//@property (weak, nonatomic) IBOutlet UIButton *btShare;

@property (nonatomic)         BOOL              isInTrash ;
@property (nonatomic)         BOOL              isInShare ;
@property (nonatomic)         BOOL              isNewFromIpad ;
@property (nonatomic)         BOOL              isCreateEmptyNote ;
@property (nonatomic)         BOOL              isSnapshoting ;


+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
                fromCtrller:(UIViewController *)ctrller ;

+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
        isCreateNewFromIpad:(BOOL)newFromIpad
                fromCtrller:(UIViewController *)ctrller ;

- (void)setupWithNote:(Note *)note
               bookID:(NSString *)bookID
          fromCtrller:(UIViewController *)ctrller ;

- (void)leaveOut ;

+ (CGFloat)getEditorLeftIpad ;


- (void)createNewNote ;
- (void)updateMyNote ;
- (void)snapShotFullScreen:(NSString *)htmlString ;
- (void)clearArticleInIpad ;

@end
