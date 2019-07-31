//
//  ArticleBgVC.h
//  Notebook
//
//  Created by teason23 on 2019/7/31.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class XTMarkdownParser,WebModel,Note ;

@protocol ArticleBgVCDelegate <NSObject>
- (void)output ;
- (void)removeToTrash ;
@end


@interface ArticleBgVC : UIViewController
@property (weak,nonatomic) id <ArticleBgVCDelegate> delegate ;

@property (weak, nonatomic) IBOutlet UIView *topArea;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;

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
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;


@property (strong, nonatomic) Note *aNote ;
@property (strong, nonatomic) WebModel *webInfo ;
- (void)bind ;
@end

NS_ASSUME_NONNULL_END
