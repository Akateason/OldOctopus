//
//  UserTestCodeVC.m
//  Notebook
//
//  Created by teason23 on 2019/7/11.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "UserTestCodeVC.h"
#import "AppDelegate.h"
#import "OctRequestUtil.h"

@interface UserTestCodeVC ()

@end

@implementation UserTestCodeVC

static NSString *k_UD_Inner_Test_Done = @"k_UD_Inner_Test_Done" ;

+ (void)getMeFrom:(UIViewController *)ctrller {
    if (!k_Is_Internal_Testing) return ;
    
    BOOL innerTestDone = [XT_USERDEFAULT_GET_VAL(k_UD_Inner_Test_Done) boolValue] ;
    if (innerTestDone) return ;
    
    UserTestCodeVC *vc = [UserTestCodeVC getCtrllerFromStory:@"Main" controllerIdentifier:@"UserTestCodeVC"] ;
    [ctrller presentViewController:vc animated:YES completion:^{}] ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.view.backgroundColor = [UIColor lightGrayColor] ;
    
    WEAK_SELF
    [self.btGoNow bk_addEventHandler:^(id sender) {
        
        NSString *testCode ;
#ifdef DEBUG
        testCode = @"octopus_test_code" ;
#else
        testCode = self.tfCode.text ;
#endif
        
        [OctRequestUtil verifyCode:testCode completion:^(bool success) {
            if (success) {
                XT_USERDEFAULT_SET_VAL(@1, k_UD_Inner_Test_Done) ;
                [weakSelf dismissViewControllerAnimated:YES completion:^{}] ;
            }
        }] ;
        
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    
    [self.btGetInviteCode bk_addEventHandler:^(id sender) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://shimo.im/octopus"]] ;
        
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    
    [self.btCancel bk_addEventHandler:^(id sender) {
        
        AppDelegate *app = [UIApplication sharedApplication].delegate ;
        UIWindow *window = app.window ;
        [UIView animateWithDuration:.1 animations:^{
            window.alpha = 0 ;
        } completion:^(BOOL finished) {
            exit(0) ;
        }] ;
        
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    
}


@end
