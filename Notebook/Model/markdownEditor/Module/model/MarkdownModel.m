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
    
    if (model.type == MarkdownSyntaxBlockquotes ||
        model.type == MarkdownSyntaxOLLists ||
        model.type == MarkdownSyntaxULLists) {
        
        XTMarkdownParser *parser = [XTMarkdownParser new] ;
        MarkdownModel *tmpModel = [model copy] ;
        NSString *prefix ;
        if (model.type == MarkdownSyntaxBlockquotes) {
            if (![tmpModel.str containsString:@">"]) return model ;
            prefix = [[tmpModel.str componentsSeparatedByString:@">"] firstObject] ;
        }
        else if (model.type == MarkdownSyntaxOLLists || model.type == MarkdownSyntaxULLists) {
            if (![tmpModel.str containsString:@"."] && ![tmpModel.str containsString:@"*"] ) return model ;
            prefix = [[tmpModel.str componentsSeparatedByString:@" "] firstObject] ;
        }
        
        tmpModel.str = [tmpModel.str substringFromIndex:prefix.length + 1] ;
        tmpModel.range = NSMakeRange(tmpModel.range.location + prefix.length + 1, tmpModel.range.length - prefix.length - 1) ;
        tmpModel.myLevel ++ ;
        MarkdownModel *subModel = [parser parsingGetABlockStyleModelFromParaModel:tmpModel] ;
        if (subModel.type <= NumberOfMarkdownSyntax && subModel.type > 0) {
            subModel.myLevel = tmpModel.myLevel ;
            model.subBlkModel = subModel ;
        }
        tmpModel = nil ;
    }
    
    return model ;
}

- (int)myLevel {
    int level = 0 ;
    MarkdownModel *tmpModel = self ;
    while (1) {
        if (
            tmpModel.subBlkModel &&
            (tmpModel.subBlkModel.type == MarkdownSyntaxBlockquotes
             || tmpModel.subBlkModel.type == MarkdownSyntaxOLLists
             || tmpModel.subBlkModel.type == MarkdownSyntaxULLists)
            ) {
            
            level ++ ;
            tmpModel = tmpModel.subBlkModel ;
        }
        else
            break ;
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
    p.myLevel = self.myLevel ;
    p.subBlkModel = self.subBlkModel ;
    return p ;
}

@end
