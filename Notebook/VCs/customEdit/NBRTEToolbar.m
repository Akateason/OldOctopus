//
//  NBRTEToolbar.m
//  Notebook
//
//  Created by teason23 on 2019/2/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "NBRTEToolbar.h"
#import <CoreText/CoreText.h>
#import "UIFont+RichTextEditor.h"


@interface NBRTEToolbar ()

@property (nonatomic, strong) UIButton *btnBold;
@property (nonatomic, strong) UIButton *btnItalic;
@property (nonatomic, strong) UIButton *btnUnderline;
@property (nonatomic, strong) UIButton *btnStrikeThrough;
@property (nonatomic, strong) UIButton *btnFontSize;
@property (nonatomic, strong) UIButton *btnFont;
@property (nonatomic, strong) UIButton *btnBackgroundColor;
@property (nonatomic, strong) UIButton *btnForegroundColor;
@property (nonatomic, strong) UIButton *btnTextAlignmentLeft;
@property (nonatomic, strong) UIButton *btnTextAlignmentCenter;
@property (nonatomic, strong) UIButton *btnTextAlignmentRight;
@property (nonatomic, strong) UIButton *btnTextAlignmentJustified;
@property (nonatomic, strong) UIButton *btnParagraphIndent;
@property (nonatomic, strong) UIButton *btnParagraphOutdent;
@property (nonatomic, strong) UIButton *btnParagraphFirstLineHeadIndent;
@property (nonatomic, strong) UIButton *btnBulletPoint;

@end


@implementation NBRTEToolbar


#pragma mark - Initialization -

- (id)initWithFrame:(CGRect)frame
           delegate:(id<NBRTEToolbarDelegate>)delegate
         dataSource:(id<NBRTEToolbarDatasource>)dataSource {
    if (self = [super initWithFrame:frame]) {
        self.tb_Delegate   = delegate;
        self.tb_Datasource = dataSource;

        self.backgroundColor   = [UIColor orangeColor];
        self.layer.borderWidth = .7;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;

        [self initializeButtons];
        [self populateToolbar];
    }

    return self;
}

#pragma mark - Public Methods -

- (void)redraw {
    [self populateToolbar];
}

- (void)updateStateWithAttributes:(NSDictionary *)attributes {
    UIFont *font                    = [attributes objectForKey:NSFontAttributeName];
    NSParagraphStyle *paragraphTyle = [attributes objectForKey:NSParagraphStyleAttributeName];

    //    [self.btnFontSize setTitle:[NSString stringWithFormat:@"%.f", font.pointSize] forState:UIControlStateNormal];
    //    [self.btnFont setTitle:font.familyName forState:UIControlStateNormal];

    self.btnBold.selected   = [font isBold];
    self.btnItalic.selected = [font isItalic];

    self.btnTextAlignmentLeft.selected            = NO;
    self.btnTextAlignmentCenter.selected          = NO;
    self.btnTextAlignmentRight.selected           = NO;
    self.btnTextAlignmentJustified.selected       = NO;
    self.btnParagraphFirstLineHeadIndent.selected = (paragraphTyle.firstLineHeadIndent > paragraphTyle.headIndent) ? YES : NO;

    switch (paragraphTyle.alignment) {
        case NSTextAlignmentLeft:
            self.btnTextAlignmentLeft.selected = YES;
            break;
        case NSTextAlignmentCenter:
            self.btnTextAlignmentCenter.selected = YES;
            break;

        case NSTextAlignmentRight:
            self.btnTextAlignmentRight.selected = YES;
            break;

        case NSTextAlignmentJustified:
            self.btnTextAlignmentJustified.selected = YES;
            break;

        default:
            self.btnTextAlignmentLeft.selected = YES;
            break;
    }

    NSNumber *existingUnderlineStyle = [attributes objectForKey:NSUnderlineStyleAttributeName];
    self.btnUnderline.selected       = (!existingUnderlineStyle || existingUnderlineStyle.intValue == NSUnderlineStyleNone) ? NO : YES;

    NSNumber *existingStrikeThrough = [attributes objectForKey:NSStrikethroughStyleAttributeName];
    self.btnStrikeThrough.selected  = (!existingStrikeThrough || existingStrikeThrough.intValue == NSUnderlineStyleNone) ? NO : YES;
}

#pragma mark - IBActions -

- (void)boldSelected:(UIButton *)sender {
    [self.tb_Delegate toolbarButtonDidSelectCommonFeature:RichTextEditorFeatureBold];
}

- (void)italicSelected:(UIButton *)sender {
    [self.tb_Delegate toolbarButtonDidSelectCommonFeature:RichTextEditorFeatureItalic];
}

- (void)underLineSelected:(UIButton *)sender {
    [self.tb_Delegate toolbarButtonDidSelectCommonFeature:RichTextEditorFeatureUnderline];
}

- (void)strikeThroughSelected:(UIButton *)sender {
    [self.tb_Delegate toolbarButtonDidSelectCommonFeature:RichTextEditorFeatureStrikeThrough];
}

- (void)bulletPointSelected:(UIButton *)sender {
    //[self.tb_Delegate toolbarButtonDidSelectCommonFeature:bull];
}

- (void)paragraphIndentSelected:(UIButton *)sender {
    [self.tb_Delegate toolbarButtonDidSelectParagraphIndent:ParagraphIndentationIncrease];
}

- (void)paragraphOutdentSelected:(UIButton *)sender {
    [self.tb_Delegate toolbarButtonDidSelectParagraphIndent:ParagraphIndentationDecrease];
}

- (void)paragraphHeadIndentOutdentSelected:(UIButton *)sender {
    [self.tb_Delegate toolbarButtonDidSelectCommonFeature:RichTextEditorFeatureParagraphFirstLineIndentation];
}

- (void)fontSizeSelected:(UIButton *)sender {
    [self.tb_Delegate toolbarButtonDidSelectCommonFeature:RichTextEditorFeatureFontSize];
}

- (void)fontSelected:(UIButton *)sender {
    [self.tb_Delegate toolbarButtonDidSelectCommonFeature:RichTextEditorFeatureFont];
}

- (void)textBackgroundColorSelected:(UIButton *)sender {
    [self.tb_Delegate toolbarButtonDidSelectCommonFeature:RichTextEditorFeatureTextBackgroundColor];
}

- (void)textForegroundColorSelected:(UIButton *)sender {
    [self.tb_Delegate toolbarButtonDidSelectCommonFeature:RichTextEditorFeatureTextForegroundColor];
}

- (void)textAlignmentSelected:(UIButton *)sender {
    NSTextAlignment textAlignment = NSTextAlignmentLeft;

    if (sender == self.btnTextAlignmentLeft)
        textAlignment = NSTextAlignmentLeft;
    else if (sender == self.btnTextAlignmentCenter)
        textAlignment = NSTextAlignmentCenter;
    else if (sender == self.btnTextAlignmentRight)
        textAlignment = NSTextAlignmentRight;
    else if (sender == self.btnTextAlignmentJustified)
        textAlignment = NSTextAlignmentJustified;

    [self.tb_Delegate toolbarButtonDidSelectTextAlignment:textAlignment];
}

#pragma mark - Private Methods -

- (void)populateToolbar {
    // Remove any existing subviews.
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }

    // Populate the toolbar with the given features.
    RichTextEditorFeature features = [self.tb_Datasource featuresEnabledForRichTextEditorToolbar];
    UIView *lastAddedView          = nil;

    self.hidden = (features == RichTextEditorFeatureNone);
    if (self.hidden) return;

    // Font selection
    if (features & RichTextEditorFeatureFont || features & RichTextEditorFeatureAll) {
        UIView *separatorView = [self separatorView];
        [self addView:self.btnFont afterView:lastAddedView withSpacing:YES];
        [self addView:separatorView afterView:self.btnFont withSpacing:YES];
        lastAddedView = separatorView;
    }

    // Font size
    if (features & RichTextEditorFeatureFontSize || features & RichTextEditorFeatureAll) {
        UIView *separatorView = [self separatorView];
        [self addView:self.btnFontSize afterView:lastAddedView withSpacing:YES];
        [self addView:separatorView afterView:self.btnFontSize withSpacing:YES];
        lastAddedView = separatorView;
    }

    // Bold
    if (features & RichTextEditorFeatureBold || features & RichTextEditorFeatureAll) {
        [self addView:self.btnBold afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnBold;
    }

    // Italic
    if (features & RichTextEditorFeatureItalic || features & RichTextEditorFeatureAll) {
        [self addView:self.btnItalic afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnItalic;
    }

    // Underline
    if (features & RichTextEditorFeatureUnderline || features & RichTextEditorFeatureAll) {
        [self addView:self.btnUnderline afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnUnderline;
    }

    // Strikethrough
    if (features & RichTextEditorFeatureStrikeThrough || features & RichTextEditorFeatureAll) {
        [self addView:self.btnStrikeThrough afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnStrikeThrough;
    }

    // Separator view after font properties.
    if (features & RichTextEditorFeatureBold || features & RichTextEditorFeatureItalic || features & RichTextEditorFeatureUnderline || features & RichTextEditorFeatureStrikeThrough || features & RichTextEditorFeatureAll) {
        UIView *separatorView = [self separatorView];
        [self addView:separatorView afterView:lastAddedView withSpacing:YES];
        lastAddedView = separatorView;
    }

    // Align left
    if (features & RichTextEditorFeatureTextAlignmentLeft || features & RichTextEditorFeatureAll) {
        [self addView:self.btnTextAlignmentLeft afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnTextAlignmentLeft;
    }

    // Align center
    if (features & RichTextEditorFeatureTextAlignmentCenter || features & RichTextEditorFeatureAll) {
        [self addView:self.btnTextAlignmentCenter afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnTextAlignmentCenter;
    }

    // Align right
    if (features & RichTextEditorFeatureTextAlignmentRight || features & RichTextEditorFeatureAll) {
        [self addView:self.btnTextAlignmentRight afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnTextAlignmentRight;
    }

    // Align justified
    if (features & RichTextEditorFeatureTextAlignmentJustified || features & RichTextEditorFeatureAll) {
        [self addView:self.btnTextAlignmentJustified afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnTextAlignmentJustified;
    }

    // Separator view after alignment section
    if (features & RichTextEditorFeatureTextAlignmentLeft || features & RichTextEditorFeatureTextAlignmentCenter || features & RichTextEditorFeatureTextAlignmentRight || features & RichTextEditorFeatureTextAlignmentJustified || features & RichTextEditorFeatureAll) {
        UIView *separatorView = [self separatorView];
        [self addView:separatorView afterView:lastAddedView withSpacing:YES];
        lastAddedView = separatorView;
    }

    // Paragraph indentation
    if (features & RichTextEditorFeatureParagraphIndentation || features & RichTextEditorFeatureAll) {
        [self addView:self.btnParagraphOutdent afterView:lastAddedView withSpacing:YES];
        [self addView:self.btnParagraphIndent afterView:self.btnParagraphOutdent withSpacing:YES];
        lastAddedView = self.btnParagraphIndent;
    }

    // Paragraph first line indentation
    if (features & RichTextEditorFeatureParagraphFirstLineIndentation || features & RichTextEditorFeatureAll) {
        [self addView:self.btnParagraphFirstLineHeadIndent afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnParagraphFirstLineHeadIndent;
    }

    // Separator view after Indentation
    if (features & RichTextEditorFeatureParagraphIndentation || features & RichTextEditorFeatureParagraphFirstLineIndentation || features & RichTextEditorFeatureAll) {
        UIView *separatorView = [self separatorView];
        [self addView:separatorView afterView:lastAddedView withSpacing:YES];
        lastAddedView = separatorView;
    }

    // Background color
    if (features & RichTextEditorFeatureTextBackgroundColor || features & RichTextEditorFeatureAll) {
        [self addView:self.btnBackgroundColor afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnBackgroundColor;
    }

    // Text color
    if (features & RichTextEditorFeatureTextForegroundColor || features & RichTextEditorFeatureAll) {
        [self addView:self.btnForegroundColor afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnForegroundColor;
    }

    // Separator view after color section
    if (features & RichTextEditorFeatureTextBackgroundColor || features & RichTextEditorFeatureTextForegroundColor || features & RichTextEditorFeatureAll) {
        UIView *separatorView = [self separatorView];
        [self addView:separatorView afterView:lastAddedView withSpacing:YES];
        lastAddedView = separatorView;
    }
}

- (void)initializeButtons {
    self.btnFont = [self buttonWithTitle:@"Font"
                             andSelector:@selector(fontSelected:)];

    self.btnFontSize = [self buttonWithTitle:@"Size"
                                 andSelector:@selector(fontSizeSelected:)];

    self.btnBold = [self buttonWithTitle:@"B"
                             andSelector:@selector(boldSelected:)];


    self.btnItalic = [self buttonWithTitle:@"I"
                               andSelector:@selector(italicSelected:)];


    self.btnUnderline = [self buttonWithTitle:@"U"
                                  andSelector:@selector(underLineSelected:)];

    self.btnStrikeThrough = [self buttonWithTitle:@"划线"
                                      andSelector:@selector(strikeThroughSelected:)];


    self.btnTextAlignmentLeft = [self buttonWithTitle:@"aL"
                                          andSelector:@selector(textAlignmentSelected:)];


    self.btnTextAlignmentCenter = [self buttonWithTitle:@"aC"
                                            andSelector:@selector(textAlignmentSelected:)];


    self.btnTextAlignmentRight = [self buttonWithTitle:@"aR"
                                           andSelector:@selector(textAlignmentSelected:)];

    self.btnTextAlignmentJustified = [self buttonWithTitle:@"aFull"
                                               andSelector:@selector(textAlignmentSelected:)];

    self.btnForegroundColor = [self buttonWithTitle:@"foreColor"
                                        andSelector:@selector(textForegroundColorSelected:)];

    self.btnBackgroundColor = [self buttonWithTitle:@"backColor"
                                        andSelector:@selector(textBackgroundColorSelected:)];

    self.btnBulletPoint = [self buttonWithTitle:@"bullet"
                                    andSelector:@selector(bulletPointSelected:)];

    self.btnParagraphIndent = [self buttonWithTitle:@"indent"
                                        andSelector:@selector(paragraphIndentSelected:)];

    self.btnParagraphOutdent = [self buttonWithTitle:@"outdent"
                                         andSelector:@selector(paragraphOutdentSelected:)];

    self.btnParagraphFirstLineHeadIndent = [self buttonWithTitle:@"1stLineIndent"
                                                     andSelector:@selector(paragraphHeadIndentOutdentSelected:)];
}

- (UIButton *)buttonWithTitle:(NSString *)title andSelector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 50, 0)];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [button.titleLabel setTextColor:[UIColor blackColor]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];

    return button;
}


- (UIView *)separatorView {
    UIView *view         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.frame.size.height)];
    view.backgroundColor = [UIColor lightGrayColor];

    return view;
}

#define ITEM_SEPARATOR_SPACE 5
#define ITEM_TOP_AND_BOTTOM_BORDER 5

- (void)addView:(UIView *)view afterView:(UIView *)otherView withSpacing:(BOOL)space {
    CGRect otherViewRect = (otherView) ? otherView.frame : CGRectZero;
    CGRect rect          = view.frame;
    rect.origin.x        = otherViewRect.size.width + otherViewRect.origin.x;
    if (space)
        rect.origin.x += ITEM_SEPARATOR_SPACE;

    rect.origin.y         = ITEM_TOP_AND_BOTTOM_BORDER;
    rect.size.height      = self.frame.size.height - (2 * ITEM_TOP_AND_BOTTOM_BORDER);
    view.frame            = rect;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    [self addSubview:view];
    [self updateContentSize];
}

- (void)updateContentSize {
    NSInteger maxViewlocation = 0;

    for (UIView *view in self.subviews) {
        NSInteger endLocation = view.frame.size.width + view.frame.origin.x;

        if (endLocation > maxViewlocation)
            maxViewlocation = endLocation;
    }

    self.contentSize = CGSizeMake(maxViewlocation + ITEM_SEPARATOR_SPACE, self.frame.size.height);
}

@end
