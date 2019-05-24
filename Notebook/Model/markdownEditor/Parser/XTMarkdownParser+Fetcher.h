//
//  XTMarkdownParser+Fetcher.h
//  Notebook
//
//  Created by teason23 on 2019/4/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTMarkdownParser.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTMarkdownParser (Fetcher)

// pick one model in currentPositionModelList.  return the user choosen type First otherwise any model .
- (MarkdownModel *)modelForModelListInlineFirst ;
- (MarkdownModel *)modelForModelListBlockFirst ;

// return a blkModel with any position
- (MarkdownModel *)getBlkModelForCustomPosition:(NSUInteger)position ;
// Returns the para before any position
- (MarkdownModel *)lastParaModelForPosition:(NSUInteger)position ;


// left icon image String
- (NSString *)iconImageStringOfPosition:(NSUInteger)position
                                  model:(MarkdownModel *)model ;

@end

NS_ASSUME_NONNULL_END
