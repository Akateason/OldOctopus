//
//  SettingItemCell.h
//  Notebook
//
//  Created by teason23 on 2019/6/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JTMaterialSwitch/JTMaterialSwitch.h>
#import "SettingCell.h"

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
@property (weak, nonatomic) IBOutlet UIView *topLine;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left_topLine;


@property (strong, nonatomic) UIViewController *controller ;

@property (nonatomic) SettingCellSeperateLine_Mode sepLineMode ;
@end

NS_ASSUME_NONNULL_END
