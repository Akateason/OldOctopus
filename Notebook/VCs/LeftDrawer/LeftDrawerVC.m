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

@interface LeftDrawerVC () <UITableViewDelegate,UITableViewDataSource,UITableViewXTReloaderDelegate>
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
    self.table.dataSource = self ;
    self.table.delegate = self ;
    [self.table xt_setup] ;
    self.table.xt_Delegate = self ;
}

#pragma mark -

- (void)tableView:(UITableView *)table loadNew:(void (^)(void))endRefresh {
    
    [NoteBooks fetchAllNoteBook:^(NSArray<NoteBooks *> * _Nonnull array) {
        
        self.booklist = array ;
        endRefresh() ;
    }] ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.booklist.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LDNotebookCell *cell = [LDNotebookCell xt_fetchFromTable:tableView] ;
    [cell xt_configure:self.booklist[indexPath.row] indexPath:indexPath] ;
    [cell setDistance:self.distance] ;
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



@end
