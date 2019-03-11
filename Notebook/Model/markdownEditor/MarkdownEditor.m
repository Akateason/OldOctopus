//
//  MarkdownEditor.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownEditor.h"
#import "MarkdownPaser.h"

static const CGFloat kFlexValue = 30.f ;

@interface MarkdownEditor ()
@property(nonatomic, strong) MarkdownPaser *markdownPaser  ;

@end

@implementation MarkdownEditor

#pragma -

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup {
    self.font = [UIFont systemFontOfSize:16.] ;
    
    self.contentInset = UIEdgeInsetsMake(0, kFlexValue, 0, kFlexValue) ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationDidTextChangeText:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
    [self updateSyntax] ;
    
    self.contentOffset = CGPointZero ;
    
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
    [attributedString beginEditing];
    
    [attributedString addAttributes:Md_defaultStyle()
                              range:NSMakeRange(0, self.text.length)] ;
    
    for (MarkdownModel *model in models) {
        [attributedString addAttributes:AttributesFromMarkdownSyntaxType(model.type)
                                  range:model.range];
    }
    [attributedString endEditing];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateAttributedText:attributedString];
        self.contentOffset = CGPointZero ;
    }) ;
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




