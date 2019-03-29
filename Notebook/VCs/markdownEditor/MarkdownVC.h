//
//  MarkdownVC.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <XTBase/XTBase.h>
@class Note ;



@interface MarkdownVC : RootCtrl

+ (instancetype)newWithNote:(Note *)note
                fromCtrller:(UIViewController *)ctrller ;

@end


