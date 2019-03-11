//
//  MarkdownEditor.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownEditor.h"
#import "MarkdownPaser.h"
#import <XTlib/XTlib.h>


static const CGFloat kFlexValue = 30.f ;

@interface MarkdownEditor () {
    BOOL fstTimeLoaded ;
}
@property(nonatomic, strong) MarkdownPaser *markdownPaser  ;

@end

@implementation MarkdownEditor

#pragma mark -

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup {
//    self.delegate = self ;
    
    self.font = [UIFont systemFontOfSize:16.] ;
    self.contentInset = UIEdgeInsetsMake(0, kFlexValue, 0, kFlexValue) ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationDidTextChangeText:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateSyntax] ;
    }) ;
    
    
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
    [attributedString beginEditing] ;
    [attributedString addAttributes:Md_defaultStyle()
                              range:NSMakeRange(0, self.text.length)] ;
    
    for (MarkdownModel *model in models) {
        [attributedString addAttributes:AttributesFromMarkdownSyntaxType(model.type)
                                  range:model.range] ;
        
    }
    [attributedString endEditing] ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateAttributedText:attributedString];
        
        if (!self->fstTimeLoaded) {
            self.contentOffset = CGPointMake(-30, 0) ;
            self->fstTimeLoaded = YES ;
        }
    }) ;
}

- (void)updateAttributedText:(NSAttributedString *) attributedString {
    self.scrollEnabled = NO;
    NSRange selectedRange = self.selectedRange;
    self.attributedText = attributedString;
    self.selectedRange = selectedRange;
    self.scrollEnabled = YES;
}

#pragma mark -
// 光标移动 和 选择
- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    [super setSelectedTextRange:selectedTextRange] ;
    NSLog(@"%@",selectedTextRange) ;
    
    CGRect caretRect = [self caretRectForPosition:selectedTextRange.start];
    NSLog(@"caret rect %@", NSStringFromCGRect(caretRect)) ;
    
    
    
}



#pragma mark - props

- (MarkdownPaser *)markdownPaser {
    if (_markdownPaser == nil) {
        _markdownPaser = [[MarkdownPaser alloc] init];
    }
    return _markdownPaser;
}

@end




