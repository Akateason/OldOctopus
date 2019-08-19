//
//  SetEditorVC.h
//  Notebook
//
//  Created by teason23 on 2019/7/1.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SetEditorVC : BasicVC
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UITableView *table;
+ (instancetype)getMe ;
@end

NS_ASSUME_NONNULL_END
