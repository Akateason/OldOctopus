//
//  RowHeightCell.h
//  Notebook
//
//  Created by teason23 on 2019/7/1.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RowHeightCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *lbSlideVal;

@end

NS_ASSUME_NONNULL_END
