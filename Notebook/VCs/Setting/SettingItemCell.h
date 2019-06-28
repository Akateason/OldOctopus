//
//  SettingItemCell.h
//  Notebook
//
//  Created by teason23 on 2019/6/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JTMaterialSwitch/JTMaterialSwitch.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SettingItemCellDelegate <NSObject>
- (void)switchStateChanged:(JTMaterialSwitchState)currentState dic:(NSDictionary *)dic ;
@end

@interface SettingItemCell : UITableViewCell
@property (weak, nonatomic) id <SettingItemCellDelegate> delegate ;

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgRightCorner;
@property (weak, nonatomic) IBOutlet UILabel *lbDesc;
@property (strong, nonatomic) JTMaterialSwitch  *swt ;

@property (strong, nonatomic) UIViewController *controller ;
@end

NS_ASSUME_NONNULL_END
