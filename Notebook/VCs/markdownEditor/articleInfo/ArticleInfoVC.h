//
//  ArticleInfoVC.h
//  Notebook
//
//  Created by teason23 on 2019/4/15.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
#import "ArticleBgVC.h"

@class XTMarkdownParser,WebModel ;

NS_ASSUME_NONNULL_BEGIN

typedef void(^BlkDeleteFinished)(void) ;
typedef void(^BlkOutputOnClick)(void) ;


@protocol ArticleInfoVCDelegate <NSObject>
- (UIViewController *)fromCtrller ;
@end

@interface ArticleInfoVC : BasicVC
@property (weak, nonatomic) id <ArticleInfoVCDelegate> delegate ;
@property (strong, nonatomic) Note *aNote ;
@property (copy, nonatomic) BlkDeleteFinished blkDelete ;
@property (copy, nonatomic) BlkOutputOnClick blkOutput ;

@property (strong, nonatomic) WebModel *webInfo ;

@property (strong, nonatomic) ArticleBgVC *bgVC ;
+ (CGFloat)movingDistance ;

- (void)close ;

@end

NS_ASSUME_NONNULL_END
