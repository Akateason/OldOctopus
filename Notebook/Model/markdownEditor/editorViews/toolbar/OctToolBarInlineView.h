//
//  OctToolBarInlineView.h
//  Notebook
//
//  Created by teason23 on 2019/5/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OctToolBarInlineView : UIView
@property (weak, nonatomic) IBOutlet UIView *area1;
@property (weak, nonatomic) IBOutlet UIView *area2;
@property (weak, nonatomic) IBOutlet UIView *area3;
@property (weak, nonatomic) IBOutlet UIView *area4;

@property (weak, nonatomic) IBOutlet UIButton *btBold;
@property (weak, nonatomic) IBOutlet UIButton *btItalic;
@property (weak, nonatomic) IBOutlet UIButton *btDeletion;

@property (weak, nonatomic) IBOutlet UIButton *bth1;
@property (weak, nonatomic) IBOutlet UIButton *bth2;
@property (weak, nonatomic) IBOutlet UIButton *bth3;
@property (weak, nonatomic) IBOutlet UIButton *bth4;
@property (weak, nonatomic) IBOutlet UIButton *bth5;
@property (weak, nonatomic) IBOutlet UIButton *bth6;

@property (weak, nonatomic) IBOutlet UIButton *btInlineCode;
@property (weak, nonatomic) IBOutlet UIButton *btParaClean;



@end

NS_ASSUME_NONNULL_END
