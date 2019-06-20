//
//  XTTripleSlidingCtrller.h
//  Notebook
//
//  Created by teason23 on 2019/6/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNoteSlidingSizeChanging                @"kNoteSlidingSizeChanging"

NS_ASSUME_NONNULL_BEGIN

@interface XTTripleSlidingCtrller : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, strong)   UIViewController    *topViewController;
@property (nonatomic, strong)   UIViewController    *midViewController;
@property (nonatomic, strong)   UIViewController    *bottomViewController;

@property (nonatomic)           CGFloat             fstDistance ;
@property (nonatomic)           CGFloat             secDistance ;

- (id)initWithTopViewController:(UIViewController *)topViewController
              midViewController:(UIViewController *)midViewController
           bottomViewController:(UIViewController *)bottomViewController
                    fstDistance:(float)fstDistance
                    secDistance:(float)secDistance ;



@end

NS_ASSUME_NONNULL_END
