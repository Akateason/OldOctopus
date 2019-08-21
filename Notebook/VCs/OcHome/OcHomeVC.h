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

/**
 topbar的变化State Y - 短， N - 长， default - 长;
 */
@property (nonatomic)           BOOL                uiStatus_TopBar_turnSmall ;
// 短topbar book segment
@property (strong, nonatomic)   XTStretchSegment    *segmentBooks ;

// data
@property (copy, nonatomic)     NSArray             *bookList ;
@property (strong, nonatomic)   NoteBooks           *currentBook ;
@property (nonatomic)           NSInteger           bookCurrentIdx ;


// FUNC
+ (UIViewController *)getMe ;

- (void)refreshAll ;



/**
 ContainerCell call back
 @param directionUp : up - YES, down - NO.
 */
- (void)containerCellDraggingDirection:(BOOL)directionUp ;

@end


