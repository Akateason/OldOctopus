//
//  OcAllBookVC.h
//  Notebook
//
//  Created by teason23 on 2019/8/23.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OcAllBookVCDelegate <NSObject>
@required
- (void)clickABook:(NoteBooks *)book ;
- (void)addedABook:(NoteBooks *)book ;
- (void)renameBook:(NoteBooks *)book ;
- (void)deleteBook:(NoteBooks *)book ;
- (void)ocAllBookVCDidClose ;
@end

@interface OcAllBookVC : BasicVC
@property (weak, nonatomic) id<OcAllBookVCDelegate> delegate ;

@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIButton *btClose;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

+ (instancetype)getMeFrom:(UIViewController *)fromCtrller ;

@end

NS_ASSUME_NONNULL_END
