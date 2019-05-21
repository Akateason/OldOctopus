//
//  OctToolbar.m
//  Notebook
//
//  Created by teason23 on 2019/5/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctToolbar.h"
#import <XTlib/XTlib.h>

@interface OctToolbar ()
@property (weak, nonatomic)IBOutlet UIButton *btShowKeyboard ;
@property (weak, nonatomic)IBOutlet UIButton *btInlineStyle ;
@property (weak, nonatomic)IBOutlet UIButton *btList ;
@property (weak, nonatomic)IBOutlet UIButton *btPhoto ;
@property (weak, nonatomic)IBOutlet UIButton *btUndo ;
@property (weak, nonatomic)IBOutlet UIButton *btRedo ;
@property (weak, nonatomic)IBOutlet UIButton *btHideKeyboard ;

@property (strong, nonatomic) UIView *underLineView ;
@end

@implementation OctToolbar

- (UIView *)underLineView {
    if (!_underLineView) {
        _underLineView = [UIView new] ;
        _underLineView.size = CGSizeMake(100, 2) ;
        _underLineView.backgroundColor = UIColorHex(@"6b737b") ;
        [_underLineView xt_completeRound] ;
    }
    return _underLineView ;
}

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.underLineView.width = self.btShowKeyboard.width ;
    self.underLineView.centerX = self.btShowKeyboard.centerX ;
    self.underLineView.bottom = self.bottom ;
    [self addSubview:self.underLineView] ;
}

- (IBAction)showKeyboardAc:(UIButton *)sender {
    [self moveUnderLineFromView:sender] ;
    
}

- (IBAction)inlinestyleAc:(UIButton *)sender {
    [self moveUnderLineFromView:sender] ;
    
}

- (IBAction)listAc:(UIButton *)sender {
    [self moveUnderLineFromView:sender] ;
    
}

- (IBAction)photoAc:(UIButton *)sender {
    [self moveUnderLineFromView:sender] ;
    
}

- (IBAction)undoAc:(UIButton *)sender {
    [self moveUnderLineFromView:sender] ;
    
}

- (IBAction)redoAc:(UIButton *)sender {
    [self moveUnderLineFromView:sender] ;
    
}

- (IBAction)hideKeyboardAc:(UIButton *)sender {
    [self moveUnderLineFromView:sender] ;
    
}

- (void)moveUnderLineFromView:(UIView *)sender {
    [UIView animateWithDuration:.2 animations:^{
        self.underLineView.centerX = sender.centerX ;
    }] ;
}


@end
