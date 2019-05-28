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
#import "MDEditUrlView.h"
#import "MarkdownEditor+OctToolbarUtil.h"
#import "MdInlineModel.h"
#import <XTlib/XTSIAlertView.h>
#import "XTMarkdownParser+ImageUtil.h"
#import "XTMarkdownParser+Fetcher.h"
#import "MdBlockModel.h"
#import "MDCodeBlockEditor.h"
#import "ArticlePhotoPreviewVC.h"
#import "XTMarkdownParser+ImageUtil.h"
#import "MdBlockModel.h"
#import <SafariServices/SafariServices.h>
#import "HrView.h"
#import "MDHeadModel.h"
#import "OctToolbar.h"
#import <iosMath/IosMath.h>
#import "RegexHighlightView.h"



NSString *const kNOTIFICATION_NAME_EDITOR_DID_CHANGE = @"kNOTIFICATION_NAME_EDITOR_DID_CHANGE" ;
const CGFloat kMDEditor_FlexValue       = 30.f  ;
static const int kTag_QuoteMarkView     = 66777 ;
static const int kTag_ListMarkView      = 32342 ;
static const int kTag_CodeBlkView       = 40000 ;
static const int kTag_InlineCodeView    = 50000 ;
static const int kTag_HrView            = 60000 ;
static const int kTag_MathView          = 78089 ;

@interface MarkdownEditor ()<XTMarkdownParserDelegate, UITextViewDelegate>
@property (strong, nonatomic) UIImageView   *imgLeftCornerMarker ;
@property (strong, nonatomic) OctToolbar     *toolBar ;

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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapThisEditorAndFindImageAttach:)];
    [self addGestureRecognizer:tapGesture] ;

    
    @weakify(self)
    // user typing
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextViewTextDidChangeNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        if (self.markedTextRange != nil) return ;
        
        [self parseAllTextFinishedThenRenderLeftSideAndToolbar] ;
        
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

// User Finger Touch cursor moving
- (void)didTapThisEditorAndFindImageAttach:(UITapGestureRecognizer *)sender {
    // first: extract the sender view
    UIView *senderView = sender.view;
    if (![senderView isKindOfClass:[UITextView class]]) return ;
    
    // calculate layout manager touch location
    UITextView *textView = (UITextView *)senderView;
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [sender locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    // find the value
    NSTextContainer *textContainer = textView.textContainer;
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:location inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    NSTextStorage *textStorage = textView.textStorage;
    if (characterIndex < textStorage.length) {
        NSRange range0;
        NSString *jsonInlineModel = [textStorage attribute:kKey_MDInlineImageModel atIndex:characterIndex effectiveRange:&range0] ;
        if (jsonInlineModel) {
            MdInlineModel *inlineImageModel = [MdInlineModel yy_modelWithJSON:jsonInlineModel] ;
            [self resignFirstResponder] ;
            [self showPreviewCtrller:inlineImageModel] ;
        }
        else {
            if (!self.isFirstResponder) [self becomeFirstResponder] ;
            if (characterIndex == textStorage.length - 1) {
                characterIndex = textStorage.length ; // debug选择最后一个字符的问题
            }
            self.selectedRange = NSMakeRange(characterIndex, 0) ; // 回 默认
            [self parseAllTextFinishedThenRenderLeftSideAndToolbar] ;
        }
    }
}

// preview one photo
- (void)showPreviewCtrller:(MdInlineModel *)inlineImageModel {
    [ArticlePhotoPreviewVC showFromCtrller:self.xt_viewController model:inlineImageModel deleteOnClick:^(ArticlePhotoPreviewVC * _Nonnull vc) {
        WEAK_SELF
        [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleAlert title:@"是否要删除此图片" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil fromWithView:self CallBackBlock:^(NSInteger btnIndex) {
            
            if (btnIndex == 1) {
                NSMutableString *tmpString = [weakSelf.text mutableCopy] ;
                [tmpString deleteCharactersInRange:NSMakeRange(inlineImageModel.location, inlineImageModel.length + 1)] ;
                weakSelf.text = tmpString ;
                [weakSelf updateTextStyle] ;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ; // notificate for update .
                [vc dismissViewControllerAnimated:YES completion:nil] ;
            }
        }] ;
    }] ;
}

#pragma mark - func

- (MarkdownModel *)updateTextStyle {
    [self.parser parseTextAndGetModelsInCurrentCursor:self.text textView:self] ; // create models
    MarkdownModel *model = [self.parser modelForModelListInlineFirst] ;
    return model ;
}

- (void)doSomethingWhenUserSelectPartOfArticle:(MarkdownModel *)model {
    NSLog(@"hey i choose a model : %@",[model yy_modelToJSONString]) ;
    // left lb
    [self drawLeftDisplayLabel:model] ;
    // render toolbar
    [self.toolBar renderWithModel:model] ;
    // edit a link
    [self clickALinkModel:(MdInlineModel *)model] ;
}

- (void)drawLeftDisplayLabel:(MarkdownModel *)model {
    [self hide_lbLeftCornerMarker] ;
    if (!model) return ;
    if (!self.isFirstResponder) return ;
    
    UIImage *img = [UIImage imageNamed:[self.parser iconImageStringOfPosition:self.selectedRange.location model:model]] ;
    self.imgLeftCornerMarker.image = img ;
    [self show_lbLeftCornerMarker] ;
}

- (void)renderLeftSideAndToobar {
    MarkdownModel *model = [self.parser modelForModelListInlineFirst] ;
    [self doSomethingWhenUserSelectPartOfArticle:model] ;
}

- (void)clickALinkModel:(MdInlineModel *)model {
    if (model.type != MarkdownInlineLinks) return ;

    NSString *link = model.linkUrl ;
    if (![link hasPrefix:@"http"]) {
        link = [@"http://" stringByAppendingString:link] ;
    }
    
    @weakify(self)
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleActionSheet title:model.linkUrl message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"跳转到此链接",@"编辑此链接",@"删除此链接"] fromWithView:self CallBackBlock:^(NSInteger btnIndex) {
        @strongify(self)
        if (btnIndex == 1) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:link]] ;
            [self.xt_viewController presentViewController:safariVC animated:YES completion:nil] ;
        }
        else if (btnIndex == 2) {
            [self editLink:model] ;
        }
        else if (btnIndex == 3) {
            [self deleteLink:model] ;
        }
    }] ;
}

- (void)editLink:(MdInlineModel *)model {
    @weakify(self)
    [MDEditUrlView showOnView:self window:self.window model:model keyboardHeight:keyboardHeight callback:^(BOOL isConfirm, NSString *title, NSString *url) {
        @strongify(self)
        if (!isConfirm) {
            [self becomeFirstResponder] ;
            return ;
        }
        
        NSMutableString *tmpString = [self.text mutableCopy] ;
        NSString *linkStr = STR_FORMAT(@"[%@](%@)",title,url) ;
        if (model && model.type == MarkdownInlineLinks) {
            [tmpString deleteCharactersInRange:model.range] ;
            [tmpString insertString:linkStr atIndex:model.range.location] ;
        }
        else [tmpString insertString:linkStr atIndex:self.selectedRange.location] ;
        
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ; // notificate for update .
    }] ;
}

- (void)deleteLink:(MdInlineModel *)model {
    if (!model || model.type != MarkdownInlineLinks) return ;
    
    NSMutableString *tmpString = [self.text mutableCopy] ;
    [tmpString deleteCharactersInRange:model.range] ;
    [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
    self.selectedRange = NSMakeRange(model.location, 0) ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ; // notificate for update .
}

- (void)parseAllTextFinishedThenRenderLeftSideAndToolbar {
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
    originalRect.size.height = (self.font.lineHeight <= 0.2) ? kDefaultFontSize + 2 : self.font.lineHeight + 2 ;
    originalRect.size.width = 2 ;
    return originalRect;
}

// keyboard cursor moving
- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    [super setSelectedTextRange:selectedTextRange] ;
    
    [self parseAllTextFinishedThenRenderLeftSideAndToolbar] ;
}

- (BOOL)canBecomeFirstResponder {
    [self.toolBar refresh] ;
    self.inputAccessoryView = self.toolBar ;
    // Redraw in case enabbled features have changes
    return [super canBecomeFirstResponder] ;
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
//    NSLog(@"caretRect ; %@", NSStringFromCGRect(caretRect)) ;
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

- (OctToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [OctToolbar xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _toolBar.frame = CGRectMake(0, 0, [self.class currentScreenBoundsDependOnOrientation].size.width, 41) ;
        _toolBar.delegate = self ;
    }
    return _toolBar ;
}

#pragma mark - MarkdownParserDelegate <NSObject>

- (void)quoteBlockParsingFinished:(NSArray *)quoteList {
    for (UIView *subView in self.subviews) {
        if (subView.tag == kTag_QuoteMarkView) {
            [subView removeFromSuperview] ;
        }
    }
    
    for (int i = 0; i < quoteList.count; i++) {
        MarkdownModel *model = quoteList[i] ;
        [self drawOneQuoteWithModel:model] ;
    }
}

- (void)drawOneQuoteWithModel:(MarkdownModel *)model {
    CGRect rectForQuote = [self xt_frameOfTextRange:model.range] ;
    if (CGSizeEqualToSize(rectForQuote.size, CGSizeZero)) return ;
    
    UIView *quoteItem = [UIView new] ;
    quoteItem.tag = kTag_QuoteMarkView ;
    quoteItem.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_quoteBarColor, 1) ;
    [self addSubview:quoteItem] ;
    [quoteItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(model.markIndentationPosition * 18 + 8) ;
        make.top.equalTo(self).offset(rectForQuote.origin.y) ;
        make.width.equalTo(@2) ;
        make.height.equalTo(@(rectForQuote.size.height)) ;
    }] ;
}

- (void)listBlockParsingFinished:(NSArray *)list {
    for (UIView *subView in self.subviews) if (subView.tag == kTag_ListMarkView) [subView removeFromSuperview] ;
    
    for (int i = 0; i < list.count; i++) {
        MdListModel *model = list[i] ;
        CGRect rectForModel = [self xt_frameOfTextRange:NSMakeRange([model realRange].location, 3)] ;
        if ([model.str isEqualToString:@"* "]) {
            rectForModel = [self caretRectForPosition:self.selectedTextRange.start] ; // 如果得到的是已经被隐藏的model,比如"* ", 那么返回光标的位置.
        }
        
        if (CGSizeEqualToSize(rectForModel.size, CGSizeZero)) continue ;
        
        UIView *item ;
        if (model.type == MarkdownSyntaxULLists) {
            UILabel *lb = [UILabel new] ;
            NSString *text ;
            switch ((model.countForSpace / 2) % 3) {
                case 0: text = @"•" ; break;
                case 1: text = @"◦" ; break;
                case 2: text = @"▪︎" ; break;
                default: break;
            }
            lb.text = text ;
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
                !model.taskItemSelected ?
                [tmpStr replaceCharactersInRange:NSMakeRange(model.range.location + 3, 1) withString:@"x"] :
                [tmpStr replaceCharactersInRange:NSMakeRange(model.range.location + 3, 1) withString:@" "] ;
                [weakSelf.parser parseTextAndGetModelsInCurrentCursor:tmpStr textView:weakSelf] ;
            }] ;
            item = imgView ;
        }
        
        item.tag = kTag_ListMarkView ;
        
        [self addSubview:item] ;
        if (model.type == MarkdownSyntaxTaskLists) {
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(21)) ;
                make.centerX.equalTo(self.mas_left).offset(rectForModel.origin.x - 8) ;
                make.top.equalTo(self).offset(rectForModel.origin.y) ;
                make.height.equalTo(@(21)) ;
            }] ;
        }
        else if (model.type == MarkdownSyntaxULLists) {
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_left).offset((model.markIndentationPosition) * 18 - 4) ;
                make.top.equalTo(self).offset(rectForModel.origin.y) ;
                make.height.equalTo(@(21)) ;
            }] ;
        }
        else if (model.type == MarkdownSyntaxOLLists) {
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_left).offset((model.markIndentationPosition) * 18) ;
                make.top.equalTo(self).offset(rectForModel.origin.y) ;
                make.height.equalTo(@(21)) ;
            }] ;
        }
    }
}

- (void)codeBlockParsingFinished:(NSArray *)list {
    for (UIView *subView in self.subviews) if (subView.tag == kTag_CodeBlkView) [subView removeFromSuperview] ;

    for (int i = 0; i < list.count; i++) {
        MdBlockModel *model = list[i] ;
        if (model.isOnEditState) continue ;
        
//        NSString *firstPrefix = [[model.str componentsSeparatedByString:@"\n"] firstObject] ;
//        NSRange range = NSMakeRange(firstPrefix.length + model.location, model.length - 4 - firstPrefix.length) ;
        CGRect rectForBlk = [self xt_frameOfTextRange:model.range] ;
        if (CGSizeEqualToSize(rectForBlk.size, CGSizeZero)) continue ;
        
        MDCodeBlockEditor *codeBlkItem = [[MDCodeBlockEditor alloc] initWithFrame:rectForBlk model:model] ;
        codeBlkItem.xt_borderWidth = 1 ;
        codeBlkItem.xt_borderColor = [UIColor redColor] ;
        codeBlkItem.tag = kTag_CodeBlkView ;
//        codeBlkItem.userInteractionEnabled = NO ;
        [self addSubview:codeBlkItem] ;
    }
}

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
        item.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .03) ;
        item.userInteractionEnabled = YES ;
        item.tag = kTag_InlineCodeView ;
        item.xt_borderWidth = .25 ;
        item.xt_borderColor = XT_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ;
        item.xt_cornerRadius = 3 ;
        
        WEAK_SELF
        [item bk_whenTapped:^{
            if (!weakSelf.isFirstResponder) [weakSelf becomeFirstResponder] ;
            weakSelf.selectedRange = NSMakeRange(model.location + model.length - 1, 0)  ;
            [weakSelf parseAllTextFinishedThenRenderLeftSideAndToolbar] ;
        }] ;
        [self addSubview:item] ;
    }
}

- (void)hrParsingFinished:(NSArray *)list {
    for (UIView *subView in self.subviews) if (subView.tag == kTag_HrView) [subView removeFromSuperview] ;
    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        CGRect rectForHr = [self xt_frameOfTextRange:NSMakeRange(model.range.location, model.range.length - 1)] ;
        HrView *hr = [[HrView alloc] init] ;
        hr.tag = kTag_HrView ;
        hr.frame = CGRectMake(0, rectForHr.origin.y, APP_WIDTH - 30 * 2, 16) ;
        [self addSubview:hr] ;
    }
}

- (void)mathListParsingFinished:(NSArray *)list {
    for (UIView *subView in self.subviews) if (subView.tag == kTag_MathView) [subView removeFromSuperview] ;
    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        if (model.isOnEditState) continue ;
        
        CGRect rectForMath = [self xt_frameOfTextRange:NSMakeRange(model.range.location, model.range.length - 1)] ;
        MTMathUILabel *label = [[MTMathUILabel alloc] init] ;
        label.tag = kTag_MathView ;
        NSMutableString *mathStr = [model.str mutableCopy] ;
        [mathStr deleteCharactersInRange:NSMakeRange(mathStr.length - 3, 3)] ;
        [mathStr deleteCharactersInRange:NSMakeRange(0, 3)] ;
        
        label.latex = mathStr ;
        label.labelMode = kMTMathUILabelModeText;
        label.textAlignment = kMTTextAlignmentCenter;
        label.fontSize = [MDThemeConfiguration sharedInstance].editorThemeObj.fontSize + 5 ;
        label.textColor = XT_MD_THEME_COLOR_KEY(k_md_textColor) ;
        label.frame = rectForMath ;
        [self addSubview:label] ;
    }
}


- (NSRange)currentCursorRange {
    return self.selectedRange ;
}

#pragma mark - textview Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    // Handle user input a "return" charactor .
    if (![text isEqualToString:@"\n"]) return YES ;
    // get current model
    MarkdownModel *thisModel = [self.parser getBlkModelForCustomPosition:range.location] ;
    int result ;
    // quote model
    result = [MdBlockModel keyboardEnterTypedInTextView:self modelInPosition:thisModel shouldChangeTextInRange:range] ;
    if (result != 100) return result ;
    // list model
    result = [MdListModel keyboardEnterTypedInTextView:self modelInPosition:thisModel shouldChangeTextInRange:range] ;
    if (result != 100) return result ;
    // para model
    result = [MarkdownModel keyboardEnterTypedInTextView:self modelInPosition:thisModel shouldChangeTextInRange:range] ;
    if (result != 100) return result ;
    // head model
    result = [MDHeadModel keyboardEnterTypedInTextView:self modelInPosition:thisModel shouldChangeTextInRange:range] ;
    if (result != 100) return result ;
    
    return YES ;
}

@end




