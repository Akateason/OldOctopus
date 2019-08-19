//
//  LDNotebookCell.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LDNotebookCell : SWRevealTableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgViewOnChoose;
@property (weak, nonatomic) IBOutlet UILabel *lbEmoji;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (strong, nonatomic) UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UIView *leftRedView;

- (void)shineOnce:(void(^)(void))completion ;

@end

NS_ASSUME_NONNULL_END
