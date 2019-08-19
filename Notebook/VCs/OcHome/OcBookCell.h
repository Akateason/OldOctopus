//
//  OcBookCell.h
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OcBookCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *viewForBookIcon;//占位，icon或emoji
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIView *viewOnSelected;

@end

NS_ASSUME_NONNULL_END
