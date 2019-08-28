//
//  SetTrashVC.h
//  Notebook
//
//  Created by teason23 on 2019/8/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SetTrashVC : BasicVC
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *sepLine;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btClear;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


+ (instancetype)showFromCtller:(UIViewController *)fromCtrller ;

@end

NS_ASSUME_NONNULL_END
