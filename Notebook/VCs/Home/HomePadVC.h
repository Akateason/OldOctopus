//
//  HomePadVC.h
//  Notebook
//
//  Created by teason23 on 2019/6/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
#import "MarkdownVC.h"

extern const float kWidth_ListView ;

NS_ASSUME_NONNULL_BEGIN

@interface HomePadVC : BasicVC
@property (strong, nonatomic) MarkdownVC    *editorVC ;
+ (UIViewController *)getMe ;

@end

NS_ASSUME_NONNULL_END
