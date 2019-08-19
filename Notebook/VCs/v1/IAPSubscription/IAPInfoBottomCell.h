//
//  IAPInfoBottomCell.h
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IAPInfoBottomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbInfo;
@property (weak, nonatomic) IBOutlet UIButton *btReply;
@property (weak, nonatomic) IBOutlet UIImageView *btImage;
@property (weak, nonatomic) IBOutlet UILabel *lbPrivacy;
@property (weak, nonatomic) IBOutlet UILabel *lbService;

@end

NS_ASSUME_NONNULL_END
