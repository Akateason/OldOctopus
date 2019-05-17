//
//  HomeVC+PanGestureHandler.h
//  Notebook
//
//  Created by teason23 on 2019/4/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeVC.h"

@class SWRevealTableViewCell ;
NS_ASSUME_NONNULL_BEGIN

@interface HomeVC (PanGestureHandler)

- (NSArray *)setupPanList:(SWRevealTableViewCell *)cell ;

@end

NS_ASSUME_NONNULL_END
