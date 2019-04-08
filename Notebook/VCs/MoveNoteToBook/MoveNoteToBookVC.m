//
//  MoveNoteToBookVC.m
//  Notebook
//
//  Created by teason23 on 2019/4/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MoveNoteToBookVC.h"
#import "LDNotebookCell.h"

@interface MoveNoteToBookVC () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btClose;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView *imgRightCornerPaint;

@property (copy, nonatomic) NSArray *booklist ;
@end

@implementation MoveNoteToBookVC

+ (instancetype)showFromCtrller:(UIViewController *)ctrller {
    MoveNoteToBookVC *vc = [MoveNoteToBookVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"MoveNoteToBookVC"] ;
    [ctrller presentViewController:vc animated:YES completion:^{
    }] ;
    
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.booklist = [NoteBooks xt_findWhere:@"isOnSelect == 0"] ;
    self.table.separatorStyle = 0 ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    [LDNotebookCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    WEAK_SELF
    [self.btClose bk_addEventHandler:^(id sender) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
        }] ;
        
    } forControlEvents:UIControlEventTouchUpInside] ;
}

- (void)prepareUI {
    self.lbTitle.textColor = [MDThemeConfiguration sharedInstance].textColor ;
    
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.booklist.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LDNotebookCell *cell = [LDNotebookCell xt_fetchFromTable:tableView indexPath:indexPath] ;
    [cell xt_configure:self.booklist[indexPath.row] indexPath:indexPath] ;
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LDNotebookCell xt_cellHeight] ;
}

@end
