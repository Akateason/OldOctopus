//
//  EmojiChooseVC.h
//  Notebook
//
//  Created by teason23 on 2019/7/4.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
#import "EmojiJson.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EmojiChooseVCDelegate <NSObject>
- (void)selectedEmoji:(EmojiJson *)emoji ;
- (void)viewDismiss ;
@end

@interface EmojiChooseVC : BasicVC
@property (weak, nonatomic) id <EmojiChooseVCDelegate> delegate ;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btClose;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *searchBarBg;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UILabel *lbHistory;
@property (weak, nonatomic) IBOutlet UILabel *lbPeople;
@property (weak, nonatomic) IBOutlet UILabel *lbAnimal;
@property (weak, nonatomic) IBOutlet UILabel *lbFood;
@property (weak, nonatomic) IBOutlet UILabel *lbActive;
@property (weak, nonatomic) IBOutlet UILabel *lbPlace;
@property (weak, nonatomic) IBOutlet UILabel *lbObject;
@property (weak, nonatomic) IBOutlet UILabel *lbSymbol;
@property (weak, nonatomic) IBOutlet UILabel *lbFlag;



+ (void)showMeFrom:(UIViewController *)contentController
          fromView:(UIView *)fromView ;


@end

NS_ASSUME_NONNULL_END
