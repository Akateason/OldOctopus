//
//  OctToolbar.m
//  Notebook
//
//  Created by teason23 on 2019/5/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctToolbar.h"
#import "OctToolBarInlineView.h"
#import "MDEKeyboardPhotoView.h"
#import "MarkdownModel.h"
#import "OctToolbarBlockView.h"
#import "MarkdownEditor.h"
#import "XTMarkdownParser+Fetcher.h"

@interface OctToolbar ()
@property (weak, nonatomic)IBOutlet UIButton *btShowKeyboard ;
@property (weak, nonatomic)IBOutlet UIButton *btInlineStyle ;
@property (weak, nonatomic)IBOutlet UIButton *btList ;
@property (weak, nonatomic)IBOutlet UIButton *btPhoto ;
@property (weak, nonatomic)IBOutlet UIButton *btUndo ;
@property (weak, nonatomic)IBOutlet UIButton *btRedo ;
@property (weak, nonatomic)IBOutlet UIButton *btHideKeyboard ;

@property (strong, nonatomic) UIView *underLineView ; // 下划线

@property (strong, nonatomic) OctToolBarInlineView *inlineBoard ;
@property (strong, nonatomic) MDEKeyboardPhotoView *photoView ;
@property (strong, nonatomic) OctToolbarBlockView  *blockBoard ;
@end

@implementation OctToolbar
XT_SINGLETON_M(OctToolbar)
- (void)renderWithParaType:(int)para inlineList:(NSArray *)inlineList {
    [self clearUI] ;
    
    NSMutableArray *tmplist = [inlineList mutableCopy] ;
    [tmplist addObject:@(para)] ;
    [self.inlineBoard renderWithlist:tmplist] ;
    [self.blockBoard renderWithType:para] ;
}

- (void)renderWithModel:(MarkdownModel *)model {
    [self clearUI] ;
    
    if (model.type > MarkdownInlineUnknown || model.type == MarkdownSyntaxHeaders || model.type == -1) { // inline board
        [self.inlineBoard renderWithModel:model] ;
    }
    else if (model.type < MarkdownInlineUnknown) {
        [self.blockBoard renderWithModel:model] ;
    }
    
    self.btUndo.enabled = self.delegate.fromEditor.undoManager.canUndo ;
    self.btRedo.enabled = self.delegate.fromEditor.undoManager.canRedo ;
}

- (void)clearUI {
    [self.inlineBoard clearUI] ;
    [self.blockBoard clearUI] ;
}

- (void)reset {
    self.underLineView.centerX = self.btShowKeyboard.centerX + 17 ;
}

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.bounds = CGRectMake(0, 0, [UIView currentScreenBoundsDependOnOrientation].size.width, 41) ;
    
    [self setNeedsLayout] ;
    [self layoutIfNeeded] ;
    
    self.underLineView.width = self.btInlineStyle.width - 4 ;
    self.underLineView.centerX = self.btShowKeyboard.centerX + 17;
    self.underLineView.bottom = self.bottom ;
    [self addSubview:self.underLineView] ;
    
}


- (IBAction)showKeyboardAc:(UIButton *)sender {
    [self moveUnderLineFromView:sender] ;
    [self hideAllBoards] ;
}

- (void)hideAllBoards {
    [self.inlineBoard removeFromSuperview] ;
    [self.photoView removeFromSuperview] ;
    [self.blockBoard removeFromSuperview] ;
}

- (IBAction)inlinestyleAc:(UIButton *)sender {
    [self hideAllBoards] ;
    [self moveUnderLineFromView:sender] ;
    // add inline board .
    [self.inlineBoard addMeAboveKeyboardViewWithKeyboardHeight:self.delegate.keyboardHeight] ;
}

- (IBAction)listAc:(UIButton *)sender {
    [self hideAllBoards] ;
    [self moveUnderLineFromView:sender] ;
    // add block board .
    [self.blockBoard addMeAboveKeyboardViewWithKeyboardHeight:self.delegate.keyboardHeight] ;
}

- (IBAction)photoAc:(UIButton *)sender {
    [self moveUnderLineFromView:sender] ;
    // add photo board .
    self.photoView = [self.delegate toolbarDidSelectPhotoView] ;
}

- (IBAction)undoAc:(UIButton *)sender {
    [self.delegate toolbarDidSelectUndo] ;
//    MarkdownModel *model = [self.delegate.fromEditor.parser modelForModelListInlineFirst] ;
//    [self renderWithModel:model] ;
}

- (IBAction)redoAc:(UIButton *)sender {
    [self.delegate toolbarDidSelectRedo] ;
//    MarkdownModel *model = [self.delegate.fromEditor.parser modelForModelListInlineFirst] ;
//    [self renderWithModel:model] ;
}

- (IBAction)hideKeyboardAc:(UIButton *)sender {
    [self.delegate hideKeyboard] ;
    
    [self hideAllBoards] ;
}

- (void)moveUnderLineFromView:(UIView *)sender {
    [UIView animateWithDuration:.2 animations:^{
        self.underLineView.centerX = sender.centerX + 17;
    }] ;
    
    self.underLineView.layer.transform = CATransform3DMakeScale(0.68, 0.68, 1) ;
    [UIView animateWithDuration:.4 animations:^{
        self.underLineView.layer.transform = CATransform3DIdentity ;
    }] ;
}

#pragma mark - prop

- (OctToolbarBlockView *)blockBoard {
    if (!_blockBoard) {
        _blockBoard = [OctToolbarBlockView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _blockBoard.blkBoard_Delegate = self.delegate ;
    }
    return _blockBoard ;
}

- (OctToolBarInlineView *)inlineBoard {
    if (!_inlineBoard) {
        _inlineBoard = [OctToolBarInlineView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _inlineBoard.inlineBoard_Delegate = self.delegate ;
    }
    return _inlineBoard ;
}

- (UIView *)underLineView {
    if (!_underLineView) {
        _underLineView = [UIView new] ;
        _underLineView.size = CGSizeMake(100, 2) ;
        _underLineView.backgroundColor = UIColorHex(@"6b737b") ;
        [_underLineView xt_completeRound] ;
    }
    return _underLineView ;
}

@end
