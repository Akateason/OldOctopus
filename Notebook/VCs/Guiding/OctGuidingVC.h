//
//  OctGuidingVC.h
//  Notebook
//
//  Created by teason23 on 2019/7/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString *const kKey_markForGuidingDisplay = @"kKey_markForGuidingDisplay" ;



@interface OctGuidingVC : UIPageViewController
@property (nonatomic) BOOL kForce ;
+ (instancetype)getMe ;
+ (instancetype)getMeForce ;

@end


