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
@property (nonatomic) GDST_Home_mode displayMode ;
@end

NS_ASSUME_NONNULL_END
