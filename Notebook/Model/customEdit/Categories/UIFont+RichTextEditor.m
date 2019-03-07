//
//  UIFont+RichTextEditor.m
//  Notebook
//
//  Created by teason23 on 2019/2/21.
//  Copyright © 2019 teason23. All rights reserved.


#import "UIFont+RichTextEditor.h"


@implementation UIFont (RichTextEditor)

+ (NSString *)postscriptNameFromFullName:(NSString *)fullName {
    UIFont *font = [UIFont fontWithName:fullName size:1];
    return (__bridge NSString *)(CTFontCopyPostScriptName((__bridge CTFontRef)(font)));
}

+ (UIFont *)fontWithName:(NSString *)name size:(CGFloat)size boldTrait:(BOOL)isBold italicTrait:(BOOL)isItalic {
    NSString *postScriptName = [UIFont postscriptNameFromFullName:name];

    CTFontSymbolicTraits traits = 0;
    CTFontRef newFontRef;
    CTFontRef fontWithoutTrait = CTFontCreateWithName((__bridge CFStringRef)(postScriptName), size, NULL);

    CGAffineTransform matrix = CGAffineTransformIdentity;
    if (isItalic) {
        //        traits |= kCTFontItalicTrait;
        matrix = CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0);
    }

    if (isBold) {
        traits |= kCTFontBoldTrait;
    }

    if (traits == 0) {
        newFontRef = CTFontCreateCopyWithAttributes(fontWithoutTrait, 0.0, NULL, NULL);
    }
    else {
        newFontRef = CTFontCreateCopyWithSymbolicTraits(fontWithoutTrait, 0.0, NULL, traits, traits);
    }

    CFRelease(fontWithoutTrait);

    if (newFontRef) {
        NSString *fontNameKey  = (__bridge NSString *)(CTFontCopyName(newFontRef, kCTFontPostScriptNameKey));
        UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:fontNameKey matrix:matrix];
        UIFont *resFont        = [UIFont fontWithDescriptor:desc size:CTFontGetSize(newFontRef)];
        CFRelease(newFontRef);
        return resFont;
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
