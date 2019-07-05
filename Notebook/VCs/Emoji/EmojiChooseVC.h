//
//  EmojiChooseVC.h
//  Notebook
//
//  Created by teason23 on 2019/7/4.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmojiChooseVC : BasicVC
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btClose;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *searchBarBg;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;




@end

NS_ASSUME_NONNULL_END
