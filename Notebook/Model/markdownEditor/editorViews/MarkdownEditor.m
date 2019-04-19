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
static const int kTag_QuoteMarkView = 66777 ;
static const int kTag_ListMarkView  = 32342 ;

@interface MarkdownEditor ()<MarkdownParserDelegate, UITextViewDelegate>
@property (strong, nonatomic) UIImageView *imgLeftCornerMarker ;
@property (strong, nonatomic) MDToolbar *toolBar ;

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
    self.font = [UIFont systemFontOfSize:self.markdownPaser.configuration.editorThemeObj.fontSize] ;
    self.contentInset = UIEdgeInsetsMake(0, kMDEditor_FlexValue, 0, kMDEditor_FlexValue) ;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag ;
    self.delegate = self ;
    if (@available(iOS 11.0, *)) self.smartDashesType = UITextSmartDashesTypeNo ;
    
    
    
    
    @weakify(self)
    // user typing
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextViewTextDidChangeNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        if (self.markedTextRange != nil) return ;
        
        [self parseTextThenRenderLeftSideAndToobar] ;
        
//        self.typingAttributes = MDThemeConfiguration.sharedInstance.editorThemeObj.basicStyle ;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
    }] ;
    
    // keyboard hiding
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.imgLeftCornerMarker removeFromSuperview] ;
        self->_imgLeftCornerMarker = nil ;
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
            self.contentOffset = CGPointMake(- kMDEditor_FlexValue, 0) ;
            self->fstTimeLoaded = YES ;
        }
    }) ;
}

#pragma mark - func

- (MarkdownModel *)updateTextStyle {
    NSArray *modellist = [self.markdownPaser parseText:self.text position:self.selectedRange.location textView:self] ; // create models
    MarkdownModel *model = [self.markdownPaser modelForModelListInlineFirst:modellist] ;
    return model ;
}

- (void)doSomethingWhenUserSelectPartOfArticle:(MarkdownModel *)model {
//    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start] ;
//    NSLog(@"caret rect %@", NSStringFromCGRect(caretRect)) ;
    NSLog(@"choose model : %@",[model yy_modelToJSONString]) ;
    // left lb
    [self drawLeftDisplayLabel:model] ;
    // render toolbar
    [self.toolBar renderWithModel:model] ;
}

- (void)drawLeftDisplayLabel:(MarkdownModel *)model {
    [self hide_lbLeftCornerMarker] ;
    if (!model) return ;
    
    UIImage *img = [UIImage imageNamed:[self.markdownPaser stringTitleOfPosition:self.selectedRange.location model:model]] ;
    self.imgLeftCornerMarker.image = img ;
    [self show_lbLeftCornerMarker] ;
}

- (void)parseTextThenRenderLeftSideAndToobar {
    MarkdownModel *model = [self updateTextStyle] ;
    [self doSomethingWhenUserSelectPartOfArticle:model] ;
}

- (void)setTopOffset:(CGFloat)topOffset {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contentInset = UIEdgeInsetsMake(topOffset, kMDEditor_FlexValue, 0, kMDEditor_FlexValue) ;
        self.mj_offsetY = - topOffset ;
    }) ;
}

#pragma mark - rewrite father
#pragma mark - cursor moving and selecting

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    [super setSelectedTextRange:selectedTextRange] ;
    
    [self parseTextThenRenderLeftSideAndToobar] ;
}

- (BOOL)canBecomeFirstResponder {
    self.inputAccessoryView = self.toolBar ;
    // Redraw in case enabbled features have changes
// [self.toolBar redraw] ;
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

- (UIImageView *)imgLeftCornerMarker{
    if(!_imgLeftCornerMarker){
        _imgLeftCornerMarker = ({
            UIImageView *object = [[UIImageView alloc] init] ;
            object.contentMode = UIViewContentModeScaleAspectFit ;
            object;
       });
    }
    return _imgLeftCornerMarker;
}

- (void)show_lbLeftCornerMarker {
    [self addSubview:self.imgLeftCornerMarker] ;
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start];
//    NSLog(@"caretRect ; %@", NSStringFromCGRect(caretRect)) ;
    [self.imgLeftCornerMarker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.superview.mas_left).offset(kMDEditor_FlexValue / 2) ;
        make.centerY.equalTo(self.mas_top).offset(caretRect.origin.y + kMDEditor_FlexValue / 2) ;
        make.size.mas_equalTo(CGSizeMake(20, 20)) ;
    }] ;
}

- (void)hide_lbLeftCornerMarker {
    if (self.imgLeftCornerMarker.superview) {
        [self.imgLeftCornerMarker removeFromSuperview] ;
        _imgLeftCornerMarker = nil ;
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
//      NSLog(@"rectForQuote : %@", NSStringFromCGRect(rectForQuote)) ;
        if (CGSizeEqualToSize(rectForQuote.size, CGSizeZero)) continue ;
        
        UIView *quoteItem = [UIView new] ;
        quoteItem.tag = kTag_QuoteMarkView ;
        quoteItem.xt_theme_backgroundColor = k_md_themeColor ;
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
//        [weakSelf doSomethingWhenUserSelectPartOfArticle:modelR] ;
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
            lb.xt_theme_textColor = k_md_themeColor ;
            lb.font = [UIFont boldSystemFontOfSize:16] ;
            lb.textAlignment = NSTextAlignmentCenter ;
            item = lb ;
        }
        else if (model.type == MarkdownSyntaxOLLists) {
            UILabel *lb = [UILabel new] ;
            lb.text = [[[model.str componentsSeparatedByString:@"."] firstObject] stringByAppendingString:@"."] ;
            lb.xt_theme_textColor = k_md_themeColor ;
            lb.font = [UIFont systemFontOfSize:16] ;
            lb.textAlignment = NSTextAlignmentRight ;
            item = lb ;
        }
        else if (model.type == MarkdownSyntaxTaskLists) {
            
            UIImageView *imgView = [UIImageView new] ;
            [imgView setImage:[model.taskItemImageState imageWithTintColor:XT_MD_THEME_COLOR_KEY(k_md_themeColor)]] ;
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




