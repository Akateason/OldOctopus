//  线程安全的数组
//  XTMutableArray.h
//  XTBase
//
//  Created by teason23 on 2018/11/26.
//  Copyright © 2018 teason23. All rights reserved.
/**
XTMutableArray *ary = [[XTMutableArray alloc] init];
NSOperationQueue *queue = [[NSOperationQueue alloc] init];
queue.maxConcurrentOperationCount = 10;
for (int i = 0; i < 200; i++) {
    NSNumber *number = [NSNumber numberWithInt:i];
    [queue addOperationWithBlock:^{
        [ary addObject:number];
    }];
}
[queue waitUntilAllOperationsAreFinished];

NSLog(@"%ld", (long)ary.count);
NSLog(@"%@", ary);
*/

#import "XTThreadSafeObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XTMutableArrayProtocol

@optional
- (id)lastObject;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)count;

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

@end

@interface XTMutableArray : XTThreadSafeObject<XTMutableArrayProtocol>

@end

NS_ASSUME_NONNULL_END
