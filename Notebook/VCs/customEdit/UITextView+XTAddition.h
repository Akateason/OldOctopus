//
//  UITextView+XTAddition.h
//  Notebook
//
//  Created by teason23 on 2019/2/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (XTAddition)

- (CGRect)frameOfTextAtRange:(NSRange)range ;

- (void)enumarateThroughParagraphsInRange:(NSRange)range withBlock:(void (^)(NSRange paragraphRange))block ;

- (NSRange)fullRangeFromArrayOfParagraphRanges:(NSArray *)paragraphRanges ;

- (UIFont *)fontAtIndex:(NSInteger)index ;

- (NSDictionary *)dictionaryAtIndex:(NSInteger)index ;

// Returns a font with given attributes. For any missing parameter takes the attribute from a given dictionary
- (UIFont *)fontwithBoldTrait:(NSNumber *)isBold italicTrait:(NSNumber *)isItalic fontName:(NSString *)fontName fontSize:(NSNumber *)fontSize fromDictionary:(NSDictionary *)dictionary ;

- (CGRect)currentScreenBoundsDependOnOrientation ;

@end

NS_ASSUME_NONNULL_END
