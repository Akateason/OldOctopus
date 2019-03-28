//
//  Note.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Note : NSObject
@property (copy, nonatomic) NSString *content ;
@property (nonatomic)       int      isDeleted ;
@property (copy, nonatomic) NSString *noteBookId ;
@property (copy, nonatomic) NSString *title ;

@end

NS_ASSUME_NONNULL_END
