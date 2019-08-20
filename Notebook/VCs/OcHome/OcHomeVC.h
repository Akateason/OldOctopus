//
//  OcHomeVC.h
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"



@interface OcHomeVC : BasicVC
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



// FUNC
+ (UIViewController *)getMe ;


/**
 ContainerCell call back
 @param directionUp : up - YES, down - NO.
 */
- (void)containerCellDraggingDirection:(BOOL)directionUp ;

@end


