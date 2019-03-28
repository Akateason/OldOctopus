//
//  LDHeadView.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDHeadView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lbHead;
@property (weak, nonatomic) IBOutlet UILabel *lbName;

- (void)setupUser ;
@end

NS_ASSUME_NONNULL_END
