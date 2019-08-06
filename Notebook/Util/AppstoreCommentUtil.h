//
//  AppstoreCommentUtil.h
//  Notebook
//
//  Created by teason23 on 2019/8/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppstoreCommentUtil : NSObject
// app did launch
+ (void)setup ;
// 读完文章之后评论
+ (void)jumpReviewAfterNoteRead ;


// 不一定跳转，应用内评论
+ (void)goReview ;
// 必定跳转，直接去appstore 评论
+ (void)goReviewToAppstore ;
@end

NS_ASSUME_NONNULL_END
