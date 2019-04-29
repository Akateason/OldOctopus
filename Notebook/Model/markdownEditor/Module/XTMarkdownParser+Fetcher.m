//
//  XTMarkdownParser+Fetcher.m
//  Notebook
//
//  Created by teason23 on 2019/4/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTMarkdownParser+Fetcher.h"

@implementation XTMarkdownParser (Fetcher)

#pragma mark - return current model with position

- (MarkdownModel *)modelForModelListInlineFirst {
    MarkdownModel *tmpModel = nil ;
    NSArray *modellist = self.currentPositionModelList ;
    for (MarkdownModel *model in modellist) {
        if (model.type > MarkdownInlineUnknown) {
            return model ;
        }
        tmpModel = model ;
    }
    
    if (tmpModel.type == -1 && tmpModel.inlineModels.count > 0) {
        return tmpModel.inlineModels.firstObject ;
    }
    return tmpModel ;
}

- (MarkdownModel *)modelForModelListBlockFirst {
    MarkdownModel *tmpModel = nil ;
    NSArray *modellist = self.currentPositionModelList ;
    for (MarkdownModel *model in modellist) {
        tmpModel = model ;
        if (model.type < MarkdownInlineUnknown) {
            return tmpModel ;
        }
    }
    return tmpModel ;
}

- (MarkdownModel *)getBlkModelForCustomPosition:(NSUInteger)position {
    NSArray *list = self.paraList ;
    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        BOOL isInRange = NSLocationInRange(position, model.range) ;
        
        if (isInRange) {
            if (model.type < MarkdownInlineUnknown) {
                return model ; // return blkModel
            }
        }
    }
    return nil ;
}

// Returns the para before this position's para
- (MarkdownModel *)lastParaModelForPosition:(NSUInteger)position {
    id lastModel = nil ;
    for (int i = 0; i < self.paraList.count; i++) {
        MarkdownModel *model = self.paraList[i] ;
        BOOL isInRange = NSLocationInRange(position, model.range) ;
        if (isInRange) {
            return lastModel ;
        }
        else {
            if (i > 0) {
                MarkdownModel *sygModel = self.paraList[i - 1] ;
                if (position > sygModel.range.location + sygModel.range.length &&
                    position < model.range.location) {
                    return sygModel ;
                }
            }
        }
        lastModel = model ;
    }
    return nil ;
}

- (NSString *)iconImageStringOfPosition:(NSUInteger)position
                                  model:(MarkdownModel *)model {
    
    if (model.type == MarkdownSyntaxHeaders) {
        // header
        if (!position) position++ ;
        
        NSString *lastString = [self.editAttrStr.string substringWithRange:NSMakeRange(position - 1, 1)] ;
        if ([lastString isEqualToString:@"\n"]) {
            return @"" ;
        }
    }
    return [model displayStringForLeftLabel] ;
}

@end
