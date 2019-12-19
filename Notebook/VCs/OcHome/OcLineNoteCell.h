//
//  OcLineNoteCell.h
//  Notebook
//
//  Created by teason23 on 2019/12/16.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface OcLineNoteCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *topLine;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbDesc;
@property (weak, nonatomic) IBOutlet UIView *viewBook;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (weak, nonatomic) IBOutlet UIImageView *pic;

@property (weak, nonatomic) IBOutlet UILabel *lbBook;
@property (weak, nonatomic) IBOutlet UIImageView *imgBook;

@property (weak, nonatomic) IBOutlet UIImageView *topMark;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tail_title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tail_desc;


@property (copy, nonatomic)     NSString    *textForSearching ;

@end

NS_ASSUME_NONNULL_END
