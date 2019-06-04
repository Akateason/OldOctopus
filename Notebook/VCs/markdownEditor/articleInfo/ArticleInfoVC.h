//
//  ArticleInfoVC.h
//  Notebook
//
//  Created by teason23 on 2019/4/15.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
@class XTMarkdownParser ;

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

@property (strong, nonatomic) XTMarkdownParser *parser ;


@property (weak, nonatomic) IBOutlet UIView *topArea;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightForRightCorner;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lbCollectForKeys;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lvCollectionForVals;


@property (weak, nonatomic) IBOutlet UILabel *lbBookName;
@property (weak, nonatomic) IBOutlet UILabel *lbCreateTime;
@property (weak, nonatomic) IBOutlet UILabel *lbUpdateTime;
@property (weak, nonatomic) IBOutlet UILabel *lbCountOfWord;
@property (weak, nonatomic) IBOutlet UILabel *lbCountOfCharactor;
@property (weak, nonatomic) IBOutlet UILabel *lbCountOfPara;
@property (weak, nonatomic) IBOutlet UIButton *btDelete;
@property (weak, nonatomic) IBOutlet UIButton *btOutput;
@property (weak, nonatomic) IBOutlet UIImageView *imgRight;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;

+ (CGFloat)movingDistance ;

@end

NS_ASSUME_NONNULL_END
