//
//  NoteModel.h
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XTFMDB/XTFMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoteModel : NSObject

@property (nonatomic, copy) NSString *title ;
@property (nonatomic, copy) NSString *htmlString ;
@property (nonatomic, copy) NSString *base64HtmlString ;


+ (NSString *)getHTMLWithAttributedString:(NSAttributedString *)attributedString ;
+ (NSAttributedString *)getAttributedStringWithHTML:(NSString *)htmlString ;

@end

NS_ASSUME_NONNULL_END
