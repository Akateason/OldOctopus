//
//  SettingCell.h
//  Notebook
//
//  Created by teason23 on 2019/6/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    SettingCellSeperateLine_Mode_ALL_FULL,
    SettingCellSeperateLine_Mode_Top,
    SettingCellSeperateLine_Mode_Bottom,
    SettingCellSeperateLine_Mode_Middel,
} SettingCellSeperateLine_Mode ;


@interface SettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIImageView *rightCorner;
@property (weak, nonatomic) IBOutlet UILabel *rightTip;
@property (weak, nonatomic) IBOutlet UIView *topLine;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left_topLine;

@property (nonatomic) SettingCellSeperateLine_Mode sepLineMode ;

@end


