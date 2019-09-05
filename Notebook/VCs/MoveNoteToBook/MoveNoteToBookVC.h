//
//  MoveNoteToBookVC.h
//  Notebook
//
//  Created by teason23 on 2019/4/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface MoveNoteToBookVC : BasicVC
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btClose;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *hud;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width_hud;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height_hud;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_Hud;
@property (weak, nonatomic) IBOutlet UIButton *btBg;


+ (instancetype)showFromCtrller:(UIViewController *)ctrller
                     moveToBook:(void(^)(NoteBooks *book))blkMove ;

@end

NS_ASSUME_NONNULL_END
