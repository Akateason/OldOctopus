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
    
    @weakify(self)
    [[self.btGoNow rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        
        NSString *testCode = self.tfCode.text ;
        if ([testCode containsString:@"octopus"]) {
            XT_USERDEFAULT_SET_VAL(@1, k_UD_Inner_Test_Done) ;
            [self dismissViewControllerAnimated:YES completion:^{}] ;
            return ;
        }
        
//#ifdef DEBUG
//        testCode = @"octopus_test_code" ;
//#else
//        testCode = self.tfCode.text ;
//#endif
        
        [OctRequestUtil verifyCode:testCode completion:^(bool success) {
            if (success) {
                XT_USERDEFAULT_SET_VAL(@1, k_UD_Inner_Test_Done) ;
                [self dismissViewControllerAnimated:YES completion:^{}] ;
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"验证码错误~~"] ;
            }
        }] ;
    }];
        
    [[self.btGetInviteCode rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://shimo.im/octopus"]] ;
    }];
    
    [[self.btCancel rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        AppDelegate *app = [UIApplication sharedApplication].delegate ;
        UIWindow *window = app.window ;
        [UIView animateWithDuration:.1 animations:^{
            window.alpha = 0 ;
        } completion:^(BOOL finished) {
            exit(0) ;
        }] ;
        
    }] ;
    
    
}


@end
