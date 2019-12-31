//
//  LikeUsView.h
//  Notebook
//
//  Created by teason23 on 2019/12/31.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LikeUsView : UIView
@property (weak, nonatomic) IBOutlet UIView *hud;
@property (weak, nonatomic) IBOutlet UILabel *lb1;
@property (weak, nonatomic) IBOutlet UILabel *lb2;

@property (weak, nonatomic) IBOutlet UIView *goStoreView;
@property (weak, nonatomic) IBOutlet UILabel *lb5Star;
@property (weak, nonatomic) IBOutlet UIButton *btLater;
@property (weak, nonatomic) IBOutlet UIButton *btReply;

@property (weak, nonatomic) IBOutlet UIView *sep1;
@property (weak, nonatomic) IBOutlet UIView *sep2;
@property (weak, nonatomic) IBOutlet UIView *sep3;

@property (weak, nonatomic) IBOutlet UIButton *btBackground;


@end

NS_ASSUME_NONNULL_END
