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


@interface SearchVC () <UITableViewDelegate, UITableViewDataSource, UITableViewXTReloaderDelegate, CYLTableViewPlaceHolderDelegate>
@property (copy, nonatomic) NSArray *listResult ;
@end

@implementation SearchVC

+ (void)showSearchVCFrom:(UIViewController *)fromCtrller {
    SearchVC *vc = [SearchVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"SearchVC"] ;
    MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:vc] ;
    
    [fromCtrller presentViewController:navVC animated:YES completion:nil] ;
}


- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    [self.tf becomeFirstResponder] ;
    
    @weakify(self)
    [self.btCancel bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self.tf resignFirstResponder] ;
        [self dismissViewControllerAnimated:YES completion:nil] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [[[[self.tf.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        return value.length > 0 ;
    }] throttle:.3]
      deliverOnMainThread]
     subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        [self.table xt_loadNewInfoInBackGround:YES] ;
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
    
    self.topArea.xt_theme_backgroundColor = k_md_bgColor ;
    self.searchBar.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, 0.03) ;
    self.tf.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, 0.8)  ;
    self.tf.placeholder = @"搜索笔记" ;
    self.btCancel.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, 0.6)  ;
    
    [NoteCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [self.table xt_setup] ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.xt_Delegate = self ;
    self.table.mj_footer = nil ;
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag ;
}

#pragma mark - table

- (void)tableView:(UITableView *)table loadNew:(void (^)(void))endRefresh {
    NSString *searchForText = self.tf.text ;
    if (searchForText.length) {
        NSArray *list = [Note xt_findWhere:XT_STR_FORMAT(@"searchContent like '%%%@%%'",searchForText)] ;
        self.listResult = list ;
    }
    else
        self.listResult = @[] ;
    
    endRefresh() ;
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
    [MarkdownVC newWithNote:aNote bookID:aNote.noteBookId fromCtrller:self] ;
}

- (UIView *)makePlaceHolderView {
    SearchEmptyVC *phVC = [SearchEmptyVC getCtrllerFromNIBWithBundle:[NSBundle bundleForClass:self.class]] ;
    
    return phVC.view ;
}

- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES ;
}






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
