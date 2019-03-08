//
//  MarkdownModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownModel.h"

@implementation MarkdownModel

- (instancetype)initWithType:(enum MarkdownSyntaxType) type range:(NSRange) range {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    self.type = type;
    self.range = range;
    
    return self;
}

+ (instancetype)modelWithType:(enum MarkdownSyntaxType) type range:(NSRange) range {
    return [[self alloc] initWithType:type range:range];
}

@end
