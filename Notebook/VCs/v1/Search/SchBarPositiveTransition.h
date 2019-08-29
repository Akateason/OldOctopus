//
//  SchBarPositiveTransition.h
//  Notebook
//
//  Created by teason23 on 2019/4/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewControllerTransitioning.h>

NS_ASSUME_NONNULL_BEGIN

@interface SchBarPositiveTransition : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic) CGRect originRect_img ;
@property (nonatomic) CGRect originRect_bar ;
@property (nonatomic) CGRect originRect_text ;
@property (nonatomic) CGRect originRect_cell ;

@property (nonatomic) BOOL isPositive ;

- (instancetype)initWithPositive:(BOOL)isPositive ;

@end

NS_ASSUME_NONNULL_END
