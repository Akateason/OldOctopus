//
//  OcHomeVC.h
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
#import "OcBookCell.h"
#import "OcContainerCell.h"
#import <XTlib/XTStretchSegment.h>
#import "NewBookVC.h"
#import <Lottie/Lottie.h>


// lastBook
// @key     kUDCached_lastBook_RecID
// @value   recID,  trash, recent , staging 这三种的话就保存vType.toStr
static NSString *const kUDCached_lastBook_RecID = @"kUDCached_lastBook_RecID" ;

@interface OcHomeVC : BasicVC
// UI
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btUser;
@property (weak, nonatomic) IBOutlet UIButton *btSearch;
@property (weak, nonatomic) IBOutlet UIView *midBar;
@property (weak, nonatomic) IBOutlet UILabel *lbMyNotes;
@property (weak, nonatomic) IBOutlet UILabel *lbAll;
@property (weak, nonatomic) IBOutlet UIImageView *img_lbAllRight;//全部右角
@property (weak, nonatomic) IBOutlet UICollectionView *bookCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height_midBar;
@property (weak, nonatomic) IBOutlet UIButton *btAllNote;

/**
 topbar的变化State Y - 短， N - 长， default - 长;
 */
@property (nonatomic)           BOOL                uiStatus_TopBar_turnSmall ;
// 短topbar book segment
@property (strong, nonatomic)   XTStretchSegment    *segmentBooks ;
// 短topbar 全部按钮
@property (strong, nonatomic)   UIView              *btBooksSmall_All  ;
// 同步转圈
//@property (strong, nonatomic) LOTAnimationView          *animationSync ;

// data
@property (copy, nonatomic)     NSArray             *bookList ;
@property (strong, nonatomic)   NoteBooks           *currentBook ;
@property (nonatomic)           NSInteger           bookCurrentIdx ;




// FUNC
+ (UIViewController *)getMe ;

- (void)refreshAll ;
- (void)refreshBars ;
- (void)refreshContents ;

- (void)getAllBooks ;           // 拿所有书, 和笔记
- (void)getAllBooksIfNeeded ;   // 不会频繁刷新

- (void)btAddOnClick ;
- (void)addNoteOnClick ;
- (void)addBookOnClick ;

- (void)moveNote:(Note *)note ;
- (void)changeNoteTopState:(Note *)note ;
- (void)deleteNote:(Note *)note ;

- (float)newMidHeight ;
- (void)setupStructCollectionLayout ;

/**
 ContainerCell call back
 @param directionUp : up - YES, down - NO.
 */
- (void)containerCellDraggingDirection:(BOOL)directionUp ;
- (void)containerCellDidSelectedNote:(Note *)note ;

/**
 OcNoteCell call back
 */
- (void)noteCellDidSelectedBtMore:(Note *)aNote fromView:(UIView *)fromView ;
@end


