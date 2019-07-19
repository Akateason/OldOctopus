//
//  SearchVC.m
//  Notebook
//
//  Created by teason23 on 2019/4/16.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SearchVC.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
#import "NoteCell.h"
#import "MarkdownVC.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>
#import "MDNavVC.h"
#import "SearchEmptyVC.h"
#import "SchBarPositiveTransition.h"
#import "GlobalDisplaySt.h"
#import "HomeVC.h"
#import "NHSlidingController.h"
#import "UIViewController+SlidingController.h"

@interface SearchVC () <UITableViewDelegate, UITableViewDataSource, UITableViewXTReloaderDelegate, CYLTableViewPlaceHolderDelegate>
@property (copy, nonatomic) NSArray *listResult ;
@property (nonatomic) BOOL isTrash ;
@end

@implementation SearchVC

+ (void)showSearchVCFrom:(UIViewController *)fromCtrller {
    [self showSearchVCFrom:fromCtrller inTrash:NO] ;
}

+ (void)showSearchVCFrom:(UIViewController *)fromCtrller inTrash:(BOOL)inTrash {
    SearchVC *vc = [SearchVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"SearchVC"] ;
    vc.isTrash = inTrash ;
    MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:vc] ;
    fromCtrller.definesPresentationContext = YES;
    navVC.transitioningDelegate = fromCtrller ;
    navVC.modalPresentationStyle = UIModalPresentationOverCurrentContext ;
    [fromCtrller presentViewController:navVC animated:YES completion:^{
        [fromCtrller.slidingController setDrawerOpened:NO animated:YES] ;
    }] ;
}


- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.topFlex.constant = APP_STATUSBAR_HEIGHT ;
    [self.tf becomeFirstResponder] ;
    
    @weakify(self)
    [self.btCancel bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self.tf resignFirstResponder] ;
        [self dismissViewControllerAnimated:YES completion:nil] ;
        
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [[[self.tf.rac_textSignal throttle:.3]
      deliverOnMainThread]
     subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
         [self render] ;
    }] ;
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)] ;
    [self.view addGestureRecognizer:recognizer] ;
}

- (void)handleSwipeFrom:(id)gest {
    [self.tf resignFirstResponder] ;
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

- (void)prepareUI {
    self.fd_prefersNavigationBarHidden = YES ;
    
    self.view.xt_theme_backgroundColor = IS_IPAD ? XT_MAKE_theme_color(k_md_midDrawerPadColor, 1) : XT_MAKE_theme_color(k_md_bgColor,1) ;
//    [self.view oct_addBlurBg] ;
    
    self.topArea.xt_theme_backgroundColor = nil ;
    self.searchBar.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, 0.03) ;
    self.tf.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, 0.8)  ;
    self.tf.placeholder = @"搜索笔记" ;
    UIColor *color = [[MDThemeConfiguration sharedInstance] themeColor:XT_MAKE_theme_color(k_md_textColor, 0.3)] ;
    [self.tf setValue:color forKeyPath:@"_placeholderLabel.textColor"] ;
    [self.tf setValue:[UIFont systemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"] ;
    
    self.btCancel.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, 0.6)  ;
    
    [NoteCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    
    self.table.estimatedRowHeight           = 0;
    self.table.estimatedSectionHeaderHeight = 0;
    self.table.estimatedSectionFooterHeight = 0;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.backgroundColor = nil ;
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag ;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated] ;
    
    self.table.scrollEnabled = YES ;
}

#pragma mark - table

- (void)render {
    NSString *searchForText = self.tf.text ;
    if (searchForText.length) {
        NSString *sql =
        self.isTrash ?
        XT_STR_FORMAT(@"searchContent like '%%%@%%' and isDeleted == 1",searchForText)
        :
        XT_STR_FORMAT(@"searchContent like '%%%@%%' and isDeleted == 0",searchForText) ;
        NSArray *list = [Note xt_findWhere:sql] ;
        self.listResult = list ;
    }
    else
        self.listResult = @[] ;
    
    [self.table cyl_reloadData] ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listResult.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteCell *cell = [NoteCell xt_fetchFromTable:tableView] ;
    [cell xt_configure:self.listResult[indexPath.row] indexPath:indexPath] ;
    cell.textForSearching = self.tf.text ;
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoteCell xt_cellHeight] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row ;
    Note *aNote = self.listResult[row] ;
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) {
        [MarkdownVC newWithNote:aNote bookID:aNote.noteBookId fromCtrller:self] ;
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNote_ClickNote_In_Pad object:aNote] ;
    }
    
    [self.tf resignFirstResponder] ;
}

- (UIView *)makePlaceHolderView {
    if (!self.tf.text.length) {
        return nil ;
    }
    SearchEmptyVC *phVC = [SearchEmptyVC getCtrllerFromNIBWithBundle:[NSBundle bundleForClass:self.class]] ;
    return phVC.view ;
}













@end
