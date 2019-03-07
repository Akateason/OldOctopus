//
//  UITextView+XTAddition.m
//  Notebook
//
//  Created by teason23 on 2019/2/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "UITextView+XTAddition.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+RichTextEditor.h"
#import "NSAttributedString+RichTextEditor.h"
#import "UIView+RichTextEditor.h"


@implementation UITextView (XTAddition)

- (CGRect)frameOfTextAtRange:(NSRange)range {
    UITextRange *selectionRange = [self selectedTextRange];
    NSArray *selectionRects     = [self selectionRectsForRange:selectionRange];
    CGRect completeRect         = CGRectNull;

    for (UITextSelectionRect *selectionRect in selectionRects) {
        completeRect = (CGRectIsNull(completeRect)) ? selectionRect.rect : CGRectUnion(completeRect, selectionRect.rect);
    }

    return completeRect;
}

- (void)enumarateThroughParagraphsInRange:(NSRange)range withBlock:(void (^)(NSRange paragraphRange))block {
    if (![self hasText])
        return;

    NSArray *rangeOfParagraphsInSelectedText = [self.attributedText rangeOfParagraphsFromTextRange:self.selectedRange];

    for (int i = 0; i < rangeOfParagraphsInSelectedText.count; i++) {
        NSValue *value         = [rangeOfParagraphsInSelectedText objectAtIndex:i];
        NSRange paragraphRange = [value rangeValue];
        block(paragraphRange);
    }

    NSRange fullRange = [self fullRangeFromArrayOfParagraphRanges:rangeOfParagraphsInSelectedText];
    [self setSelectedRange:fullRange];
}

- (NSRange)fullRangeFromArrayOfParagraphRanges:(NSArray *)paragraphRanges {
    if (!paragraphRanges.count)
        return NSMakeRange(0, 0);

    NSRange firstRange = [[paragraphRanges objectAtIndex:0] rangeValue];
    NSRange lastRange  = [[paragraphRanges lastObject] rangeValue];
    return NSMakeRange(firstRange.location, lastRange.location + lastRange.length - firstRange.location);
}

- (UIFont *)fontAtIndex:(NSInteger)index {
    // If index at end of string, get attributes starting from previous character
    if (index == self.attributedText.string.length && [self hasText])
        --index;

    // If no text exists get font from typing attributes
    NSDictionary *dictionary = ([self hasText]) ? [self.attributedText attributesAtIndex:index effectiveRange:nil] : self.typingAttributes;

    return [dictionary objectForKey:NSFontAttributeName];
}

- (NSDictionary *)dictionaryAtIndex:(NSInteger)index {
    // If index at end of string, get attributes starting from previous character
    if (index == self.attributedText.string.length && [self hasText])
        --index;

    // If no text exists get font from typing attributes
    return ([self hasText]) ? [self.attributedText attributesAtIndex:index effectiveRange:nil] : self.typingAttributes;
}

// Returns a font with given attributes. For any missing parameter takes the attribute from a given dictionary
- (UIFont *)fontwithBoldTrait:(NSNumber *)isBold italicTrait:(NSNumber *)isItalic fontName:(NSString *)fontName fontSize:(NSNumber *)fontSize fromDictionary:(NSDictionary *)dictionary {
    UIFont *newFont     = nil;
    UIFont *font        = [dictionary objectForKey:NSFontAttributeName];
    BOOL newBold        = (isBold) ? isBold.intValue : [font isBold];
    BOOL newItalic      = (isItalic) ? isItalic.intValue : [font isItalic];
    CGFloat newFontSize = (fontSize) ? fontSize.floatValue : font.pointSize;

    if (fontName) {
        newFont = [UIFont fontWithName:fontName size:newFontSize boldTrait:newBold italicTrait:newItalic];
    }
    else {
        newFont = [font fontWithBoldTrait:newBold italicTrait:newItalic andSize:newFontSize];
    }

    return newFont;
}

- (CGRect)currentScreenBoundsDependOnOrientation {
    CGRect screenBounds                         = [UIScreen mainScreen].bounds;
    CGFloat width                               = CGRectGetWidth(screenBounds);
    CGFloat height                              = CGRectGetHeight(screenBounds);
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;

    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        screenBounds.size = CGSizeMake(width, height);
    }
    else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        screenBounds.size = CGSizeMake(height, width);
    }

    return screenBounds;
}


@end
