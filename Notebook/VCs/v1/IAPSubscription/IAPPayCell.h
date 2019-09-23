//
//  IAPPayCell.h
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IapUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface IAPPayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbMonth;
@property (weak, nonatomic) IBOutlet UILabel *lbYear;
@property (weak, nonatomic) IBOutlet UIButton *btMonth;
@property (weak, nonatomic) IBOutlet UIButton *btYear;
@property (weak, nonatomic) IBOutlet UILabel *lbDescMonth;
@property (weak, nonatomic) IBOutlet UILabel *lbDescYear;
@property (weak, nonatomic) IBOutlet UIView *baseLien;

@property (strong, nonatomic) IapUtil *iap ;

@end

NS_ASSUME_NONNULL_END
