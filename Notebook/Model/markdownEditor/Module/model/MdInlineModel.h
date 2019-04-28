//
//  MdInlineModel.h
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkdownModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MdInlineModel : MarkdownModel
//img
- (NSString *)imageUrl ;
//link
- (NSString *)linkTitle ;
- (NSString *)linkUrl ;





+ (void)toolbarEventDeletion:(MarkdownEditor *)editor ;
+ (void)toolbarEventCode:(MarkdownEditor *)editor ;

@end

NS_ASSUME_NONNULL_END
