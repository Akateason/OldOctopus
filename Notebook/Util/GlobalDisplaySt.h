//
//  GlobalDisplaySt.h
//  Notebook
//
//  Created by teason23 on 2019/6/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XTlib/XTlib.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    GDST_Home_2_Column_Verical_default ,
    GDST_Home_3_Column_Horizon ,
} GDST_Home_mode ;

@interface GlobalDisplaySt : NSObject
XT_SINGLETON_H(GlobalDisplaySt)
@property (nonatomic) GDST_Home_mode displayMode ; // 三排还是两排
@property (nonatomic) int gdst_level_for_horizon ; // 三排下的抽屉级数, -1最外(编辑器),0(列表和编辑器),1(书本,列表,编辑器)
- (void)correctCurrentCondition:(UIViewController *)ctrller ;
@end

NS_ASSUME_NONNULL_END
