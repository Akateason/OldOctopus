//
//  OctMBPHud.m
//  Notebook
//
//  Created by teason23 on 2019/7/12.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctMBPHud.h"
#import "AppDelegate.h"
#import <MBProgressHUD.h>

@implementation OctMBPHud
XT_SINGLETON_M(OctMBPHud)

- (void)show {
    AppDelegate *app = [UIApplication sharedApplication].delegate ;
    [MBProgressHUD showHUDAddedTo:app.window animated:YES] ;

}

- (void)hide {
    AppDelegate *app = [UIApplication sharedApplication].delegate ;
    [MBProgressHUD hideHUDForView:app.window animated:YES] ;
}

@end
