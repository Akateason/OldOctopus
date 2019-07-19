//
//  HomePadVC.h
//  Notebook
//
//  Created by teason23 on 2019/6/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
#import "MarkdownVC.h"

extern const float kWidth_ListView ;

NS_ASSUME_NONNULL_BEGIN

@protocol HomePadVCDelegate <NSObject>
- (void)moveRelativeViewsOnState:(bool)stateOn ;
@end


@interface HomePadVC : BasicVC
@property (weak, nonatomic) id <HomePadVCDelegate>  delegate ;
@property (strong, nonatomic)   MarkdownVC          *editorVC ;
+ (UIViewController *)getMe ;

@end

NS_ASSUME_NONNULL_END
