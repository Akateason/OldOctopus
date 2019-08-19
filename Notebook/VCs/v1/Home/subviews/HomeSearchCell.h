//
//  HomeSearchCell.h
//  Notebook
//
//  Created by teason23 on 2019/4/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeSearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgSearchIcon;
@property (weak, nonatomic) IBOutlet UILabel *lbPh;
@property (weak, nonatomic) IBOutlet UIView *scBar;

@end

NS_ASSUME_NONNULL_END
