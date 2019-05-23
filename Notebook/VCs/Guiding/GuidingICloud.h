//
//  GuidingICloud.h
//  Notebook
//
//  Created by teason23 on 2019/5/23.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XTlib/XTlib.h>

NS_ASSUME_NONNULL_BEGIN

@interface GuidingICloud : UIView
XT_SINGLETON_H(GuidingICloud)

@property (weak, nonatomic) IBOutlet UIButton *btClose;
@property (weak, nonatomic) IBOutlet UIView *hud;
@property (weak, nonatomic) IBOutlet UILabel *lb1;
@property (weak, nonatomic) IBOutlet UILabel *lb2;
@property (weak, nonatomic) IBOutlet UILabel *btOpen;
@property (weak, nonatomic) IBOutlet UILabel *lbHowToOpen;

+ (instancetype)show ;
@end

NS_ASSUME_NONNULL_END
