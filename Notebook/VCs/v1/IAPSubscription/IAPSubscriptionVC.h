//
//  IAPSubscriptionVC.h
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface IAPSubscriptionVC : BasicVC
+ (instancetype)getMe ;
+ (void)showMePresentedInFromCtrller:(UIViewController *)fromCtrller
                      fromSourceView:(UIView *)souceView
                      isPresentState:(BOOL)isPresentState ;

@end

NS_ASSUME_NONNULL_END
