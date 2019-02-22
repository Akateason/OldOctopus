//
//  NBRichTextEditor.m
//  Notebook
//
//  Created by teason23 on 2019/2/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "NBRichTextEditor.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+RichTextEditor.h"
#import "NSAttributedString+RichTextEditor.h"
#import "UIView+RichTextEditor.h"
#import "UITextView+XTAddition.h"


@interface NBRichTextEditor ()
// Gets set to YES when the user starts chaning attributes when there is no text selection (selecting bold, italic, etc)
// Gets set to NO  when the user changes selection or starts typing
@property (nonatomic, assign) BOOL typingAttributesInProgress;
@end


@implementation NBRichTextEditor

- (void)setBold:(BOOL)isBold {
    UIFont *font = [self fontAtIndex:self.selectedRange.location];
    [self applyFontAttributesToSelectedRangeWithBoldTrait:[NSNumber numberWithBool:![font isBold]] italicTrait:nil fontName:nil fontSize:nil];
}


#pragma mark - apply attr

- (void)applyAttributeToTypingAttribute:(id)attribute
                                 forKey:(NSString *)key {
    NSMutableDictionary *dictionary = [self.typingAttributes mutableCopy];
    [dictionary setObject:attribute forKey:key];
    [self setTypingAttributes:dictionary];
}

- (void)applyAttributes:(id)attribute
                 forKey:(NSString *)key
                atRange:(NSRange)range {
    // If any text selected apply attributes to text
    if (range.length > 0) {
        NSMutableAttributedString *attributedString = [self.attributedText mutableCopy];

        // Workaround for when there is only one paragraph,
        // sometimes the attributedString is actually longer by one then the displayed text,
        // and this results in not being able to set to lef align anymore.
        if (range.length == attributedString.length - 1 && range.length == self.text.length)
            ++range.length;

        [attributedString addAttributes:[NSDictionary dictionaryWithObject:attribute forKey:key] range:range];

        [self setAttributedText:attributedString];
        [self setSelectedRange:range];
    }
    // If no text is selected apply attributes to typingAttribute
    else {
        self.typingAttributesInProgress = YES;
        [self applyAttributeToTypingAttribute:attribute forKey:key];
    }

    [self updateToolbarState];
}

- (void)applyAttrubutesToSelectedRange:(id)attribute
                                forKey:(NSString *)key {
    [self applyAttributes:attribute forKey:key atRange:self.selectedRange];
}

- (void)applyFontAttributesToSelectedRangeWithBoldTrait:(NSNumber *)isBold
                                            italicTrait:(NSNumber *)isItalic
                                               fontName:(NSString *)fontName
                                               fontSize:(NSNumber *)fontSize {
    [self applyFontAttributesWithBoldTrait:isBold italicTrait:isItalic fontName:fontName fontSize:fontSize toTextAtRange:self.selectedRange];
}

- (void)applyFontAttributesWithBoldTrait:(NSNumber *)isBold
                             italicTrait:(NSNumber *)isItalic
                                fontName:(NSString *)fontName
                                fontSize:(NSNumber *)fontSize
                           toTextAtRange:(NSRange)range {
    // If any text selected apply attributes to text
    if (range.length > 0) {
        NSMutableAttributedString *attributedString = [self.attributedText mutableCopy];

        [attributedString beginEditing];
        [attributedString enumerateAttributesInRange:range
                                             options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                          usingBlock:^(NSDictionary *dictionary, NSRange range, BOOL *stop) {

                                              UIFont *newFont = [self fontwithBoldTrait:isBold
                                                                            italicTrait:isItalic
                                                                               fontName:fontName
                                                                               fontSize:fontSize
                                                                         fromDictionary:dictionary];

                                              if (newFont)
                                                  [attributedString addAttributes:[NSDictionary dictionaryWithObject:newFont forKey:NSFontAttributeName] range:range];
                                          }];
        [attributedString endEditing];
        self.attributedText = attributedString;

        [self setSelectedRange:range];
    }
    // If no text is selected apply attributes to typingAttribute
    else {
        self.typingAttributesInProgress = YES;

        UIFont *newFont = [self fontwithBoldTrait:isBold
                                      italicTrait:isItalic
                                         fontName:fontName
                                         fontSize:fontSize
                                   fromDictionary:self.typingAttributes];
        if (newFont)
            [self applyAttributeToTypingAttribute:newFont forKey:NSFontAttributeName];
    }

    [self updateToolbarState];
}

#pragma mark - toolbar

- (void)updateToolbarState {
}


@end
