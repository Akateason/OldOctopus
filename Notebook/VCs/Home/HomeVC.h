//
//  HomeVC.h
//  Notebook
//
//  Created by teason23 on 2019/3/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
@class LeftDrawerVC, NewBookVC ;

NS_ASSUME_NONNULL_BEGIN

@interface HomeVC : BasicVC
@property (readonly, weak, nonatomic) IBOutlet   UITableView    *table;
@property (readonly, strong, nonatomic)          LeftDrawerVC   *leftVC ;
@property (strong, nonatomic)                    NewBookVC      *nBookVC ;
@property (nonatomic)                            CGRect         rectSchBarCell ;
@end

NS_ASSUME_NONNULL_END
