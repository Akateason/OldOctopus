//
//  UIFont+RichTextEditor.h
//  Notebook
//
//  Created by teason23 on 2019/2/21.
//  Copyright © 2019 teason23. All rights reserved.

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>


@interface UIFont (RichTextEditor)

+ (NSString *)postscriptNameFromFullName:(NSString *)fullName;
+ (UIFont *)fontWithName:(NSString *)name size:(CGFloat)size boldTrait:(BOOL)isBold italicTrait:(BOOL)isItalic;
- (UIFont *)fontWithBoldTrait:(BOOL)bold italicTrait:(BOOL)italic andSize:(CGFloat)size;
- (UIFont *)fontWithBoldTrait:(BOOL)bold andItalicTrait:(BOOL)italic;
- (BOOL)isBold;
- (BOOL)isItalic;

@end
