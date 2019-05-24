//
//  MdListModel.h
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
// 列表嵌套是一对多, 但也视为一对一. 逐行处理他们. 通过前面的空格数判断 缩进的位置

#import <UIKit/UIKit.h>
#import "MarkdownModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MdListModel : MarkdownModel

@property (nonatomic) NSRange realRange ;           // 去掉嵌套列表前面的空格符之后的 真实 range .
@property (nonatomic) NSRange markWillHiddenRange ; // 需要被去掉的mark的range, 包括前面的空格符 .
@property (nonatomic) int countForSpace ;


- (BOOL)taskItemSelected ;
- (UIImage *)taskItemImageState ;

+ (void)toolbarEventForTasklist:(MarkdownEditor *)editor ;
+ (void)toolbarEventForUlist:(MarkdownEditor *)editor ;
+ (void)toolbarEventForOrderList:(MarkdownEditor *)editor ;

+ (int)keyboardEnterTypedInTextView:(MarkdownEditor *)textView
                    modelInPosition:(MarkdownModel *)aModel
            shouldChangeTextInRange:(NSRange)range ;

@end

NS_ASSUME_NONNULL_END
