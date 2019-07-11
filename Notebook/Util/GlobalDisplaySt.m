//
//  GlobalDisplaySt.m
//  Notebook
//
//  Created by teason23 on 2019/6/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "GlobalDisplaySt.h"



@implementation GlobalDisplaySt
XT_SINGLETON_M(GlobalDisplaySt)

- (void)correctCurrentCondition:(UIViewController *)ctrller {
    if (IS_IPAD) {
        if (ctrller.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular || ctrller.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassUnspecified ) {
            [GlobalDisplaySt sharedInstance].displayMode = GDST_Home_3_Column_Horizon ;
        }
        else {
            [GlobalDisplaySt sharedInstance].displayMode = GDST_Home_2_Column_Verical_default ;
        }
    }
    else {
        [GlobalDisplaySt sharedInstance].displayMode = GDST_Home_2_Column_Verical_default ;
    }
}

- (void)setGdst_level_for_horizon:(int)gdst_level_for_horizon {
    _gdst_level_for_horizon = gdst_level_for_horizon ;
    
    NSLog(@"gdst_level_for_horizon %d",gdst_level_for_horizon) ;
    
//    [[UIApplication sharedApplication] setStatusBarHidden:gdst_level_for_horizon == 1] ;
}

@end
