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
#import <XTlib/XTlib.h>
#import "NBRTEColorPickerView.h"


@interface NBRichTextEditor () <NBRTEToolbarDatasource, NBRTEToolbarDelegate>
@property (nonatomic, strong) NBRTEToolbar *toolBar;
@property (nonatomic, strong) NBRTEColorPickerView *colorPickerView;
// Gets set to YES when the user starts chaning attributes when there is no text selection (selecting bold, italic, etc)
// Gets set to NO  when the user changes selection or starts typing
@property (nonatomic, assign) BOOL typingAttributesInProgress;

@property (nonatomic) float heightForKeyboard;
@end


@implementation NBRichTextEditor

#pragma mark - init

- (id)init {
    if (self = [super init]) {
        [self commonInitialization];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInitialization];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInitialization];
    }

    return self;
}

- (void)commonInitialization {
    [self toolBar];
    self.typingAttributesInProgress = NO;
    self.defaultIndentationSize     = 15;

    // ToDo menu
    //    [self setupMenuItems];

    //If there is text already, then we do want to update the toolbar. Otherwise we don't.
    if ([self hasText]) [self updateToolbarState];

    //Keyboard noti
    [self setupKeyboardNotification];
}

- (void)setupKeyboardNotification {
    @weakify(self)
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *_Nullable x) {
            @strongify(self)
                NSDictionary *info = [x userInfo];
            CGSize kbSize          = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
            NSLog(@"keyboard changed, keyboard width = %f, height = %f", kbSize.width, kbSize.height);
            self.heightForKeyboard = kbSize.height;

            [self colorPickerView];
        }];
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
    // If no text exists or typing attributes is in progress update toolbar using typing attributes instead of selected text
    if (self.typingAttributesInProgress || ![self hasText]) {
        [self.toolBar updateStateWithAttributes:self.typingAttributes];
    }
    else {
        long location = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
        if (location == self.text.length) location--;

        [self.toolBar updateStateWithAttributes:[self.attributedText attributesAtIndex:location effectiveRange:nil]];
    }
}

#pragma mark - toolbar callback

- (RichTextEditorFeature)featuresEnabledForRichTextEditorToolbar {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(featuresEnabledForRichTextEditor:)]) {
        return [self.dataSource featuresEnabledForRichTextEditor:self];
    }
    return RichTextEditorFeatureAll;
}

- (void)toolbarButtonDidSelectCommonFeature:(RichTextEditorFeature)feature {
    switch (feature) {
        case RichTextEditorFeatureBold: {
            UIFont *font = [self fontAtIndex:self.selectedRange.location];
            [self applyFontAttributesToSelectedRangeWithBoldTrait:[NSNumber numberWithBool:![font isBold]] italicTrait:nil fontName:nil fontSize:nil];
        } break;
        case RichTextEditorFeatureItalic: {
            UIFont *font = [self fontAtIndex:self.selectedRange.location];
            [self applyFontAttributesToSelectedRangeWithBoldTrait:nil italicTrait:[NSNumber numberWithBool:![font isItalic]] fontName:nil fontSize:nil];
        } break;
        case RichTextEditorFeatureUnderline: {
            NSDictionary *dictionary         = [self dictionaryAtIndex:self.selectedRange.location];
            NSNumber *existingUnderlineStyle = [dictionary objectForKey:NSUnderlineStyleAttributeName];
            existingUnderlineStyle           = (!existingUnderlineStyle || existingUnderlineStyle.intValue == NSUnderlineStyleNone) ? [NSNumber numberWithInteger:NSUnderlineStyleSingle] : [NSNumber numberWithInteger:NSUnderlineStyleNone];
            [self applyAttrubutesToSelectedRange:existingUnderlineStyle forKey:NSUnderlineStyleAttributeName];
        } break;
        case RichTextEditorFeatureStrikeThrough: {
            NSDictionary *dictionary         = [self dictionaryAtIndex:self.selectedRange.location];
            NSNumber *existingUnderlineStyle = [dictionary objectForKey:NSStrikethroughStyleAttributeName];
            existingUnderlineStyle           = (!existingUnderlineStyle || existingUnderlineStyle.intValue == NSUnderlineStyleNone) ? [NSNumber numberWithInteger:NSUnderlineStyleSingle] : [NSNumber numberWithInteger:NSUnderlineStyleNone];
            [self applyAttrubutesToSelectedRange:existingUnderlineStyle forKey:NSStrikethroughStyleAttributeName];
        } break;
        case RichTextEditorFeatureParagraphFirstLineIndentation: {
            [self enumarateThroughParagraphsInRange:self.selectedRange withBlock:^(NSRange paragraphRange) {
                NSDictionary *dictionary                = [self dictionaryAtIndex:paragraphRange.location];
                NSMutableParagraphStyle *paragraphStyle = [[dictionary objectForKey:NSParagraphStyleAttributeName] mutableCopy];
                if (!paragraphStyle) paragraphStyle     = [[NSMutableParagraphStyle alloc] init];

                if (paragraphStyle.headIndent == paragraphStyle.firstLineHeadIndent)
                    paragraphStyle.firstLineHeadIndent += self.defaultIndentationSize;
                else
                    paragraphStyle.firstLineHeadIndent = paragraphStyle.headIndent;
                [self applyAttributes:paragraphStyle forKey:NSParagraphStyleAttributeName atRange:paragraphRange];
            }];
        } break;
        case RichTextEditorFeatureFontSize: {
        } break;
        case RichTextEditorFeatureFont: {
        } break;
        case RichTextEditorFeatureTextBackgroundColor: {
            for (UIView *window in [UIApplication sharedApplication].windows) {
                if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
                    [window addSubview:self.colorPickerView];
                    [self.colorPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.left.right.equalTo(window);
                        make.height.equalTo(@(self.heightForKeyboard));
                    }];
                }
            }
        } break;
        case RichTextEditorFeatureTextForegroundColor: {
        } break;

        default:
            break;
    }
}

- (void)toolbarButtonDidSelectParagraphIndent:(ParagraphIndentation)paragraphIndentation {
    [self enumarateThroughParagraphsInRange:self.selectedRange withBlock:^(NSRange paragraphRange) {
        NSDictionary *dictionary                = [self dictionaryAtIndex:paragraphRange.location];
        NSMutableParagraphStyle *paragraphStyle = [[dictionary objectForKey:NSParagraphStyleAttributeName] mutableCopy];

        if (!paragraphStyle) paragraphStyle = [[NSMutableParagraphStyle alloc] init];

        if (paragraphIndentation == ParagraphIndentationIncrease) {
            paragraphStyle.headIndent += self.defaultIndentationSize;
            paragraphStyle.firstLineHeadIndent += self.defaultIndentationSize;
        }
        else if (paragraphIndentation == ParagraphIndentationDecrease) {
            paragraphStyle.headIndent -= self.defaultIndentationSize;
            paragraphStyle.firstLineHeadIndent -= self.defaultIndentationSize;

            if (paragraphStyle.headIndent < 0) paragraphStyle.headIndent = 0;

            if (paragraphStyle.firstLineHeadIndent < 0) paragraphStyle.firstLineHeadIndent = 0;
        }

        [self applyAttributes:paragraphStyle forKey:NSParagraphStyleAttributeName atRange:paragraphRange];
    }];
}

- (void)toolbarButtonDidSelectTextAlignment:(NSTextAlignment)textAlignment {
    [self enumarateThroughParagraphsInRange:self.selectedRange withBlock:^(NSRange paragraphRange) {
        NSDictionary *dictionary                = [self dictionaryAtIndex:paragraphRange.location];
        NSMutableParagraphStyle *paragraphStyle = [[dictionary objectForKey:NSParagraphStyleAttributeName] mutableCopy];
        if (!paragraphStyle) paragraphStyle     = [[NSMutableParagraphStyle alloc] init];

        paragraphStyle.alignment = textAlignment;
        [self applyAttributes:paragraphStyle forKey:NSParagraphStyleAttributeName atRange:paragraphRange];
    }];
}

- (void)toolbarDidSelectShutDownKeyboard {
    [self resignFirstResponder];

    // remove color picker .
    if (self.colorPickerView.window) {
        [self.colorPickerView removeFromSuperview];
        self.colorPickerView = nil;
    }
}


#pragma mark - Override Methods -

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    [super setSelectedTextRange:selectedTextRange];

    [self updateToolbarState];
    self.typingAttributesInProgress = NO;
}

- (BOOL)canBecomeFirstResponder {
    if (![self.dataSource respondsToSelector:@selector(shouldDisplayToolbarForRichTextEditor:)] ||
        [self.dataSource shouldDisplayToolbarForRichTextEditor:self]) {
        self.inputAccessoryView = self.toolBar;

        // Redraw in case enabbled features have changes
        [self.toolBar redraw];
    }
    else {
        self.inputAccessoryView = nil;
    }

    return [super canBecomeFirstResponder];
}


// ToDo menu ...
//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    RichTextEditorFeature features = [self featuresEnabledForRichTextEditorToolbar];
//
//    if ([self.dataSource respondsToSelector:@selector(shouldDisplayRichTextOptionsInMenuControllerForRichTextEditor:)] &&
//        [self.dataSource shouldDisplayRichTextOptionsInMenuControllerForRichTextEditor:self])
//    {
//        if (action == @selector(richTextEditorToolbarDidSelectBold) && (features & RichTextEditorFeatureBold  || features & RichTextEditorFeatureAll))
//            return YES;
//
//        if (action == @selector(richTextEditorToolbarDidSelectItalic) && (features & RichTextEditorFeatureItalic  || features & RichTextEditorFeatureAll))
//            return YES;
//
//        if (action == @selector(richTextEditorToolbarDidSelectUnderline) && (features & RichTextEditorFeatureUnderline  || features & RichTextEditorFeatureAll))
//            return YES;
//
//        if (action == @selector(richTextEditorToolbarDidSelectStrikeThrough) && (features & RichTextEditorFeatureStrikeThrough  || features & RichTextEditorFeatureAll))
//            return YES;
//    }
//
//    if (action == @selector(selectParagraph:) && self.selectedRange.length > 0)
//        return YES;
//
//    return [super canPerformAction:action withSender:sender];
//}


- (NBRTEColorPickerView *)colorPickerView {
    if (!_colorPickerView) {
        _colorPickerView = ({
            NBRTEColorPickerView *object = [[NBRTEColorPickerView alloc] initWithHeight:self.heightForKeyboard toolBarHandler:self];
            object;
        });
    }
    return _colorPickerView;
}

- (NBRTEToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = ({
            NBRTEToolbar *object = [[NBRTEToolbar alloc] initWithFrame:CGRectMake(0, 0, [self currentScreenBoundsDependOnOrientation].size.width, 40) delegate:self dataSource:self];
            object;
        });
    }
    return _toolBar;
}

@end
