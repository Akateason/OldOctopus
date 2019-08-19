//
//  HomeVC+PanGestureHandler.h
//  Notebook
//
//  Created by teason23 on 2019/4/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeVC.h"

@class MGSwipeButton ;
NS_ASSUME_NONNULL_BEGIN

@interface HomeVC (PanGestureHandler)

- (NSArray *)setupPanList:(MGSwipeButton *)cell ;

@end

NS_ASSUME_NONNULL_END
