//
//  XTMarkdownParser+Fetcher.m
//  Notebook
//
//  Created by teason23 on 2019/4/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTMarkdownParser+Fetcher.h"
#import "MarkdownModel.h"

@implementation XTMarkdownParser (Fetcher)

#pragma mark - return current model with position

NS_INLINE BOOL xt_LocationInRange(NSUInteger loc, NSRange range) {
    return ((loc >= range.location) && (loc - range.location) <= range.length) ? YES : NO;
}

- (MarkdownModel *)modelForModelListInlineFirst {
    MarkdownModel *tmpModel = nil ;
    NSRange cursorRange = [self.delegate currentCursorRange] ;
    NSArray *modellist = self.currentPositionModelList ;
    
    for (MarkdownModel *model in modellist) {
        tmpModel = model ;
        if (model.type > MarkdownInlineUnknown && ( xt_LocationInRange(cursorRange.location, model.range) || xt_LocationInRange(cursorRange.location - 1, model.range) ) ) {
            return model ;
        }
    }
    
    if (tmpModel.type == -1 && tmpModel.inlineModels.count > 0) {
        for (int i = 0; i < tmpModel.inlineModels.count; i++) {
            MarkdownModel *inlineModel = tmpModel.inlineModels[i] ;
            if (inlineModel.type > MarkdownInlineUnknown &&  ( xt_LocationInRange(cursorRange.location, inlineModel.range) || xt_LocationInRange(cursorRange.location - 1, inlineModel.range) ) ) {
                return inlineModel ;
            }
        }
    }
    return tmpModel ;
}

- (MarkdownModel *)modelForModelListBlockFirst {
    MarkdownModel *tmpModel = nil ;
    NSRange cursorRange = [self.delegate currentCursorRange] ;
    NSArray *modellist = self.currentPositionModelList ;
    
    for (MarkdownModel *model in modellist) {
        tmpModel = model ;
        if (model.type < MarkdownInlineUnknown && xt_LocationInRange(cursorRange.location, model.range)) {
            return tmpModel ;
        }
    }
    return tmpModel ;
}

- (MarkdownModel *)getBlkModelForCustomPosition:(NSUInteger)position {
    NSArray *list = self.paraList ;
    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        BOOL isInRange = xt_LocationInRange(position, model.range) ;
        
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
        BOOL isInRange = xt_LocationInRange(position, model.range) ;
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
