//
//  SettingCellHeader.h
//  Notebook
//
//  Created by teason23 on 2019/6/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingCellHeader : UITableViewHeaderFooterView
@property (strong, nonatomic) UILabel *lbTitle;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier ;
@end

NS_ASSUME_NONNULL_END
