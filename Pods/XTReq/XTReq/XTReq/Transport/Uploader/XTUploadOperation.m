//
//  XTUploadOperation.m
//  XTReq
//
//  Created by teason23 on 2020/8/26.
//  Copyright © 2020 teaason. All rights reserved.
//

#import "XTUploadOperation.h"

@interface XTUploadOperation() {
    BOOL executing;  // 系统的 finished 是只读的，不能修改，所以只能重写一个。
    BOOL finished;
}
@property (nonatomic, strong) XTUploadTask      *task;
@property (nonatomic, assign) BOOL              isObserving;
@end

@implementation XTUploadOperation

#pragma mark - Observe Task

+ (instancetype)operationWithURLSessionTask:(XTUploadTask *)task {
    XTUploadOperation *operation = [XTUploadOperation new];
    operation.task = task;
    return operation;
}

- (void)dealloc {
    [self stopObservingTask];
}

- (void)startObservingTask {
    @synchronized (self) {
        if (_isObserving) {
            return;
        }
        
        [_task addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        _isObserving = YES;
    }
}

- (void)stopObservingTask { // 因为要在 dealloc 调，所以用下划线不用点语法
    @synchronized (self) {
        if (!_isObserving) {
            return;
        }
        
        _isObserving = NO;
        [_task removeObserver:self forKeyPath:@"state"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (self.task.state == XTReqTaskStateCanceled || self.task.state == XTReqTaskStateFailed || self.task.state == XTReqTaskStateSuccessed) {
        [self stopObservingTask];
        [self completeOperation];
    }
}

#pragma mark - NSOperation methods

- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled]) {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    @try {
        [self startObservingTask];
        [self.task resume];
    }
    @catch (NSException * e) {
        NSLog(@"Exception %@", e);
    }
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

@end
