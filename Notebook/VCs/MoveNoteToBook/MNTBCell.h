//
//  MNTBCell.h
//  Notebook
//
//  Created by teason23 on 2019/8/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNTBCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbEmoji;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIView *sepLine;

@end

NS_ASSUME_NONNULL_END
