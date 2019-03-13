//
//  MarkdownEditor.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownEditor.h"
#import "MDThemeConfiguration.h"
#import <XTlib/XTlib.h>

static const CGFloat kFlexValue = 30.f ;

@interface MarkdownEditor () {
    BOOL fstTimeLoaded ;
}

@property (strong, nonatomic) UILabel *lbLeftCornerMarker ;
@end

@implementation MarkdownEditor

#pragma mark - life

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)setup {
    self.font = [UIFont systemFontOfSize:self.markdownPaser.configuration.fontSize] ;
    self.contentInset = UIEdgeInsetsMake(0, kFlexValue, 0, kFlexValue) ;
    
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextViewTextDidChangeNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self updateSyntax] ;
        [self makeLeftDisplayLabel] ;
    }] ;
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.lbLeftCornerMarker removeFromSuperview] ;
        self->_lbLeftCornerMarker = nil ;
    }] ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateSyntax] ;
    }) ;
    
}

#pragma mark - func

- (void)updateSyntax {
    NSAttributedString *attributedString = [self.markdownPaser parseText:self.text] ;
    [self updateAttributedText:attributedString];
    
    if (!self->fstTimeLoaded) {
        self.contentOffset = CGPointMake(- kFlexValue, 0) ;
        self->fstTimeLoaded = YES ;
    }
}

- (void)updateAttributedText:(NSAttributedString *) attributedString {
    self.scrollEnabled = NO ;
    NSRange selectedRange = self.selectedRange ;
    self.attributedText = attributedString ;
    self.selectedRange = selectedRange ;
    self.scrollEnabled = YES ;
}

- (void)makeLeftDisplayLabel {
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start];
    NSLog(@"caret rect %@", NSStringFromCGRect(caretRect)) ;

    if (self.lbLeftCornerMarker.superview) {
        [self.lbLeftCornerMarker removeFromSuperview] ;
        _lbLeftCornerMarker = nil ;
    }
    
    self.lbLeftCornerMarker.text = [MarkdownPaser stringTitleOfModel:[self.markdownPaser modelForRangePosition:self.selectedRange.location]] ;
    
    [self addSubview:self.lbLeftCornerMarker] ;
    [self.lbLeftCornerMarker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.superview).offset(3) ;
        make.top.equalTo(@(caretRect.origin.y)) ;
        make.size.mas_equalTo(CGSizeMake(kFlexValue, caretRect.size.height)) ;
    }] ;
}

#pragma mark - rewrite

// 光标移动 和 选择
- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    [super setSelectedTextRange:selectedTextRange] ;
    
    NSLog(@"selectedTextRange %@",selectedTextRange) ;
    
    [self makeLeftDisplayLabel] ;
}



#pragma mark - props

- (MarkdownPaser *)markdownPaser {
    if (_markdownPaser == nil) {
        MDThemeConfiguration *config = [MDThemeConfiguration new] ;
        _markdownPaser = [[MarkdownPaser alloc] initWithConfig:config] ;
    }
    return _markdownPaser;
}

- (UILabel *)lbLeftCornerMarker{
    if(!_lbLeftCornerMarker){
        _lbLeftCornerMarker = ({
            UILabel * object = [[UILabel alloc] init] ;
            object.font = [UIFont systemFontOfSize:14] ;
            object.numberOfLines = 0 ;
            object.textColor = [UIColor lightGrayColor] ;
            object.textAlignment = NSTextAlignmentCenter ;
            object;
       });
    }
    return _lbLeftCornerMarker;
}

@end




