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
    SC_Home_mode_default_iPhone_2_collumn   = 32 ,
    SC_Home_mode_iPad_Horizon_6_collumn     = 40 ,
    SC_Home_mode_iPad_Verical_4_collumn          ,
    SC_Home_mode_iPad_Spilit_4_collumn           ,
        
} SC_Home_mode_Type ;

@interface GlobalDisplaySt : NSObject
XT_SINGLETON_H(GlobalDisplaySt)

@property (nonatomic) SC_Home_mode_Type vType ;
@property (nonatomic) CGSize containerSize ;
- (void)correctCurrentCondition:(UIViewController *)ctrller ;


@property (nonatomic) BOOL isPopOverFromIpad ; // 从ipad弹出的 气泡窗口,  控制topFLex 为0 ;
@property (nonatomic) BOOL isInNewBookVC ;

@property (nonatomic) BOOL currentSystemIsDarkMode ;

- (UICollectionViewFlowLayout *)homeContentLayout ;









@end

NS_ASSUME_NONNULL_END
