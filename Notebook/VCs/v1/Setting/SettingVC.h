//
//  SettingVC.h
//  Notebook
//
//  Created by teason23 on 2019/6/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
#import "MDNavVC.h"



@interface SettingVC : BasicVC



+ (MDNavVC *)getMeFromCtrller:(UIViewController *)contentController
                     fromView:(UIView *)fromView ;
@end


