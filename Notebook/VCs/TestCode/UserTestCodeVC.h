//
//  UserTestCodeVC.h
//  Notebook
//
//  Created by teason23 on 2019/7/11.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserTestCodeVC : BasicVC
@property (weak, nonatomic) IBOutlet UITextField *tfCode;
@property (weak, nonatomic) IBOutlet UIButton *btGetInviteCode;
@property (weak, nonatomic) IBOutlet UIButton *btGoNow;
@property (weak, nonatomic) IBOutlet UIButton *btCancel;
@property (weak, nonatomic) IBOutlet UIView *inputContainer;

+ (void)getMeFrom:(UIViewController *)ctrller ;

@end

NS_ASSUME_NONNULL_END
