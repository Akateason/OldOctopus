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
#import "MdListModel.h"


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
//    self.editable = NO ;
    if (@available(iOS 11.0, *)) self.smartDashesType = UITextSmartDashesTypeNo ;
    
    @weakify(self)
    // user typing
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextViewTextDidChangeNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self updateTextStyle] ;
        [self doSomethingWhenUserSelectPartOfArticle] ;
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
    [self.markdownPaser parseText:self.text position:self.selectedRange.location textView:self] ; // create models
}

- (void)doSomethingWhenUserSelectPartOfArticle {
//    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start];
//    NSLog(@"caret rect %@", NSStringFromCGRect(caretRect)) ;
    MarkdownModel *model = [self.markdownPaser modelForRangePosition:self.selectedRange.location] ;
    NSLog(@"choose model : %@",[model yy_modelToJSONString]) ;
    
    // left lb
    [self drawLeftDisplayLabel:model] ;
    // bullet
    [self drawBullet:model] ;
}

- (void)drawLeftDisplayLabel:(MarkdownModel *)model {
    [self hide_lbLeftCornerMarker] ;
    self.lbLeftCornerMarker.text = [self.markdownPaser stringTitleOfPosition:self.selectedRange.location model:model] ;
    [self show_lbLeftCornerMarker] ;
}

- (void)drawBullet:(MarkdownModel *)model {
    if (model.type != MarkdownSyntaxULLists) return ;
    
    if (model.isOnEditState) {
        NSMutableAttributedString *attr = [self.attributedText mutableCopy] ;
        [attr replaceCharactersInRange:NSMakeRange(model.range.location, 1) withString:@"*"] ;
        [self.markdownPaser updateAttributedText:attr textView:self] ;
    }
    else {
        NSMutableAttributedString *attr = [self.attributedText mutableCopy] ;
        [attr replaceCharactersInRange:NSMakeRange(model.range.location, 1) withString:kMark_Bullet] ;
        [self.markdownPaser updateAttributedText:attr textView:self] ;
    }
}

- (void)insertPhoto:(UIImage *)image {
    NSMutableAttributedString *mutaAttrStr = [self.attributedText mutableCopy] ;
    
    NSRange range = self.selectedRange;
    NSLog(@"插入图片loc在: %lu", (unsigned long)range.location) ;
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image             = image;
    CGFloat tvWid                = self.width - 10 - kFlexValue ;
    CGSize resultImgSize         = CGSizeMake(tvWid, tvWid / image.size.width * image.size.height);
    CGRect rect                  = (CGRect){CGPointZero, resultImgSize};
    attachment.bounds            = rect;
    NSAttributedString *attrStr = [NSAttributedString attributedStringWithAttachment:attachment];
    [mutaAttrStr insertAttributedString:attrStr atIndex:range.location];
    
    [self.markdownPaser updateAttributedText:mutaAttrStr textView:self] ;
    
    NSLog(@"text%@\n attrtext%@",self.text, self.attributedText) ;
}

#pragma mark - rewrite father
#pragma mark - cursor moving and selecting

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    [super setSelectedTextRange:selectedTextRange] ;
//    NSLog(@"selectedTextRange %@",selectedTextRange) ;
    
    [self updateTextStyle] ;
    [self doSomethingWhenUserSelectPartOfArticle] ;
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
    
//    [self setNeedsLayout] ;
//    [self layoutIfNeeded] ;

    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        CGRect rectForQuote = [self xt_frameOfTextRange:model.range] ;
        NSLog(@"rectForQuote : %@", NSStringFromCGRect(rectForQuote)) ;
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


#pragma mark - touch

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    // 获取当前触摸位置的字符所属的字母(提示：触摸位置需向下调整10个点，以便与文本元素对齐)
//    UITouch *touch = [touches anyObject];
//    CGPoint touchPoint = [touch locationInView:self];
//    touchPoint.y -= 10;
//
//    // 获取点击的字母的位置
//    NSInteger characterIndex = [self.layoutManager characterIndexForPoint:touchPoint
//                                                          inTextContainer:self.textContainer
//                                 fractionOfDistanceBetweenInsertionPoints:NULL];
//
//    // 获取单词的范围。range 由起始位置和长度构成。
//    MarkdownModel *modelPressed = [self.markdownPaser modelForRangePosition:characterIndex] ;
//    if (modelPressed.type == MarkdownInlineLinks) {
//        NSLog(@"链接点解了 ? ? ??!!") ;
//    }
//
//
//
//    //调用父类的方法
//    [super touchesBegan: touches withEvent: event];
//}

@end




