//
//  MdListModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MdListModel.h"
#import <XTlib/XTlib.h>

@implementation MdListModel

- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    
    switch (self.type) {
        case MarkdownSyntaxTaskLists:   str = @"tl" ; break ;
        case MarkdownSyntaxOLLists:     str = @"ol" ; break ;
        case MarkdownSyntaxULLists:     str = @"ul" ; break ;
        default: break;
    }
    
    return str ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString
                                              config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.basicStyle ;
    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;

    switch (self.type) {
        case MarkdownSyntaxOLLists: {
            [attributedString addAttributes:configuration.listStyle range:self.range] ;
            // number
            NSString *prefix = [[self.str componentsSeparatedByString:@"."] firstObject] ;
            NSUInteger lenOfMark = prefix.length + 1 ;
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:kDefaultFontSize]} ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, lenOfMark + 1)] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            [attributedString addAttributes:configuration.listStyle range:self.range] ;
            // bullet
            resultDic = @{NSFontAttributeName : [UIFont systemFontOfSize:20]} ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, 2)] ;
        }
            break ;
        case MarkdownSyntaxTaskLists: {
//            BOOL select = YES ;
//            NSInteger fontSize = kDefaultFontSize ;
//            UIImage *image = [UIImage imageNamed:select == YES ? @"check-box-on" : @"check-box-off"];
//            CGSize size = CGSizeMake(fontSize, fontSize);
//
//            UIGraphicsBeginImageContextWithOptions(size, false, 0);
//            [image drawInRect:CGRectMake(0, 2, size.width, size.height)];
//            UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//
//            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init] ;
//            textAttachment.image = resizeImage ;
//            NSMutableAttributedString *imageString = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy] ;
//            [imageString addAttribute:NSLinkAttributeName
//                                value:@"checkbox://"
//                                range:NSMakeRange(0, imageString.length)];
//
//            NSString *prefix = [[self.str componentsSeparatedByString:@"]"] firstObject] ;
//            [attributedString insertAttributedString:imageString atIndex:location + prefix.length + 1];
//
            
//            _textview.attributedText = attributedString;
//            _textview.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor],
//                                             NSUnderlineColorAttributeName: [UIColor lightGrayColor],
//                                             NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
            
//            _textview.delegate = self;
//            _textview.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
//            _textview.scrollEnabled = NO;
            
            resultDic = @{NSBackgroundColorAttributeName : [UIColor xt_facePink]} ;
            [attributedString addAttributes:resultDic range:self.range] ;
            

            

        }
            break ;
        
        default:
            break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                           config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.basicStyle ;
    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxOLLists: {
            [attributedString addAttributes:configuration.listStyle range:self.range] ;
            // number
            NSString *prefix = [[self.str componentsSeparatedByString:@"."] firstObject] ;
            NSUInteger lenOfMark = prefix.length + 1 ;
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:kDefaultFontSize],
                          NSForegroundColorAttributeName : configuration.markColor
                          } ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, lenOfMark + 1)] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            [attributedString addAttributes:configuration.listStyle range:self.range] ;
            // bullet
            resultDic = @{NSFontAttributeName : configuration.font ,
                          NSForegroundColorAttributeName : configuration.markColor
                          } ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, 2)] ;
       }
            break ;
        case MarkdownSyntaxTaskLists: {
//            resultDic = @{NSFontAttributeName : paragraphFont} ;
//            [attributedString addAttributes:resultDic range:self.range] ;
            
//            BOOL select = YES ;
//            NSInteger fontSize = kDefaultFontSize ;
//            UIImage *image = [UIImage imageNamed:select == YES ? @"check-box-on" : @"check-box-off"] ;
//            CGSize size = CGSizeMake(fontSize, fontSize) ;
//
//            UIGraphicsBeginImageContextWithOptions(size, false, 0);
//            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//            UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//
//            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init] ;
//            textAttachment.image = resizeImage ;
//            NSMutableAttributedString *imageString = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy] ;
//            [imageString addAttribute:NSLinkAttributeName
//                                value:@"checkbox://"
//                                range:NSMakeRange(0, imageString.length)] ;
//            [attributedString insertAttributedString:imageString atIndex:location];
            
        }
            break ;

            
            
        default:
            break;
    }
    
    return attributedString ;
}


@end
