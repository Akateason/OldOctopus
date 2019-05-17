//
//  XTMarkdownParser+ImageUtil.m
//  Notebook
//
//  Created by teason23 on 2019/4/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTMarkdownParser+ImageUtil.h"
#import "MDThemeConfiguration.h"
#import "model/MdInlineModel.h"
#import "MarkdownEditor.h"
#import "MDImageManager.h"

@implementation XTMarkdownParser (ImageUtil)

- (NSTextAttachment *)attachmentStandardFromImage:(UIImage *)image {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init] ;
    attachment.image             = image ;
    CGFloat tvWid                = APP_WIDTH - 10 - kMDEditor_FlexValue ;
    CGSize resultImgSize         = CGSizeMake(tvWid, tvWid / image.size.width * image.size.height) ;
    CGRect rect                  = (CGRect){CGPointZero, resultImgSize};
    attachment.bounds            = rect;
    return attachment ;
}

- (NSAttributedString *)attrbuteStringWithInlineImageModel:(MdInlineModel *)model image:(UIImage *)image {
    NSTextAttachment *attach = [self attachmentStandardFromImage:image] ;
    NSMutableAttributedString *attrAttach = [[NSAttributedString attributedStringWithAttachment:attach] mutableCopy] ;
//    NSLog(@"img json : %@",[model yy_modelToJSONObject]) ;
    NSMutableDictionary *jsonObj = [[model yy_modelToJSONObject] mutableCopy] ;
    [jsonObj setValue:@(model.location) forKey:@"location"] ;
    [jsonObj setValue:@(model.length) forKey:@"length"] ;
    
    [attrAttach addAttributes:@{kKey_MDInlineImageModel:[jsonObj yy_modelToJSONString]} range:NSMakeRange(0, attrAttach.length)] ;
    return attrAttach ;
}



// do when editor launch . (insert img placeholder)
- (NSMutableAttributedString *)readArticleFirstTimeAndInsertImagePHWhenEditorDidLaunching:(NSString *)text
                                                                                 textView:(UITextView *)textView {
    NSMutableArray *imageModelList = [@[] mutableCopy] ;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text] ;
    [str beginEditing] ;
    
    NSRegularExpression *expLink = regexp(MDIL_LINKS, NSRegularExpressionAnchorsMatchLines) ;
    NSArray *matsLink = [expLink matchesInString:text options:0 range:NSMakeRange(0, text.length)] ;
    for (NSTextCheckingResult *result in matsLink) {
        NSString *prefixCha = [[text substringWithRange:result.range] substringWithRange:NSMakeRange(0, 1)] ;
        if ([prefixCha isEqualToString:@"!"]) {
            MdInlineModel *resModel = [MdInlineModel modelWithType:MarkdownInlineImage range:result.range str:[text substringWithRange:result.range]] ;
            [imageModelList addObject:resModel] ;
        }
    }
    
    [imageModelList enumerateObjectsUsingBlock:^(MdInlineModel * _Nonnull imgModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *imgUrl = [imgModel imageUrl] ;
        
        NSInteger loc = imgModel.range.location + imgModel.range.length + idx ;
        UIImage *imgResult = [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:imgUrl] ;
        if (!imgResult) {
            imgResult = self.imgManager.imagePlaceHolder ;
        }
        NSAttributedString *attrAttach = [self attrbuteStringWithInlineImageModel:imgModel image:imgResult] ;
        [str insertAttributedString:attrAttach atIndex:loc] ;
        
    }] ;
    
    [str endEditing] ;
    [self updateAttributedText:str textView:textView] ;
    
    return str ;
}

// in parse time . update image or download image.
- (NSMutableAttributedString *)updateImages:(NSString *)text
                                   textView:(UITextView *)textView {
    
    NSMutableArray *imageModelList = [@[] mutableCopy] ;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text] ;
    [str beginEditing] ;
    
    NSRegularExpression *expLink = regexp(MDIL_LINKS, NSRegularExpressionAnchorsMatchLines) ;
    NSArray *matsLink = [expLink matchesInString:text options:0 range:NSMakeRange(0, text.length)] ;
    for (NSTextCheckingResult *result in matsLink) {
        NSString *prefixCha = [[text substringWithRange:result.range] substringWithRange:NSMakeRange(0, 1)] ;
        if ([prefixCha isEqualToString:@"!"]) {
            MdInlineModel *resModel = [MdInlineModel modelWithType:MarkdownInlineImage range:result.range str:[text substringWithRange:result.range]] ;
            [imageModelList addObject:resModel] ;
        }
    }
    
    [imageModelList enumerateObjectsUsingBlock:^(MdInlineModel * _Nonnull imgModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *imgUrl = [imgModel imageUrl] ;
        
        NSInteger loc = imgModel.range.location + imgModel.range.length ;
        UIImage *imgResult = [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:imgUrl] ;
        if (!imgResult) {
            imgResult = self.imgManager.imagePlaceHolder ;
            @weakify(self)
            [self.imgManager imageWithUrlStr:imgUrl complete:^(UIImage * _Nonnull image) {
                @strongify(self)
                
                [str beginEditing] ;
                NSAttributedString *attrAttach = [self attrbuteStringWithInlineImageModel:imgModel image:imgResult] ;
                [str replaceCharactersInRange:NSMakeRange(loc, 1) withAttributedString:attrAttach] ;
                [str endEditing] ;

                [self parseTextAndGetModelsInCurrentCursor:str.string textView:textView] ;
            }] ;
        }
        
        NSAttributedString *attrAttach = [self attrbuteStringWithInlineImageModel:imgModel image:imgResult] ;
        [str replaceCharactersInRange:NSMakeRange(loc, 1) withAttributedString:attrAttach] ;
    }] ;
    [str endEditing] ;
    
    return str ;
}


@end
