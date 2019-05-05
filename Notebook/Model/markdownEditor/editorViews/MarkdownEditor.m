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
#import "XTMarkdownParser+ImageUtil.h"
#import "XTMarkdownParser+Fetcher.h"
#import "MdBlockModel.h"
#import "MDCodeBlockEditor.h"


NSString *const kNOTIFICATION_NAME_EDITOR_DID_CHANGE = @"kNOTIFICATION_NAME_EDITOR_DID_CHANGE" ;
const CGFloat kMDEditor_FlexValue       = 30.f  ;
static const int kTag_QuoteMarkView     = 66777 ;
static const int kTag_ListMarkView      = 32342 ;
static const int kTag_CodeBlkView       = 40000 ;
static const int kTag_InlineCodeView    = 50000 ;

@interface MarkdownEditor ()<XTMarkdownParserDelegate, UITextViewDelegate>
@property (strong, nonatomic) UIImageView   *imgLeftCornerMarker ;
@property (strong, nonatomic) MDToolbar     *toolBar ;

@end

@implementation MarkdownEditor

#pragma mark - life

- (void)dealloc {
    NSLog(@"******** MarkdownEditor DEALLOC ********") ; // todo 添加图片后不能释放. 图片下载中, 退出时应终止下载.
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
    self.font = [UIFont systemFontOfSize:self.parser.configuration.editorThemeObj.fontSize] ;
    self.contentInset = UIEdgeInsetsMake(0, kMDEditor_FlexValue, 0, kMDEditor_FlexValue) ;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag ;
    self.delegate = self ;
    if (@available(iOS 11.0, *)) self.smartDashesType = UITextSmartDashesTypeNo ;
    
//    self.backgroundColor = nil ;
    
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
        [self.parser readArticleFirstTimeAndInsertImagePHWhenEditorDidLaunching:self.text textView:self] ;
        [self updateTextStyle] ;
        
        if (!self->fstTimeLoaded) {
            self.contentOffset = CGPointMake(- kMDEditor_FlexValue, 0) ;
            self->fstTimeLoaded = YES ;
        }
    }) ;
}

#pragma mark - func

- (MarkdownModel *)updateTextStyle {
    [self.parser parseTextAndGetModelsInCurrentCursor:self.text textView:self] ; // create models
    MarkdownModel *model = [self.parser modelForModelListInlineFirst] ;
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
    
    UIImage *img = [UIImage imageNamed:[self.parser iconImageStringOfPosition:self.selectedRange.location model:model]] ;
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

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect originalRect = [super caretRectForPosition:position];
    originalRect.size.height = self.font.lineHeight + 2;
    originalRect.size.width = 2 ;
    return originalRect;
}

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    [super setSelectedTextRange:selectedTextRange] ;
    
    [self parseTextThenRenderLeftSideAndToobar] ;
    [self returnImageModelIfUserHasSelectImage:self.selectedRange.location] ;
}

- (BOOL)canBecomeFirstResponder {
    self.inputAccessoryView = self.toolBar ;
    // Redraw in case enabbled features have changes
    return [super canBecomeFirstResponder] ;
}

- (MarkdownModel *)returnImageModelIfUserHasSelectImage:(NSUInteger)position {
    if (position < 1) return nil ;
    
    NSString *strSelect = [self.text substringWithRange:NSMakeRange(position - 1, 1)] ;
    if ([strSelect isEqualToString:@"\uFFFC"]) {
        MarkdownModel *model = [self.parser modelForModelListInlineFirst] ; //移动到![]()后面
        [self imageSelectedAtNewPosition:model.range.location imageModel:(MdInlineModel *)model] ; // 图片选择
        return model ;
    }
    return nil ;
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
    }] ;
    [alert addButtonWithTitle:@"取消" type:XTSIAlertViewButtonTypeDefault handler:^(XTSIAlertView *alertView) {
    }] ;
    [alert show] ;
}



#pragma mark - props

- (XTMarkdownParser *)parser {
    if (!_parser) {
        MDThemeConfiguration *config = [MDThemeConfiguration new] ;
        _parser = [[XTMarkdownParser alloc] initWithConfig:config] ;
        _parser.delegate = self ;
    }
    return _parser ;
}

- (UIImageView *)imgLeftCornerMarker{
    if(!_imgLeftCornerMarker){
        _imgLeftCornerMarker = ({
            UIImageView *object = [[UIImageView alloc] init] ;
            object.contentMode = UIViewContentModeScaleAspectFit ;
            object.alpha = .3 ;
            object;
       });
    }
    return _imgLeftCornerMarker;
}

- (void)show_lbLeftCornerMarker {
    [self addSubview:self.imgLeftCornerMarker] ;
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start] ;
    NSLog(@"caretRect ; %@", NSStringFromCGRect(caretRect)) ;
    [self.imgLeftCornerMarker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_left).offset(-1) ;
        make.top.equalTo(self.mas_top).offset(caretRect.origin.y) ;
        make.size.mas_equalTo(CGSizeMake(15, 15)) ;
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
        if (CGSizeEqualToSize(rectForQuote.size, CGSizeZero)) continue ;
        
        UIView *quoteItem = [UIView new] ;
        quoteItem.tag = kTag_QuoteMarkView ;
        quoteItem.xt_theme_backgroundColor = k_md_themeColor ;
        [self addSubview:quoteItem] ;
        [quoteItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self) ;
            make.top.equalTo(self).offset(rectForQuote.origin.y) ;
            make.width.equalTo(@2) ;
            make.height.equalTo(@(rectForQuote.size.height)) ;
        }] ;
    }
}

- (void)listBlockParsingFinished:(NSArray *)list {
    for (UIView *subView in self.subviews) if (subView.tag == kTag_ListMarkView) [subView removeFromSuperview] ;
    
    for (int i = 0; i < list.count; i++) {
        MdListModel *model = list[i] ;
        CGRect rectForModel = [self xt_frameOfTextRange:NSMakeRange(model.range.location, 3)] ;
        if (CGSizeEqualToSize(rectForModel.size, CGSizeZero)) continue ;
        
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
                
                [weakSelf.parser parseTextAndGetModelsInCurrentCursor:tmpStr textView:weakSelf] ;
            }] ;
            item = imgView ;
        }
        
        item.tag = kTag_ListMarkView ;
        
        [self addSubview:item] ;
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            if (model.type == MarkdownSyntaxTaskLists) {
                make.width.equalTo(@(21)) ;
                make.centerX.equalTo(self.mas_left).offset(rectForModel.origin.x - 8) ;
            }
            else if (model.type == MarkdownSyntaxULLists) {
                make.right.equalTo(self.mas_left).offset(rectForModel.origin.x - 8) ;
            }
            else if (model.type == MarkdownSyntaxOLLists) {
                make.right.equalTo(self.mas_left).offset(rectForModel.origin.x - 8) ;
            }
            
            make.top.equalTo(self).offset(rectForModel.origin.y) ;
            make.height.equalTo(@(21)) ;
        }] ;
        
//        UIView *view = [UIView new] ;
//        view.backgroundColor = [UIColor greenColor] ;
//        view.alpha =.1 ;
//        view.frame = rectForModel ;
//        [self addSubview:view] ;
        
    }
}

//- (void)codeBlockParsingFinished:(NSArray *)list {
//    for (UIView *subView in self.subviews) if (subView.tag == kTag_CodeBlkView) [subView removeFromSuperview] ;
//
//    for (int i = 0; i < list.count; i++) {
//        MdBlockModel *model = list[i] ;
//        CGRect rectForBlk = [self xt_frameOfTextRange:model.range] ;
//        if (CGSizeEqualToSize(rectForBlk.size, CGSizeZero)) continue ;
//
//        MDCodeBlockEditor *codeBlkItem = [[MDCodeBlockEditor alloc] initWithFrame:rectForBlk model:model] ;
//        codeBlkItem.xt_borderWidth = 1 ;
//        codeBlkItem.xt_borderColor = [UIColor redColor] ;
//        codeBlkItem.tag = kTag_CodeBlkView ;
//        codeBlkItem.userInteractionEnabled = YES ;
//        [self addSubview:codeBlkItem] ;
//    }
//}

- (void)inlineCodeParsingFinished:(NSArray *)list {
    for (UIView *subView in self.subviews) if (subView.tag == kTag_InlineCodeView) [subView removeFromSuperview] ;
    for (int i = 0; i < list.count; i++) {
        MdBlockModel *model = list[i] ;
        if (model.str.length == 2) continue ;
        
        CGRect rectForIC = [self xt_frameOfTextRange:NSMakeRange(model.range.location + 1, model.range.length - 2)] ;
        rectForIC.size.height = [MDThemeConfiguration sharedInstance].editorThemeObj.fontSize * 1.5 ;
        rectForIC.origin.x -= [MDThemeConfiguration sharedInstance].editorThemeObj.inlineCodeSideFlex ;
        rectForIC.size.width += [MDThemeConfiguration sharedInstance].editorThemeObj.inlineCodeSideFlex ;
        if (CGSizeEqualToSize(rectForIC.size, CGSizeZero)) continue ;

        UIView *item = [[UIView alloc] init] ;
        item.frame = rectForIC ;
        item.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_themeColor, .2) ;
        item.userInteractionEnabled = YES ;
        item.tag = kTag_InlineCodeView ;
        WEAK_SELF
        [item bk_whenTapped:^{
            if (!weakSelf.isFirstResponder) [weakSelf becomeFirstResponder] ;
            weakSelf.selectedRange = NSMakeRange(model.location + model.length - 1, 0)  ;
            [weakSelf parseTextThenRenderLeftSideAndToobar] ;
        }] ;
        [self addSubview:item] ;
    }
}

- (NSRange)currentCursorRange {
    return self.selectedRange ;
}

#pragma mark - textview Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (![text isEqualToString:@"\n"]) return YES ;
    
    MarkdownModel *lstModel = [self.parser getBlkModelForCustomPosition:range.location - 1] ;
    NSMutableString *tmpString = [self.text mutableCopy] ;

    if (lstModel.type == MarkdownSyntaxOLLists) {
        int orderNum = [[[lstModel.str componentsSeparatedByString:@"."] firstObject] intValue] ;
        orderNum ++ ;
        NSString *orderStr = STR_FORMAT(@"%d",orderNum) ;
        if (lstModel.str.length < orderStr.length + 4) { //两下回车
            [tmpString deleteCharactersInRange:NSMakeRange(range.location - lstModel.str.length, lstModel.str.length)] ;
            [self.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location + 2 textView:self] ;
            self.selectedRange = NSMakeRange(range.location, 0) ;
            return NO ;
        }

        [tmpString insertString:STR_FORMAT(@"\n\n%@.  ",orderStr) atIndex:range.location] ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location textView:self] ;

        self.selectedRange = NSMakeRange(range.location + orderStr.length + 4, 0) ;
        return NO ;
    }
    else if (lstModel.type == MarkdownSyntaxTaskLists) {
        if (lstModel.str.length < 8) { //两下回车
            [tmpString deleteCharactersInRange:NSMakeRange(range.location - lstModel.str.length, lstModel.str.length)] ;
            [self.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location + 2 textView:self] ;
            self.selectedRange = NSMakeRange(range.location, 0) ;
            return NO ;
        }

        [tmpString insertString:@"\n\n* [ ]  " atIndex:range.location] ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location textView:self] ;
        self.selectedRange = NSMakeRange(range.location + 8, 0) ;
        return NO ;
    }
    else if (lstModel.type == MarkdownSyntaxULLists) {
        if (lstModel.str.length < 4) { //两下回车
            [tmpString deleteCharactersInRange:NSMakeRange(range.location - lstModel.str.length, lstModel.str.length)] ;
            [self.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location + 2 textView:self] ;
            self.selectedRange = NSMakeRange(range.location, 0) ;
            return NO ;
        }

        [tmpString insertString:@"\n\n*  " atIndex:range.location] ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location textView:self] ;
        self.selectedRange = NSMakeRange(range.location + 4, 0) ;
        return NO ;
    }
    
    return YES ;
}

@end




