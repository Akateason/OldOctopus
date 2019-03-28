//
//  LDNotebookCell.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDNotebookCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgViewOnChoose;
@property (weak, nonatomic) IBOutlet UIView *redMark;
@property (weak, nonatomic) IBOutlet UILabel *lbEmoji;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flexGrayWid;
- (void)setDistance:(float)distance ;

//- (void)setSelectedState:

@end

NS_ASSUME_NONNULL_END
