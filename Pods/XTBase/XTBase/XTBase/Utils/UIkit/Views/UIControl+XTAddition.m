//
//  UIControl+XTAddition.m
//  XTBase
//
//  Created by teason23 on 2020/4/10.
//  Copyright © 2020 teason23. All rights reserved.
//

#import "UIControl+XTAddition.h"

@import ObjectiveC.runtime;

static const void *XTControlHandlersKey = &XTControlHandlersKey;

#pragma mark Private

@interface XTControlWrapper : NSObject <NSCopying>

- (id)initWithHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents;

@property (nonatomic) UIControlEvents controlEvents;
@property (nonatomic, copy) void (^handler)(id sender);

@end

@implementation XTControlWrapper

- (id)initWithHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents {
    self = [super init];
    if (!self) return nil;

    self.handler = handler;
    self.controlEvents = controlEvents;

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[XTControlWrapper alloc] initWithHandler:self.handler forControlEvents:self.controlEvents];
}

- (void)invoke:(id)sender {
    self.handler(sender);
}

@end

#pragma mark Category

@implementation UIControl (BlocksKit)

- (void)xt_addEventHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents {
    NSParameterAssert(handler);
    
    NSMutableDictionary *events = objc_getAssociatedObject(self, XTControlHandlersKey);
    if (!events) {
        events = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, XTControlHandlersKey, events, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    NSNumber *key = @(controlEvents);
    NSMutableSet *handlers = events[key];
    if (!handlers) {
        handlers = [NSMutableSet set];
        events[key] = handlers;
    }
    
    XTControlWrapper *target = [[XTControlWrapper alloc] initWithHandler:handler forControlEvents:controlEvents];
    [handlers addObject:target];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
}

- (void)xt_removeEventHandlersForControlEvents:(UIControlEvents)controlEvents {
    NSMutableDictionary *events = objc_getAssociatedObject(self, XTControlHandlersKey);
    if (!events) {
        events = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, XTControlHandlersKey, events, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    NSNumber *key = @(controlEvents);
    NSSet *handlers = events[key];

    if (!handlers)
        return;

    [handlers enumerateObjectsUsingBlock:^(id sender, BOOL *stop) {
        [self removeTarget:sender action:NULL forControlEvents:controlEvents];
    }];

    [events removeObjectForKey:key];
}

- (BOOL)xt_hasEventHandlersForControlEvents:(UIControlEvents)controlEvents {
    NSMutableDictionary *events = objc_getAssociatedObject(self, XTControlHandlersKey);
    if (!events) {
        events = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, XTControlHandlersKey, events, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    NSNumber *key = @(controlEvents);
    NSSet *handlers = events[key];
    
    if (!handlers)
        return NO;
    
    return !!handlers.count;
}

@end
