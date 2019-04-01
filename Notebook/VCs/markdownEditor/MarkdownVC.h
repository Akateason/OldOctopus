//
//  MarkdownVC.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
@class Note ;



@interface MarkdownVC : BasicVC

+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
                fromCtrller:(UIViewController *)ctrller ;

@end


