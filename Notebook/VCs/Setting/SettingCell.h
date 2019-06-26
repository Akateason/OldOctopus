//
//  SettingCell.h
//  Notebook
//
//  Created by teason23 on 2019/6/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *upContainer;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIImageView *rightCorner;
@property (weak, nonatomic) IBOutlet UILabel *rightTip;

@end


