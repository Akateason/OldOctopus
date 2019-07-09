//
//  EmojiJson.h
//  Notebook
//
//  Created by teason23 on 2019/4/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmojiJson : NSObject
@property (copy, nonatomic) NSString *emoji ;
@property (copy, nonatomic) NSString *descriptionEm ;
@property (copy, nonatomic) NSString *category ;
@property (copy, nonatomic) NSArray *aliases ;
@property (copy, nonatomic) NSArray *tags ;


+ (NSArray *)allList ;
+ (NSString *)randomADistinctEmojiWithBooklist:(NSArray *)booklist ;


//+ (void)logAlltype ;

@end

NS_ASSUME_NONNULL_END
