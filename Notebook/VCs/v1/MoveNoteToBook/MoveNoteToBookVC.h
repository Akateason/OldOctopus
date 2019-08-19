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

+ (instancetype)showFromCtrller:(UIViewController *)ctrller
                     moveToBook:(void(^)(NoteBooks *book))blkMove ;

@end

NS_ASSUME_NONNULL_END
