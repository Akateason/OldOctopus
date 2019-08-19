//
//  HomeVC.h
//  Notebook
//
//  Created by teason23 on 2019/3/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
@class LeftDrawerVC, NewBookVC ;



@interface HomeVC : BasicVC
+ (UIViewController *)getMe ;

@property (readonly, weak, nonatomic) IBOutlet   UITableView    *table;
@property (strong, nonatomic)                    LeftDrawerVC   *leftVC ;
@property (strong, nonatomic)                    NewBookVC      *nBookVC ;
@property (nonatomic)                            CGRect         rectSchBarCell ;
@property (copy, nonatomic)                      NSArray        *listNotes ;

- (void)dealTopNoteLists:(NSArray *)list ;
+ (CGFloat)movingDistance ;
@end


