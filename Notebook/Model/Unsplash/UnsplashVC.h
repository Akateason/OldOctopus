//
//  UnsplashVC.h
//  Notebook
//
//  Created by teason23 on 2019/9/24.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"





NS_ASSUME_NONNULL_BEGIN



@interface UnsplashVC : BasicVC
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btClose;
@property (weak, nonatomic) IBOutlet UIView *secBar;
@property (weak, nonatomic) IBOutlet UIView *bgSch;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;


+ (void)showMeFrom:(UIViewController *)fromCtrller ;

@end

NS_ASSUME_NONNULL_END
