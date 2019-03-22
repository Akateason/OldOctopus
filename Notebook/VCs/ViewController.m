//
//  ViewController.m
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "ViewController.h"
#import <XTlib/XTlib.h>

#import "MDToolBar.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UITableViewXTReloaderDelegate>

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self.table xt_setup];
//    self.table.xt_Delegate = self;
    
    
    MDToolbar *toolbar = [[MDToolbar alloc] initWithConfigList:nil] ;
    [self.view addSubview:toolbar] ;
    [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop) ;
        make.right.left.equalTo(self.view) ;
        make.height.equalTo(@41) ;
    }] ;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    [self.table xt_loadNewInfoInBackGround:YES];
}

#pragma mark - table
//
//- (void)tableView:(UITableView *)table loadNew:(void (^)(void))endRefresh {
//    self.datasource = [NoteModel xt_findAll];
//    endRefresh();
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.datasource.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aCell" forIndexPath:indexPath];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"aCell"];
//    }
//
//    NoteModel *model    = self.datasource[indexPath.row];
//    cell.textLabel.text = model.title;
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//}
//
//
//#pragma mark - props
//
//- (NSArray *)datasource {
//    if (!_datasource) {
//        _datasource = ({
//            NSArray *object = [[NSArray alloc] init];
//            object;
//        });
//    }
//    return _datasource;
//}

@end
