//
//  MdListModel.h
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.


#import <UIKit/UIKit.h>
#import "MarkdownModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MdListModel : MarkdownModel

- (BOOL)taskItemSelected ;
- (UIImage *)taskItemImageState ;

+ (void)toolbarEventForTasklist:(MarkdownEditor *)editor ;
+ (void)toolbarEventForUlist:(MarkdownEditor *)editor ;
+ (void)toolbarEventForOrderList:(MarkdownEditor *)editor ;

@end

NS_ASSUME_NONNULL_END
