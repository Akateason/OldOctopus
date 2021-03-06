//
//  OcNoteCell.h
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookBgView.h"


@interface OcNoteCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIView *sepLine;
@property (weak, nonatomic) IBOutlet UILabel *lbContent;
@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet UIView *bookPHView;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UIImageView *topMark;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lead_date;
@property (strong, nonatomic) UIImageView *bgShadow ;

@property (copy, nonatomic)     NSString    *textForSearching ;
@property (nonatomic)           BOOL        trashState ;
@property (nonatomic)           BOOL        recentState ;
@property (strong, nonatomic)   BookBgView  *bookBg ;
@end


