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
static const int kTag_QuoteMarkView = 66777 ;

@interface MarkdownEditor ()<MarkdownParserDelegate> {
    BOOL fstTimeLoaded ;
}
@property (strong, nonatomic) UILabel *lbLeftCornerMarker ;
@end

@implementation MarkdownEditor

#pragma mark - life

- (void)dealloc {
    NSLog(@"******** MarkdownEditor DEALLOC ********") ;
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
    if (@available(iOS 11.0, *)) self.smartDashesType = UITextSmartDashesTypeNo ;
    
    @weakify(self)
    // user typing
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextViewTextDidChangeNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self updateTextStyle] ;
        [self makeLeftDisplayLabel] ;
    }] ;
    
    // keyboard hiding
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.lbLeftCornerMarker removeFromSuperview] ;
        self->_lbLeftCornerMarker = nil ;
    }] ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTextStyle] ;
        
        if (!self->fstTimeLoaded) {
            self.contentOffset = CGPointMake(- kFlexValue, 0) ;
            self->fstTimeLoaded = YES ;
        }
    }) ;
}

#pragma mark - func

- (void)updateTextStyle {
    NSAttributedString *attributedString = [self.markdownPaser parseText:self.text position:self.selectedRange.location] ; // create models
    [self updateAttributedText:attributedString];
}

- (void)updateAttributedText:(NSAttributedString *)attributedString {
    self.scrollEnabled = NO ;
    NSRange selectedRange = self.selectedRange ;
    self.attributedText = attributedString ;
    self.selectedRange = selectedRange ;
    self.scrollEnabled = YES ;
}

- (void)makeLeftDisplayLabel {
    [self hide_lbLeftCornerMarker] ;
    
//    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start];
//    NSLog(@"caret rect %@", NSStringFromCGRect(caretRect)) ;
    MarkdownModel *model = [self.markdownPaser modelForRangePosition:self.selectedRange.location] ;
    self.lbLeftCornerMarker.text = [self.markdownPaser stringTitleOfPosition:self.selectedRange.location model:model] ;
    NSLog(@"choose model : %@",[model yy_modelToJSONString]) ;
    
    [self show_lbLeftCornerMarker] ;
}


#pragma mark - rewrite father
#pragma mark - cursor moving and selecting

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    [super setSelectedTextRange:selectedTextRange] ;
//    NSLog(@"selectedTextRange %@",selectedTextRange) ;
    
    [self updateTextStyle] ;
    [self makeLeftDisplayLabel] ;
}

#pragma mark - props

- (MarkdownPaser *)markdownPaser {
    if (_markdownPaser == nil) {
        MDThemeConfiguration *config = [MDThemeConfiguration new] ;
        _markdownPaser = [[MarkdownPaser alloc] initWithConfig:config] ;
        _markdownPaser.delegate = self ;
    }
    return _markdownPaser;
}

- (UILabel *)lbLeftCornerMarker{
    if(!_lbLeftCornerMarker){
        _lbLeftCornerMarker = ({
            UILabel * object = [[UILabel alloc] init] ;
            object.font = [UIFont systemFontOfSize:9] ;
            object.numberOfLines = 0 ;
            object.textColor = [UIColor redColor] ; //[UIColor lightGrayColor] ;
            object.textAlignment = NSTextAlignmentCenter ;
            object;
       });
    }
    return _lbLeftCornerMarker;
}

- (void)show_lbLeftCornerMarker {
    [self addSubview:self.lbLeftCornerMarker] ;
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start];
    [self.lbLeftCornerMarker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.superview).offset(3) ;
        make.top.equalTo(@(caretRect.origin.y)) ;
        make.size.mas_equalTo(CGSizeMake(kFlexValue, caretRect.size.height)) ;
    }] ;
}

- (void)hide_lbLeftCornerMarker {
    if (self.lbLeftCornerMarker.superview) {
        [self.lbLeftCornerMarker removeFromSuperview] ;
        _lbLeftCornerMarker = nil ;
    }
}

#pragma mark - MarkdownParserDelegate <NSObject>

- (void)quoteBlockParsingFinished:(NSArray *)list {

    for (UIView *subView in self.subviews) {
        if (subView.tag == kTag_QuoteMarkView) {
            [subView removeFromSuperview] ;
        }
    }

    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        CGRect rectForQuote = [self xt_frameOfTextRange:model.range] ;
//        NSLog(@"rectForQuote : %@", NSStringFromCGRect(rectForQuote)) ;
        if (CGSizeEqualToSize(rectForQuote.size, CGSizeZero)) {
            continue ;
        }
        
        UIView *quoteItem = [UIView new] ;
        quoteItem.tag = kTag_QuoteMarkView ;
        quoteItem.backgroundColor = self.markdownPaser.configuration.quoteLeftBarColor ;
        [self addSubview:quoteItem] ;
        [quoteItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self) ;
            make.top.equalTo(self).offset(rectForQuote.origin.y) ;
            make.width.equalTo(@5) ;
            make.height.equalTo(@(rectForQuote.size.height)) ;
        }] ;
    }
}

@end




