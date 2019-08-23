//
//  OcBookCell.h
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OcBookCellDelegate <NSObject>
- (void)longPressed:(NSIndexPath *)indexPath ;
@end

@interface OcBookCell : UICollectionViewCell
@property (weak, nonatomic) id <OcBookCellDelegate> delegate ;
@property (weak, nonatomic) IBOutlet UIView *viewForBookIcon;//占位，icon或emoji
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIImageView *viewOnSelected;



@end

NS_ASSUME_NONNULL_END
