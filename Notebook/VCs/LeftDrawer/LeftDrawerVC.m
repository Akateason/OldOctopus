//
//  LeftDrawerVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "LeftDrawerVC.h"
#import "LDHeadView.h"
#import "LDNotebookCell.h"
#import "NoteBooks.h"

@interface LeftDrawerVC () <UITableViewDelegate,UITableViewDataSource>
{
    BOOL isFirst ;
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (copy, nonatomic) NSArray *booklist ;
@end

@implementation LeftDrawerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _booklist = @[] ;
    
}

- (void)prepareUI {
    [LDNotebookCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    self.table.separatorStyle = 0 ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.estimatedRowHeight           = 0;
    self.table.estimatedSectionHeaderHeight = 0;
    self.table.estimatedSectionFooterHeight = 0;
}

#pragma mark -

- (void)render {
    
    [NoteBooks fetchAllNoteBook:^(NSArray<NoteBooks *> * _Nonnull array) {
        self.booklist = array ;
        [self.table reloadData] ;
        
        if (!self->isFirst) {
            self->isFirst = YES ;
            [self.table selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:(UITableViewScrollPositionNone)] ;
        }
    }] ;
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.booklist.count + 2 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row ;
    LDNotebookCell *cell = [LDNotebookCell xt_fetchFromTable:tableView] ;
    if (row < self.booklist.count) {
        cell.imgView.hidden = YES ;
        cell.lbEmoji.hidden = NO ;
        [cell xt_configure:self.booklist[indexPath.row] indexPath:indexPath] ;
        [cell setDistance:self.distance] ;
    }
    else if (row == self.booklist.count) { // recent
        cell.imgView.hidden = NO ;
        cell.lbEmoji.hidden = YES ;
        cell.imgView.image = [UIImage imageNamed:@"ld_bt_recent"] ;
        cell.lbName.text = @"最近使用" ;
    }
    else if (row == self.booklist.count + 1) { // trash
        cell.imgView.hidden = NO ;
        cell.lbEmoji.hidden = YES ;
        cell.imgView.image = [UIImage imageNamed:@"ld_bt_trash"] ;
        cell.lbName.text = @"垃圾桶" ;
    }
    
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LDNotebookCell xt_cellHeight] ;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LDHeadView *headView = (LDHeadView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"LDheadView"] ;
    if (!headView) {
        headView = [LDHeadView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    }
    [headView setupUser] ;
    return headView ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 78.f ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row ;
    if (row < self.booklist.count) { // book
        
    }
    else if (row == self.booklist.count) { // recent
        
    }
    else if (row == self.booklist.count + 1) { // trash
        
    }

}

@end
