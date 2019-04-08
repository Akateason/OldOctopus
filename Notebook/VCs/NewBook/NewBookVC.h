//
//  NewBookVC.h
//  Notebook
//
//  Created by teason23 on 2019/4/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewBookVC : BasicVC
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgRightCornerFish;
@property (weak, nonatomic) IBOutlet UILabel *lbEmoji;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UIView *underline;
@property (weak, nonatomic) IBOutlet UIButton *btCreate;
@property (weak, nonatomic) IBOutlet UIButton *btCancel;

+ (instancetype)showMeFromCtrller:(UIViewController *)ctrller
                          changed:(void(^)(NSString *emoji, NSString *bookName))blkChanged
                           cancel:(void(^)(void))blkCancel ;

@end

NS_ASSUME_NONNULL_END
