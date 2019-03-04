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
#import "UIFont+RichTextEditor.h"


@interface NBRichTextEditor () <NBRTEToolbarDatasource,
                                NBRTEToolbarDelegate,
                                NBRTEColorPickerViewDelegate,
                                UITextViewDelegate>
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
    self.selectable                 = YES;
    self.editable                   = YES;
    self.delegate                   = self;

    // ToDo menu
    //    [self setupMenuItems];

    //If there is text already, then we do want to update the toolbar. Otherwise we don't.
    if ([self hasText]) [self updateToolbarState];

    //setup Keyboard Notification
    [self setupKeyboardNotification];
}

- (void)setupKeyboardNotification {
    @weakify(self)
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *_Nullable x) {
            @strongify(self)
                NSDictionary *info = [x userInfo];
            CGSize kbSize          = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

            // get keyboard height
            self.heightForKeyboard = kbSize.height;
            // setup colorpicker view .
            [self colorPickerView];
        }];
}

#pragma mark - apply attrs func

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
    NSDictionary *attr = @{};
    if (self.typingAttributesInProgress || ![self hasText]) {
        attr = self.typingAttributes;
    }
    else {
        long location = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
        if (location == self.text.length) location--;
        attr = [self.attributedText attributesAtIndex:location effectiveRange:nil];
    }

    [self.toolBar updateStateWithAttributes:attr];
    [self.colorPickerView updateStateByCurrentAttr:attr];
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
            [self.colorPickerView addColorPickerAboveKeyboardViewWithKeyboardHeight:self.heightForKeyboard type:NBRTEColorPickerView_typeTextBackGroundColor];
        } break;
        case RichTextEditorFeatureTextForegroundColor: {
            [self.colorPickerView addColorPickerAboveKeyboardViewWithKeyboardHeight:self.heightForKeyboard type:NBRTEColorPickerView_typeTextColor];
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

// todo .
- (void)toolbarDidSelectPhotoInsert {
    //    [self toolbarDidSelectShutDownKeyboard] ;

    UIImage *imgTest                       = [UIImage imageNamed:@"test"];
    NSMutableAttributedString *mutaAttrStr = [self.attributedText mutableCopy];
    //获取光标的位置
    NSRange range = self.selectedRange;
    //    NSLog(@"%lu %lu",(unsigned long)range.location,(unsigned long)range.length);
    //声明表情资源 NSTextAttachment类型
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image             = imgTest;
    CGFloat tvWid                = self.width - 10;
    CGSize resultImgSize         = CGSizeMake(tvWid, tvWid / imgTest.size.width * imgTest.size.height);
    CGRect rect                  = (CGRect){CGPointZero, resultImgSize};
    attachment.bounds            = rect;

    NSAttributedString *attrStr = [NSAttributedString attributedStringWithAttachment:attachment];
    [mutaAttrStr insertAttributedString:attrStr atIndex:range.location];
    self.attributedText = mutaAttrStr;
}

- (void)toolbarDidSelectLinkInsert {
    NSMutableAttributedString *mutaAttrStr = [self.attributedText mutableCopy];
    NSRange range                          = self.selectedRange;

    NSDictionary *dictAttr      = @{ NSLinkAttributeName : [NSURL URLWithString:@"http://www.baidu.com"] };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"百度123" attributes:dictAttr];
    [mutaAttrStr insertAttributedString:attrStr atIndex:range.location];
    self.attributedText = mutaAttrStr;
}

// remove keyboard
- (void)toolbarDidSelectShutDownKeyboard {
    [self resignFirstResponder];
}

#pragma mark - NBRTEColorPickerViewDelegate <NSObject>

- (void)onNBRTEColorPickerView:(NBRTEColorPickerView *)colorPicker didPickColor:(UIColor *)color type:(NBRTEColorPickerViewType)type {
    if (type == NBRTEColorPickerView_typeTextColor) {
        [self applyAttrubutesToSelectedRange:color forKey:NSForegroundColorAttributeName];
    }
    else if (type == NBRTEColorPickerView_typeTextBackGroundColor) {
        [self applyAttrubutesToSelectedRange:color forKey:NSBackgroundColorAttributeName];
    }
}

- (void)returnToKeyboard {
    self.colorPickerView = nil; // call dealloc ;
}

#pragma mark -

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    //在这里是可以做一些判定什么的，用来确定对应的操作。
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
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

#pragma mark - props

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
