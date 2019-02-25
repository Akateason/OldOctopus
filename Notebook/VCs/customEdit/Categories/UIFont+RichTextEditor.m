//
//  UIFont+RichTextEditor.m
//  RichTextEdtor
//
//  Created by Aryan Gh on 7/21/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//
// https://github.com/aryaxt/iOS-Rich-Text-Editor
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIFont+RichTextEditor.h"


@implementation UIFont (RichTextEditor)

+ (NSString *)postscriptNameFromFullName:(NSString *)fullName {
    UIFont *font = [UIFont fontWithName:fullName size:1];
    return (__bridge NSString *)(CTFontCopyPostScriptName((__bridge CTFontRef)(font)));
}

+ (UIFont *)fontWithName:(NSString *)name size:(CGFloat)size boldTrait:(BOOL)isBold italicTrait:(BOOL)isItalic {
    NSMutableDictionary *tmpDic = [@{ UIFontDescriptorFamilyAttribute : name } mutableCopy];

    //    UIFont *oldApiFont = [self oldfontWithName:name size:size boldTrait:isBold] ;
    //    UIFontDescriptor *fontDescriptor = oldApiFont.fontDescriptor ;

    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:tmpDic];

    if (isBold) {
        //        fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] ;

        //        fontDescriptor = [fontDescriptor fontDescriptorWithFace:@"Bold"] ;

        //        NSDictionary *fontTraitsDictionary = @{UIFontWeightTrait : @(1.0)};
        //        [tmpDic setObject:fontTraitsDictionary forKey:UIFontDescriptorTraitsAttribute] ;

        [tmpDic setObject:@{ UIFontWeightTrait : @.4 } forKey:UIFontDescriptorTraitsAttribute];
    }
    else {
        [tmpDic setObject:@{ UIFontWeightTrait : @0 } forKey:UIFontDescriptorTraitsAttribute];
    }

    if (isItalic) {
        NSValue *matrix = [NSValue valueWithCGAffineTransform:CGAffineTransformIdentity];
        matrix          = [NSValue valueWithCGAffineTransform:CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0)];
        [tmpDic setObject:matrix forKey:UIFontDescriptorMatrixAttribute];
    }

    fontDescriptor = [fontDescriptor fontDescriptorByAddingAttributes:tmpDic];
    UIFont *font   = [UIFont fontWithDescriptor:fontDescriptor size:size];
    return font;
}

// core text old api
+ (UIFont *)oldfontWithName:(NSString *)name size:(CGFloat)size boldTrait:(BOOL)isBold {
    NSString *postScriptName = [UIFont postscriptNameFromFullName:name];

    CTFontSymbolicTraits traits = 0;
    CTFontRef newFontRef;
    CTFontRef fontWithoutTrait = CTFontCreateWithName((__bridge CFStringRef)(postScriptName), size, NULL);

    if (isBold)
        traits |= kCTFontBoldTrait;

    if (traits == 0) {
        newFontRef = CTFontCreateCopyWithAttributes(fontWithoutTrait, 0.0, NULL, NULL);
    }
    else {
        newFontRef = CTFontCreateCopyWithSymbolicTraits(fontWithoutTrait, 0.0, NULL, traits, traits);
    }

    if (newFontRef) {
        NSString *fontNameKey = (__bridge NSString *)(CTFontCopyName(newFontRef, kCTFontPostScriptNameKey));
        UIFont *font          = [UIFont fontWithName:fontNameKey size:CTFontGetSize(newFontRef)];
        CFRelease(newFontRef);
        return font;
    }
    return nil;
}


- (UIFont *)fontWithBoldTrait:(BOOL)bold italicTrait:(BOOL)italic andSize:(CGFloat)size {
    CTFontRef fontRef        = (__bridge CTFontRef)self;
    NSString *familyName     = (__bridge NSString *)(CTFontCopyName(fontRef, kCTFontFamilyNameKey));
    NSString *postScriptName = [UIFont postscriptNameFromFullName:familyName];
    return [[self class] fontWithName:postScriptName size:size boldTrait:bold italicTrait:italic];
}

- (UIFont *)fontWithBoldTrait:(BOOL)bold andItalicTrait:(BOOL)italic {
    return [self fontWithBoldTrait:bold italicTrait:italic andSize:self.pointSize];
}

- (BOOL)isBold {
    //    UIFontDescriptor *descroptor = self.fontDescriptor;
    //    BOOL isbold = (descroptor.symbolicTraits & UIFontDescriptorTraitBold) != 0;
    //    return isbold ;
    CTFontRef ctFont            = CTFontCreateWithName((__bridge CFStringRef)self.fontName, self.pointSize, NULL);
    CTFontSymbolicTraits traits = CTFontGetSymbolicTraits(ctFont);
    BOOL isBold                 = ((traits & kCTFontBoldTrait) == kCTFontBoldTrait);
    CFRelease(ctFont);
    return isBold;
}

- (BOOL)isItalic {
    UIFontDescriptor *descroptor = self.fontDescriptor;
    BOOL isItalic                = descroptor.fontAttributes[@"NSCTFontMatrixAttribute"] != nil;
    return isItalic;
}

@end
