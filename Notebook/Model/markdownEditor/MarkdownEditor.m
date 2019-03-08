//
//  MarkdownEditor.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownEditor.h"
#import "MarkdownPaser.h"

@interface MarkdownEditor ()
@property(nonatomic, strong) MarkdownPaser *markdownPaser  ;

@end

@implementation MarkdownEditor

#pragma -

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationDidTextChangeText:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
    [self updateSyntax];
//    [KOKeyboardRow applyToTextView:self];
}

- (id)initWithCoder:(NSCoder *) coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup] ;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup] ;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup] ;
    }
    return self;
}

- (void)notificationDidTextChangeText:(id)sender {
    [self updateSyntax];
}

- (void)updateSyntax {
    NSArray *models = [self.markdownPaser syntaxModelsForText:self.text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    for (MarkdownModel *model in models) {
        [attributedString addAttributes:AttributesFromMarkdownSyntaxType(model.type)
                                  range:model.range];
    }
    [self updateAttributedText:attributedString];
}

- (void)updateAttributedText:(NSAttributedString *) attributedString {
    self.scrollEnabled = NO;
    NSRange selectedRange = self.selectedRange;
    self.attributedText = attributedString;
    self.selectedRange = selectedRange;
    self.scrollEnabled = YES;
}

#pragma - props

- (MarkdownPaser *)markdownPaser {
    if (_markdownPaser == nil) {
        _markdownPaser = [[MarkdownPaser alloc] init];
    }
    return _markdownPaser;
}



@end




