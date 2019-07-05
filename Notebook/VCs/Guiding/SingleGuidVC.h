//
//  SingleGuidVC.h
//  Notebook
//
//  Created by teason23 on 2019/7/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SingleGuidVCDelegate <NSObject>
- (void)startOnClick ;
@end

@interface SingleGuidVC : UIViewController
@property (weak, nonatomic) id <SingleGuidVCDelegate> delegate ;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *lb1;
@property (weak, nonatomic) IBOutlet UILabel *lb2;
@property (weak, nonatomic) IBOutlet UILabel *btStart;

@property (nonatomic) int viewType ;
+ (instancetype)getMeWithType:(int)type ;
@end


