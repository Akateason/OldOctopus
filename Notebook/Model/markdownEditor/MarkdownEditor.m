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
#import <BlocksKit+UIKit.h>
#import "MDToolbar.h"

const CGFloat kMDEditor_FlexValue   = 30.f  ;
static const int kTag_QuoteMarkView = 66777 ;
static const int kTag_ListMarkView  = 32342 ;

@interface MarkdownEditor ()<MarkdownParserDelegate, MDToolbarDelegate> {
    BOOL fstTimeLoaded ;
}
@property (strong, nonatomic) UILabel *lbLeftCornerMarker ;
@property (strong, nonatomic) MDToolbar *toolBar ;
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
    self.contentInset = UIEdgeInsetsMake(0, kMDEditor_FlexValue, 0, kMDEditor_FlexValue) ;
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
        [self.markdownPaser readArticleFirstTimeAndInsertImagePHWhenEditorDidLaunching:self.text textView:self] ;
        [self updateTextStyle] ;
        
        if (!self->fstTimeLoaded) {
            self.contentOffset = CGPointMake(- kMDEditor_FlexValue, 0) ;
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
}

- (void)drawLeftDisplayLabel:(MarkdownModel *)model {
    [self hide_lbLeftCornerMarker] ;
    self.lbLeftCornerMarker.text = [self.markdownPaser stringTitleOfPosition:self.selectedRange.location model:model] ;
    [self show_lbLeftCornerMarker] ;
}


#pragma mark - rewrite father
#pragma mark - cursor moving and selecting

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    [super setSelectedTextRange:selectedTextRange] ;
    
    [self updateTextStyle] ;
    [self doSomethingWhenUserSelectPartOfArticle] ;
}

- (BOOL)canBecomeFirstResponder {
    self.inputAccessoryView = self.toolBar ;
    // Redraw in case enabbled features have changes
//    [self.toolBar redraw];
    
    return [super canBecomeFirstResponder];
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
        make.size.mas_equalTo(CGSizeMake(kMDEditor_FlexValue, caretRect.size.height)) ;
    }] ;
}

- (void)hide_lbLeftCornerMarker {
    if (self.lbLeftCornerMarker.superview) {
        [self.lbLeftCornerMarker removeFromSuperview] ;
        _lbLeftCornerMarker = nil ;
    }
}

- (MDToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[MDToolbar alloc] initWithConfigList:nil] ;
        _toolBar.frame = CGRectMake(0, 0, [self currentScreenBoundsDependOnOrientation].size.width, 41) ;
        _toolBar.mdt_delegate = self ;
    }
    return _toolBar ;
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
        if (CGSizeEqualToSize(rectForQuote.size, CGSizeZero)) continue ;
        
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

- (void)imageSelectedAtNewPosition:(NSInteger)position {
    self.selectedRange = NSMakeRange(position, 0) ;
    [self updateTextStyle] ;
}

- (void)listBlockParsingFinished:(NSArray *)list {
    for (UIView *subView in self.subviews) {
        if (subView.tag == kTag_ListMarkView) {
            [subView removeFromSuperview] ;
        }
    }
    
    for (int i = 0; i < list.count; i++) {
        MdListModel *model = list[i] ;
        CGRect rectForQuote = [self xt_frameOfTextRange:model.range] ;
//        NSLog(@"rectForQuote : %@", NSStringFromCGRect(rectForQuote)) ;
        if (CGSizeEqualToSize(rectForQuote.size, CGSizeZero)) continue ;
        
        UIView *item ;
        if (model.type == MarkdownSyntaxULLists) {
            UILabel *lb = [UILabel new] ;
            lb.text = @"   •" ;
            lb.font = [UIFont boldSystemFontOfSize:16] ;
            lb.textAlignment = NSTextAlignmentCenter ;
            item = lb ;
        }
        else if (model.type == MarkdownSyntaxOLLists) {
            UILabel *lb = [UILabel new] ;
            lb.text = [[[model.str componentsSeparatedByString:@"."] firstObject] stringByAppendingString:@"."] ;
            lb.font = [UIFont systemFontOfSize:16] ;
            lb.textAlignment = NSTextAlignmentRight ;
            item = lb ;
        }
        else if (model.type == MarkdownSyntaxTaskLists) {
            
            UIImageView *imgView = [UIImageView new] ;
            [imgView setImage:model.taskItemImageState] ;
            imgView.contentMode = UIViewContentModeScaleAspectFit ;
            imgView.userInteractionEnabled = YES ;
            WEAK_SELF
            [imgView bk_whenTapped:^{
                NSMutableString *tmpStr = [[NSMutableString alloc] initWithString:weakSelf.text] ;
                model.taskItemSelected
                ?
                [tmpStr replaceCharactersInRange:NSMakeRange(model.range.location + 3, 1) withString:@"x"]
                :
                [tmpStr replaceCharactersInRange:NSMakeRange(model.range.location + 3, 1) withString:@" "] ;
                [weakSelf.markdownPaser parseText:tmpStr position:weakSelf.selectedRange.location textView:weakSelf] ;
            }] ;
            item = imgView ;
        }
        
        item.tag = kTag_ListMarkView ;
        
        [self addSubview:item] ;
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            if (model.type == MarkdownSyntaxTaskLists) {
                make.width.equalTo(@(21)) ;
                make.right.equalTo(self.window.mas_left).offset(kMDEditor_FlexValue) ;
            }
            else {
                make.left.equalTo(self.window.mas_left) ;
                make.width.equalTo(@(kMDEditor_FlexValue)) ;
            }
            make.top.equalTo(self).offset(rectForQuote.origin.y) ;
            make.height.equalTo(@(21)) ;
        }] ;
    }
}

#pragma mark - MDToolbarDelegate <NSObject>

- (void)makeHeaderWithSize:(NSString *)mark {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *paraModel = [self.markdownPaser paraModelForPosition:self.selectedRange.location] ;
    if ([paraModel.str hasPrefix:@"#"]) {
        NSString *prefix = [[paraModel.str componentsSeparatedByString:@" "] firstObject] ;
        NSInteger delNum = prefix.length + 1 ;
        [tmpString deleteCharactersInRange:NSMakeRange(paraModel.range.location, delNum)] ;
    }
    [tmpString insertString:mark atIndex:paraModel.range.location] ;
    [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
}

- (void)toolbarDidSelectRemoveTitle {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *paraModel = [self.markdownPaser paraModelForPosition:self.selectedRange.location] ;
    if ([paraModel.str hasPrefix:@"#"]) {
        NSString *prefix = [[paraModel.str componentsSeparatedByString:@" "] firstObject] ;
        NSInteger delNum = prefix.length + 1 ;
        [tmpString deleteCharactersInRange:NSMakeRange(paraModel.range.location, delNum)] ;
    }
    [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
}
- (void)toolbarDidSelectH1 {
    [self makeHeaderWithSize:@"# "] ;
}
- (void)toolbarDidSelectH2 {
    [self makeHeaderWithSize:@"## "] ;
}
- (void)toolbarDidSelectH3 {
    [self makeHeaderWithSize:@"### "] ;
}
- (void)toolbarDidSelectH4 {
    [self makeHeaderWithSize:@"#### "] ;
}
- (void)toolbarDidSelectH5 {
    [self makeHeaderWithSize:@"##### "] ;
}
- (void)toolbarDidSelectH6 {
    [self makeHeaderWithSize:@"###### "] ;
}
- (void)toolbarDidSelectSepLine {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    [tmpString insertString:@"\n---\n" atIndex:self.selectedRange.location] ;
    [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    self.selectedRange = NSMakeRange(self.selectedRange.location + 5, 0) ;
}


- (void)toolbarDidSelectBold {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *model = [self.markdownPaser modelForRangePosition:self.selectedRange.location] ;
    // del
    if (model.type == MarkdownInlineBold) {
        NSInteger numOfStr = model.str.length - 4 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 2 + numOfStr, 2)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 2)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
        return ;
    }
    
    if (model.type == MarkdownInlineBoldItalic) {
        NSInteger numOfStr = model.str.length - 6 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 3 + numOfStr, 3)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 3)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
        [self toolbarDidSelectItalic] ;
        return ;
    }
    
    if (model.type == MarkdownInlineItalic) {
        NSInteger numOfStr = model.str.length - 2 ;
        self.selectedRange = NSMakeRange(model.range.location + 1, numOfStr) ;
    }
    
    // add
    if (!self.selectedRange.length) {
        [tmpString insertString:@"****" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 2, 0) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
    else {
        [tmpString insertString:@"**" atIndex:self.selectedRange.location + self.selectedRange.length] ;
        [tmpString insertString:@"**" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 2, self.selectedRange.length) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
}

- (void)toolbarDidSelectItalic {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *model = [self.markdownPaser modelForRangePosition:self.selectedRange.location] ;
    // del
    if (model.type == MarkdownInlineItalic) {
        NSInteger numOfStr = model.str.length - 2 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 1 + numOfStr, 1)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 1)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
        return ;
    }
    
    if (model.type == MarkdownInlineBoldItalic) {
        NSInteger numOfStr = model.str.length - 6 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 3 + numOfStr, 3)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 3)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
        [self toolbarDidSelectBold] ;
        return ;
    }
    
    if (model.type == MarkdownInlineBold) {
        NSInteger numOfStr = model.str.length - 4 ;
        self.selectedRange = NSMakeRange(model.range.location + 2, numOfStr) ;
    }
    
    // add
    if (!self.selectedRange.length) {
        [tmpString insertString:@"**" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 1, 0) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
    else {
        [tmpString insertString:@"*" atIndex:self.selectedRange.location + self.selectedRange.length] ;
        [tmpString insertString:@"*" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 1, self.selectedRange.length) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
}

- (void)toolbarDidSelectDeletion {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *model = [self.markdownPaser modelForRangePosition:self.selectedRange.location] ;
    // del
    if (model.type == MarkdownInlineDeletions) {
        NSInteger numOfStr = model.str.length - 4 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 2 + numOfStr, 2)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 2)] ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location, numOfStr) ;
        return ;
    }
    
    // add
    if (!self.selectedRange.length) {
        [tmpString insertString:@"~~~~" atIndex:self.selectedRange.location] ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 2, 0) ;
    }
    else { // todo
        [tmpString insertString:@"~~" atIndex:self.selectedRange.location + self.selectedRange.length] ;
        [tmpString insertString:@"~~" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 2, self.selectedRange.length) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
}

- (void)toolbarDidSelectPhoto {
    
}
- (void)toolbarDidSelectLink {
    
}

- (void)toolbarDidSelectUList {
    
}
- (void)toolbarDidSelectOrderlist {
    
}
- (void)toolbarDidSelectTaskList {
    
}

- (void)toolbarDidSelectCodeBlock {
    
}
- (void)toolbarDidSelectQuoteBlock {
    
}

- (void)toolbarDidSelectUndo {
    [[self undoManager] undo];
}
- (void)toolbarDidSelectRedo {
    [[self undoManager] redo];
}


#pragma mark -

- (CGRect)currentScreenBoundsDependOnOrientation {
    CGRect screenBounds                         = [UIScreen mainScreen].bounds;
    CGFloat width                               = CGRectGetWidth(screenBounds);
    CGFloat height                              = CGRectGetHeight(screenBounds);
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        screenBounds.size = CGSizeMake(width, height);
    }
    else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        screenBounds.size = CGSizeMake(height, width);
    }
    
    return screenBounds;
}



@end




