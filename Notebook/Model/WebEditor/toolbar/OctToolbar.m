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
#import "OctWebEditor.h"
#import "IAPSubscriptionVC.h"
#import "IapUtil.h"
#import "GuidingICloud.h"

@interface OctToolbar ()
@property (strong, nonatomic) UIView *underLineView ; // 下划线

@property (strong, nonatomic) OctToolBarInlineView *inlineBoard ;
@property (strong, nonatomic) MDEKeyboardPhotoView *photoView ;
@property (strong, nonatomic) OctToolbarBlockView  *blockBoard ;
@end

@implementation OctToolbar

- (UIButton *)makeButton:(NSString *)imgStr {
    UIButton *bt = [UIButton new] ;
    [bt setImage:[UIImage imageNamed:imgStr] forState:0] ;
    bt.frame = CGRectMake(0, 0, 100, 41) ;
    return bt ;
}

- (void)renderWithParaType:(NSArray *)paraList inlineList:(NSArray *)inlineList {
    [self clearUI] ;
    
    NSMutableArray *tmplist = [inlineList mutableCopy] ;
    [tmplist addObjectsFromArray:paraList] ;
    [self.inlineBoard renderWithlist:tmplist] ;
    [self.blockBoard renderWithTypeList:paraList] ;
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
    self.selectedPosition = self.smartKeyboardState ? 1 : 0 ;
    self.underLineView.centerX = self.smartKeyboardState ? (self.width / 5. / 2. + 17) : (self.width / 6. / 2. + 17) ;
    self.underLineView.top = 38. ;
}

- (void)refresh {
    switch (self.selectedPosition) {
        case 0: {
            [self showKeyboardAc:self.btShowKeyboard] ;
        }
            break;
        case 1: {
            [self inlinestyleAc:self.btInlineStyle] ;
        }
            break;
        case 2: {
            [self listAc:self.btList] ;
        }
            break;
        case 3: {
            [self photoAc:self.btPhoto] ;
        }
            break;
        default: break ;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.bounds = CGRectMake(0, 0, [UIView currentScreenBoundsDependOnOrientation].size.width, 41) ;
    
    [self setNeedsLayout] ;
    [self layoutIfNeeded] ;
    
    self.underLineView.width = self.btInlineStyle.width - 4 ;
    self.underLineView.centerX = self.smartKeyboardState ? (self.width / 5. / 2. + 17) : (self.width / 6. / 2. + 17) ;
    self.underLineView.top = 38. ;
}


- (IBAction)showKeyboardAc:(UIButton *)sender {
    self.selectedPosition = 0 ;
    [self moveUnderLineFromView:sender] ;
    [self hideAllBoards] ;
}

- (void)hideAllBoards {
    [self.inlineBoard removeFromSuperview] ;
    _inlineBoard = nil ;
    [self.photoView.scrollView removeFromSuperview] ;
    _photoView = nil ;
    [self.blockBoard.scrollView removeFromSuperview] ;
    _blockBoard = nil ;
}

- (IBAction)inlinestyleAc:(UIButton *)sender {
    self.selectedPosition = 1 ;
    [self hideAllBoards] ;
    [self moveUnderLineFromView:sender] ;
    // add inline board .
    [self.inlineBoard addMeAboveKeyboardViewWithKeyboardHeight:self.delegate.keyboardHeight] ;
    
    [self renderWithParaType:[OctWebEditor sharedInstance].typeBlkList inlineList:[OctWebEditor sharedInstance].typeInlineList] ;
}

- (IBAction)listAc:(UIButton *)sender {
    self.selectedPosition = 2 ;
    [self hideAllBoards] ;
    [self moveUnderLineFromView:sender] ;
    // add block board .
    [self.blockBoard addMeAboveKeyboardViewWithKeyboardHeight:self.delegate.keyboardHeight] ;
    
    [self renderWithParaType:[OctWebEditor sharedInstance].typeBlkList inlineList:[OctWebEditor sharedInstance].typeInlineList] ;
}

- (IBAction)photoAc:(UIButton *)sender {
    if (![XTIcloudUser hasLogin]) {
        NSLog(@"未登录") ;
        [GuidingICloud show] ;
        
        return ;
    }
    
    if (![IapUtil isIapVipFromLocalAndRequestIfLocalNotExist]) {
        [self.delegate subscription] ;
        
        return ;
    }
    
    
    self.selectedPosition = 3 ;
    [self hideAllBoards] ;
    [self moveUnderLineFromView:sender] ;
    // add photo board .
    self.photoView = [self.delegate toolbarDidSelectPhotoView] ;
}

- (IBAction)undoAc:(UIButton *)sender {
    [self.delegate toolbarDidSelectUndo] ;
}

- (IBAction)redoAc:(UIButton *)sender {
    [self.delegate toolbarDidSelectRedo] ;
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

- (void)setSmartKeyboardState:(BOOL)smartKeyboardState {
    _smartKeyboardState = smartKeyboardState ;
    
    self.btShowKeyboard.hidden = smartKeyboardState ;
}

#pragma mark - prop

- (OctToolbarBlockView *)blockBoard {
    if (!_blockBoard) {
        _blockBoard = [OctToolbarBlockView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _blockBoard.blkBoard_Delegate = (id<OctToolbarBlockViewDelegate>)self.delegate ;
    }
    return _blockBoard ;
}

- (OctToolBarInlineView *)inlineBoard {
    if (!_inlineBoard) {
        _inlineBoard = [OctToolBarInlineView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _inlineBoard.inlineBoard_Delegate = (id<OctToolBarInlineViewDelegate>)self.delegate ;
    }
    return _inlineBoard ;
}

- (UIView *)underLineView {
    if (!_underLineView) {
        _underLineView = [UIView new] ;
        _underLineView.size = CGSizeMake(100, 2) ;
        _underLineView.backgroundColor = UIColorHex(@"6b737b") ;
        _underLineView.top = 38. ;
        [_underLineView xt_completeRound] ;
        if (!_underLineView.superview) {
            [self addSubview:_underLineView] ;
        }
    }
    return _underLineView ;
}

@end

