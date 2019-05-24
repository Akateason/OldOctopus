//
//  XTMarkdownParser+ImageUtil.h
//  Notebook
//
//  Created by teason23 on 2019/4/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTMarkdownParser.h"

static NSString *const kKey_MDInlineImageModel = @"kKey_MDInlineImageModel" ;



@interface XTMarkdownParser (ImageUtil)

// get attachment
- (NSTextAttachment *)attachmentStandardFromImage:(UIImage *)image ;

// do when editor launch . (insert img placeholder)
- (NSMutableAttributedString *)readArticleFirstTimeAndInsertImagePHWhenEditorDidLaunching:(NSString *)text
                                                                                 textView:(UITextView *)textView ;

// in parse time . update image or download image.
- (NSMutableAttributedString *)updateImages:(NSString *)text
                                   textView:(UITextView *)textView ;


@end





@interface MDImageManager : NSObject

- (UIImage *)imagePlaceHolder ;

// download
- (void)imageWithUrlStr:(NSString *)urlStr
               complete:(void(^)(UIImage *image))complete ;

// upload
- (void)uploadImage:(UIImage *)image
           progress:(nullable void (^)(float))progressValueBlock
            success:(void (^)(NSURLResponse *response, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))fail ;

@end
