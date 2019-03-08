//
//  MarkdownModel.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MarkdownPaser ;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MarkdownSyntaxType){
    MarkdownSyntaxUnknown,
    
    MarkdownSyntaxHeaders_h1,
    MarkdownSyntaxHeaders_h2,
    MarkdownSyntaxHeaders_h3,
    MarkdownSyntaxHeaders_h4,
    MarkdownSyntaxHeaders_h5,
    MarkdownSyntaxHeaders_h6,
    
    
    MarkdownSyntaxLinks,
    MarkdownSyntaxBold,
    MarkdownSyntaxEmphasis,
    MarkdownSyntaxDeletions,
    MarkdownSyntaxQuotes,
    MarkdownSyntaxInlineCode,
    MarkdownSyntaxCodeBlock,
    MarkdownSyntaxBlockquotes,
    MarkdownSyntaxULLists,
    MarkdownSyntaxOLLists,
    NumberOfMarkdownSyntax,
    
    // new
//    MD_Header_Type ,
    
};



@interface MarkdownModel : NSObject
@property(nonatomic) NSRange range;
@property(nonatomic) MarkdownSyntaxType type;

- (instancetype)initWithType:(enum MarkdownSyntaxType)type
                       range:(NSRange) range;

+ (instancetype)modelWithType:(enum MarkdownSyntaxType)type
                        range:(NSRange) range;
@end

NS_ASSUME_NONNULL_END
