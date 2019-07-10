//
//  EmojiJson.h
//  Notebook
//
//  Created by teason23 on 2019/4/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XTlib/XTlib.h>


@interface EmojiJson : NSObject
@property (copy, nonatomic) NSString *emoji ;
@property (copy, nonatomic) NSString *desc ;
@property (copy, nonatomic) NSString *category ;
@property (copy, nonatomic) NSArray *aliases ;
@property (copy, nonatomic) NSArray *tags ;

+ (NSArray *)allList ;
+ (NSString *)randomADistinctEmojiWithBooklist:(NSArray *)booklist ;
@end



@interface EmojiJsonManager : NSObject
XT_SINGLETON_H(EmojiJsonManager)
- (NSArray *)allList ;
- (NSArray *)arrayCategory ;
- (NSDictionary *)getWholeDatasource ;
- (NSArray *)chineseCategory ;

- (NSArray *)history ;
- (void)iUseEmoji:(EmojiJson *)emoji ;

@end
