//
//  OctMBPHud.h
//  Notebook
//
//  Created by teason23 on 2019/7/12.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XTlib/XTlib.h>

NS_ASSUME_NONNULL_BEGIN

@interface OctMBPHud : NSObject
XT_SINGLETON_H(OctMBPHud)

- (void)show ;
- (void)hide ;

@end

NS_ASSUME_NONNULL_END
