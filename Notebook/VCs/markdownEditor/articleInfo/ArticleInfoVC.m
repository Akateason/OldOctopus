//
//  ArticleInfoVC.m
//  Notebook
//
//  Created by teason23 on 2019/4/15.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "ArticleInfoVC.h"
#import "XTMarkdownParser.h"
#import "WebModel.h"
#import "GlobalDisplaySt.h"


@interface ArticleInfoVC ()

@end

@implementation ArticleInfoVC

+ (CGFloat)movingDistance {
    if (IS_IPAD) return 280 ;
    return  48. / 75. * APP_WIDTH ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    if (IS_IPAD) {
        self.view.backgroundColor = nil ;
    }
    else {
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.3] ;
    }
    
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)] ;
    [self.view addGestureRecognizer:recognizer] ;
    
    WEAK_SELF
    [self.view bk_whenTapped:^{
        [weakSelf close] ;
    }] ;
    
    
    [self bgVC] ;
    [self.view addSubview:self.bgVC.view] ;
    
    if (IS_IPAD) {
        [self.bgVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(50) ;
            make.right.equalTo(self.view).offset(-50) ;
            make.size.mas_equalTo(CGSizeMake(280, 580)) ;
        }] ;
        
        self.bgVC.view.xt_cornerRadius = 5 ;
        self.bgVC.view.xt_borderWidth = .25 ;
        self.bgVC.view.xt_borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] ;
        self.bgVC.topArea.backgroundColor = nil ;

        self.bgVC.view.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.15].CGColor;
        self.bgVC.view.layer.shadowOffset = CGSizeMake(0,10) ;
        self.bgVC.view.layer.shadowOpacity = 60 ;
        self.bgVC.view.layer.shadowRadius = 10 ;
    }
    else {
        [self.bgVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self.view) ;
            make.width.equalTo(@([self.class movingDistance])) ;
        }] ;
    }
    self.bgVC.btClose.hidden = !IS_IPAD ;
}

- (void)setWebInfo:(WebModel *)webInfo {
    _webInfo = webInfo ;
    
    self.bgVC.aNote = self.aNote ;
    self.bgVC.webInfo = webInfo ;
    [self.bgVC bind] ;
}

- (void)handleSwipeFrom:(id)gesture {
    [self close] ;
}

- (void)close {
    [UIView animateWithDuration:.2 animations:^{
        self.bgVC.view.left = APP_WIDTH ;
        self.view.alpha = 0.1 ;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview] ;
    }] ;
}

- (void)openFromView:(UIView *)fromView {
    [fromView.window addSubview:self.view] ;
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(fromView) ;
    }] ;
    self.view.alpha = 0.1 ;
    
    self.bgVC.view.transform = CGAffineTransformTranslate(self.bgVC.view.transform, APP_WIDTH * 2, 0) ;
    [UIView animateWithDuration:.3 animations:^{
        self.view.alpha = 1 ;
        self.bgVC.view.transform = CGAffineTransformIdentity ;
    } completion:^(BOOL finished) {
        
    }] ;
}

#pragma mark - ArticleBgVCDelegate <NSObject>

- (void)closeBg {
    [self close] ;
}

- (void)output {
    if (self.blkOutput) self.blkOutput() ;
}

- (void)removeToTrash {
    // Delete Note
    [self close] ;
    
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"确认要将此文章放入垃圾桶?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
        if (btnIndex == 1) {
            self.aNote.isDeleted = YES ;
            [Note updateMyNote:self.aNote] ;
            self.blkDelete() ;
        }
    }] ;
}

#pragma mark -

- (ArticleBgVC *)bgVC{
    if(!_bgVC){
        _bgVC = ({
            ArticleBgVC * object = [ArticleBgVC getCtrllerFromNIB] ;
            object.delegate = (id<ArticleBgVCDelegate>)self ;
            object;
       });
    }
    return _bgVC;
}

@end
