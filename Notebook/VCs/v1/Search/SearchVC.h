//
//  SearchVC.h
//  Notebook
//
//  Created by teason23 on 2019/4/16.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"



NS_ASSUME_NONNULL_BEGIN

@interface SearchVC : BasicVC
@property (weak, nonatomic) IBOutlet UIView *topArea;
@property (weak, nonatomic) IBOutlet UIView *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *btCancel;
@property (weak, nonatomic) IBOutlet UITextField *tf;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topFlex;

@property (weak, nonatomic) IBOutlet UITableView *table;

+ (void)showSearchVCFrom:(UIViewController *)fromCtrller ;
+ (void)showSearchVCFrom:(UIViewController *)fromCtrller inTrash:(BOOL)inTrash ;

@end

NS_ASSUME_NONNULL_END
