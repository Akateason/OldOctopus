//
//  NoteCell.h
//  Notebook
//
//  Created by teason23 on 2019/3/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealTableViewCell.h"
//#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoteCell : SWRevealTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_isTop;
@property (weak, nonatomic) IBOutlet UIView *area;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbContent;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;

@property (copy, nonatomic) NSString *textForSearching ;
- (void)trashMode:(BOOL)isTrashmode ;

@property (nonatomic) BOOL userSelected ;
//- (void)setUserSelected:(BOOL)selected ;
@end

NS_ASSUME_NONNULL_END
