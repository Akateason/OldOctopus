//
//  NoteModel.m
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "NoteModel.h"
#import <UIKit/UIKit.h>
#import <XTlib/XTlib.h>

@implementation NoteModel
@synthesize htmlString = _htmlString ;

- (void)setHtmlString:(NSString *)htmlString {
    _htmlString = htmlString ;
    
    _base64HtmlString = [htmlString base64EncodedString] ;
}

- (NSString *)htmlString {
    return [self.base64HtmlString base64DecodedString] ;
}

+ (NSArray *)ignoreProperties {
    return @[@"htmlString"] ;
}

+ (NSString *)getHTMLWithAttributedString:(NSAttributedString *)attributedString {
    NSDictionary *exportParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSData *htmlData = [attributedString dataFromRange:NSMakeRange(0, attributedString.length) documentAttributes:exportParams error:nil];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"pt;" withString:@"px;"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"pt}" withString:@"px}"];
    return htmlString;
}

+ (NSAttributedString *)getAttributedStringWithHTML:(NSString *)htmlString{
    NSData *htmltest = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *importParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSAttributedString *attString = [[NSAttributedString alloc] initWithData:htmltest options:importParams documentAttributes:nil error:nil];
    return attString;
}

@end
