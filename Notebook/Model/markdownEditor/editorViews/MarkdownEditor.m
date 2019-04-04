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
#import "MDEditUrlView.h"
#import "MarkdownEditor+UtilOfToolbar.h"
#import "MdInlineModel.h"
#import <XTlib/XTSIAlertView.h>


NSString *const kNOTIFICATION_NAME_EDITOR_DID_CHANGE = @"kNOTIFICATION_NAME_EDITOR_DID_CHANGE" ;
const CGFloat kMDEditor_FlexValue   = 30.f  ;
const CGFloat kMDEditor_TopMarginValue  = 50.f  ;
static const int kTag_QuoteMarkView = 66777 ;
static const int kTag_ListMarkView  = 32342 ;

@interface MarkdownEditor ()<MarkdownParserDelegate, UITextViewDelegate>
@property (strong, nonatomic) UILabel *lbLeftCornerMarker ;
@property (strong, nonatomic) MDToolbar *toolBar ;
@property (strong, nonatomic) UITextField *hiddenTitleTf ;
@property (strong, nonatomic) UILabel *titleLabel ;
@end

@implementation MarkdownEditor

#pragma mark - life

- (void)dealloc {
    NSLog(@"******** MarkdownEditor DEALLOC ********") ; // todo 添加图片后不能释放.
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
    [self hiddenTitleTf] ; // 解决直接加tf开键盘之后下滑问题
    
    @weakify(self)
    [self.titleLabel bk_whenTapped:^{
        @strongify(self)
        self.inputAccessoryView = nil ;
        [self.hiddenTitleTf becomeFirstResponder] ;
    }] ;
    
    RAC(self.titleLabel, text) = [self.hiddenTitleTf rac_textSignal] ;
    
    self.font = [UIFont systemFontOfSize:self.markdownPaser.configuration.fontSize] ;
    self.contentInset = UIEdgeInsetsMake(kMDEditor_TopMarginValue, kMDEditor_FlexValue, 0, kMDEditor_FlexValue) ;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag ;
    self.delegate = self ;
    if (@available(iOS 11.0, *)) self.smartDashesType = UITextSmartDashesTypeNo ;
    
    
    // user typing
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextViewTextDidChangeNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        if (self.markedTextRange != nil) return ;
        
        [self updateTextStyle] ;
        [self doSomethingWhenUserSelectPartOfArticle] ;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
    }] ;
    
    // keyboard hiding
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.lbLeftCornerMarker removeFromSuperview] ;
        self->_lbLeftCornerMarker = nil ;
    }] ;
    
    // keyboard showing
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *_Nullable x) {
        @strongify(self)
        NSDictionary *info = [x userInfo];
        CGSize kbSize          = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        // get keyboard height
        self->keyboardHeight = kbSize.height;
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.markdownPaser readArticleFirstTimeAndInsertImagePHWhenEditorDidLaunching:self.text textView:self] ;
        [self updateTextStyle] ;
        
        if (!self->fstTimeLoaded) {
            self.contentOffset = CGPointMake(- kMDEditor_FlexValue, - kMDEditor_TopMarginValue) ;
            self->fstTimeLoaded = YES ;
        }
    }) ;
}

#pragma mark - func

- (void)setArticleTitle:(NSString *)title {
    self.hiddenTitleTf.text = title ;
    self.titleLabel.text = title ;
}

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
    if (!model) return ;
    
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
    return [super canBecomeFirstResponder] ;
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
        _toolBar.frame = CGRectMake(0, 0, [self.class currentScreenBoundsDependOnOrientation].size.width, 41) ;
        _toolBar.mdt_delegate = self ;
    }
    return _toolBar ;
}

- (UITextField *)hiddenTitleTf{
    if(!_hiddenTitleTf){
        _hiddenTitleTf = ({
            UITextField *object = [UITextField new] ;
            object.frame = CGRectMake(-100, -100, 1, 1) ;
            [self addSubview:object] ;
            object;
        });
    }
    return _hiddenTitleTf;
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, - kMDEditor_TopMarginValue, APP_WIDTH - 2 * kMDEditor_FlexValue , kMDEditor_TopMarginValue - 10)] ;
            tLabel.font = [UIFont boldSystemFontOfSize:32.] ;
            tLabel.text = self.hiddenTitleTf.text ;
            tLabel.textColor = [UIColor blackColor] ;
            tLabel.userInteractionEnabled = YES ;
            [self addSubview:tLabel] ;
            tLabel ;
        });
    }
    return _titleLabel;
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

- (void)imageSelectedAtNewPosition:(NSInteger)position imageModel:(MdInlineModel *)model {
    [self resignFirstResponder] ;
    
    XTSIAlertView *alert = [[XTSIAlertView alloc] initWithTitle:@"是否要删除此图片" andMessage:@""] ;
    WEAK_SELF
    [alert addButtonWithTitle:@"删除" type:XTSIAlertViewButtonTypeDestructive handler:^(XTSIAlertView *alertView) {
        NSMutableString *tmpString = [weakSelf.text mutableCopy] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, model.range.length + 3)] ;
        weakSelf.text = tmpString ;
        [weakSelf updateTextStyle] ;
        [weakSelf doSomethingWhenUserSelectPartOfArticle] ;
    }] ;
    [alert addButtonWithTitle:@"取消" type:XTSIAlertViewButtonTypeDefault handler:^(XTSIAlertView *alertView) {
    }] ;
    [alert show] ;
}

- (void)listBlockParsingFinished:(NSArray *)list {
    for (UIView *subView in self.subviews) if (subView.tag == kTag_ListMarkView) [subView removeFromSuperview] ;
        
    for (int i = 0; i < list.count; i++) {
        MdListModel *model = list[i] ;
        CGRect rectForQuote = [self xt_frameOfTextRange:model.range] ;
//        NSLog(@"rectForQuote : %@", NSStringFromCGRect(rectForQuote)) ;
        if (CGSizeEqualToSize(rectForQuote.size, CGSizeZero)) continue ;
        
        UIView *item ;
        if (model.type == MarkdownSyntaxULLists) {
            UILabel *lb = [UILabel new] ;
            lb.text = @"   •" ;
            lb.textColor = [MDThemeConfiguration sharedInstance].themeColor ;
            lb.font = [UIFont boldSystemFontOfSize:16] ;
            lb.textAlignment = NSTextAlignmentCenter ;
            item = lb ;
        }
        else if (model.type == MarkdownSyntaxOLLists) {
            UILabel *lb = [UILabel new] ;
            lb.text = [[[model.str componentsSeparatedByString:@"."] firstObject] stringByAppendingString:@"."] ;
            lb.textColor = [MDThemeConfiguration sharedInstance].themeColor ;
            lb.font = [UIFont systemFontOfSize:16] ;
            lb.textAlignment = NSTextAlignmentRight ;
            item = lb ;
        }
        else if (model.type == MarkdownSyntaxTaskLists) {
            
            UIImageView *imgView = [UIImageView new] ;
            [imgView setImage:[model.taskItemImageState imageWithTintColor:[MDThemeConfiguration sharedInstance].themeColor]] ;
            imgView.contentMode = UIViewContentModeScaleAspectFit ;
            imgView.userInteractionEnabled = YES ;
            WEAK_SELF
            [imgView bk_whenTapped:^{
                NSMutableString *tmpStr = [[NSMutableString alloc] initWithString:weakSelf.text] ;
                !model.taskItemSelected
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
                make.right.equalTo(self.xt_viewController.view.window.mas_left).offset(kMDEditor_FlexValue) ;
            }
            else {
                make.left.equalTo(self.xt_viewController.view.window.mas_left) ;
                make.width.equalTo(@(kMDEditor_FlexValue)) ;
            }
            make.top.equalTo(self).offset(rectForQuote.origin.y) ;
            make.height.equalTo(@(21)) ;
        }] ;
    }
}

#pragma mark - textview Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (![text isEqualToString:@"\n"]) return YES ;
    
    MarkdownModel *lstModel = [self.markdownPaser blkModelForRangePosition:range.location - 1] ;
    NSMutableString *tmpString = [self.text mutableCopy] ;
    
    if (lstModel.type == MarkdownSyntaxOLLists) {
        int orderNum = [[[lstModel.str componentsSeparatedByString:@"."] firstObject] intValue] ;
        orderNum ++ ;
        NSString *orderStr = STR_FORMAT(@"%d",orderNum) ;
        if (lstModel.str.length < orderStr.length + 4) { //两下回车
            [tmpString deleteCharactersInRange:NSMakeRange(range.location - lstModel.str.length, lstModel.str.length)] ;
            [self.markdownPaser parseText:tmpString position:range.location + 2 textView:self] ;
            self.selectedRange = NSMakeRange(range.location, 0) ;
            return NO ;
        }
        
        [tmpString insertString:STR_FORMAT(@"\n\n%@.  ",orderStr) atIndex:range.location] ;
        [self.markdownPaser parseText:tmpString position:range.location textView:self] ;
        self.selectedRange = NSMakeRange(range.location + orderStr.length + 4, 0) ;
        return NO ;
    }
    else if (lstModel.type == MarkdownSyntaxTaskLists) {
        if (lstModel.str.length < 8) { //两下回车
            [tmpString deleteCharactersInRange:NSMakeRange(range.location - lstModel.str.length, lstModel.str.length)] ;
            [self.markdownPaser parseText:tmpString position:range.location + 2 textView:self] ;
            self.selectedRange = NSMakeRange(range.location, 0) ;
            return NO ;
        }
        
        [tmpString insertString:@"\n\n* [ ]  " atIndex:range.location] ;
        [self.markdownPaser parseText:tmpString position:range.location textView:self] ;
        self.selectedRange = NSMakeRange(range.location + 8, 0) ;
        return NO ;
    }
    else if (lstModel.type == MarkdownSyntaxULLists) {
        if (lstModel.str.length < 4) { //两下回车
            [tmpString deleteCharactersInRange:NSMakeRange(range.location - lstModel.str.length, lstModel.str.length)] ;
            [self.markdownPaser parseText:tmpString position:range.location + 2 textView:self] ;
            self.selectedRange = NSMakeRange(range.location, 0) ;
            return NO ;
        }
        
        [tmpString insertString:@"\n\n*  " atIndex:range.location] ;
        [self.markdownPaser parseText:tmpString position:range.location textView:self] ;
        self.selectedRange = NSMakeRange(range.location + 4, 0) ;
        return NO ;
    }
    
// return NO ;//返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    return YES ;
}

@end




