//
//  LDHeadView.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kNotification_AddBook = @"kNotification_AddBook" ;


@interface LDHeadView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lbHead;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbMyBook;
@property (weak, nonatomic) IBOutlet UIImageView *imgAddBook;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightFlex_addImage;

- (void)setupUser ;
- (void)setDistance:(float)distance ;
@end

NS_ASSUME_NONNULL_END
