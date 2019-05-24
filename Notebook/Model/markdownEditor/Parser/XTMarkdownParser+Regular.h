//
//  XTMarkdownParser+Regular.h
//  Notebook
//
//  Created by teason23 on 2019/4/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTMarkdownParser.h"


NS_ASSUME_NONNULL_BEGIN

@interface XTMarkdownParser (Regular)

- (NSRegularExpression *)getRegularExpressionFromMarkdownSyntaxType:(MarkdownSyntaxType)type ;

- (NSRegularExpression *)getRegularExpressionFromMarkdownInlineType:(MarkdownInlineType)type ;


@end

NS_ASSUME_NONNULL_END
