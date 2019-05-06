//
//  MarkdownModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownModel.h"
#import <XTlib/XTlib.h>
#import "XTMarkdownParser.h"

@implementation MarkdownModel

- (instancetype)initWithType:(int)type
                       range:(NSRange)range
                         str:(NSString *)str {
    self = [super init] ;
    if (self) {
        _type   = type;
        _range  = range;
        _str    = str ;
    }
    return self;
}

+ (instancetype)modelWithType:(int)type
                        range:(NSRange)range
                          str:(NSString *)str {
    
    MarkdownModel *model = [[self alloc] initWithType:type range:range str:str] ;
    // quote blk nest 针对行
    if (model.type == MarkdownSyntaxBlockquotes) {
        XTMarkdownParser *parser = [XTMarkdownParser new] ;
        MarkdownModel *tmpModel = [model copy] ;
        NSUInteger cutNumber = 0 ;
        NSString *newStr ;
        if (model.type == MarkdownSyntaxBlockquotes) {
            
            if (![tmpModel.str containsString:@">"]) return model ;
            NSString *prefix = [[tmpModel.str componentsSeparatedByString:@">"] firstObject] ;
            cutNumber = prefix.length ;
            newStr = [tmpModel.str substringFromIndex:cutNumber + 1] ;
            while ([newStr hasPrefix:@" "]) {
                newStr = [newStr substringFromIndex:1] ;
                cutNumber++ ;
            }
            
            tmpModel.quoteLevel ++ ;
            
            tmpModel.str = newStr ;
            tmpModel.range = NSMakeRange(tmpModel.range.location + cutNumber + 1, tmpModel.range.length - cutNumber - 1) ;
        }
        // 递归
        MarkdownModel *subModel = [parser parsingGetABlockStyleModelFromParaModel:tmpModel] ;
        if (subModel.type <= NumberOfMarkdownSyntax && subModel.type > 0) {
            subModel.quoteLevel = tmpModel.quoteLevel ;
            model.subBlkModel = subModel ;
        }
        tmpModel = nil ;
    }
    
    return model ;
}

- (int)quoteLevel {
    int level = 0 ;
    MarkdownModel *tmpModel = self ;
    if (self.type == MarkdownSyntaxBlockquotes) {
        while (1) {
            if (
                tmpModel.subBlkModel &&
                tmpModel.subBlkModel.type == MarkdownSyntaxBlockquotes
                 
                ) {
                level ++ ;
                tmpModel = tmpModel.subBlkModel ;
            }
            else break ;
        }
    }
    return level ;
}

- (int)nestLevel {
    int level = 0 ;
    MarkdownModel *tmpModel = self ;
    while (1) {
        if (
            tmpModel.subBlkModel &&
            (
             tmpModel.subBlkModel.type == MarkdownSyntaxBlockquotes ||
             tmpModel.subBlkModel.type == MarkdownSyntaxULLists ||
             tmpModel.subBlkModel.type == MarkdownSyntaxOLLists
             )
            ) {
            level ++ ;
            tmpModel = tmpModel.subBlkModel ;
        }
        else break ;
    }
    
    return level ;

}




- (NSString *)displayStringForLeftLabel {
    return @"" ;
}

- (NSUInteger)location {
    return self.range.location ;
}

- (NSUInteger)length {
    return self.range.length ;
}

- (UIFont *)defaultFont {
    return [MDThemeConfiguration sharedInstance].editorThemeObj.font ;
}

- (NSDictionary *)defultStyle {
    return MDThemeConfiguration.sharedInstance.editorThemeObj.basicStyle ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString
                                              {
//    if (self.type == -1) { // paragraph
//        NSDictionary *resultDic = @{NSBackgroundColorAttributeName : [[XTColorFetcher sharedInstance] randomColor]} ;
//        [attributedString addAttributes:resultDic range:self.range] ;
//    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition {
    return attributedString ;
}

- (id)copyWithZone:(NSZone *)zone {
    MarkdownModel *p = [[MarkdownModel allocWithZone:zone] init] ;
    p.range = self.range ;
    p.type = self.type ;
    p.str = [self.str mutableCopy] ;
    p.isOnEditState = self.isOnEditState ;
    p.inlineModels = [self.inlineModels mutableCopy] ;
    p.quoteLevel = self.quoteLevel ;
    p.subBlkModel = self.subBlkModel ;
    return p ;
}

@end
