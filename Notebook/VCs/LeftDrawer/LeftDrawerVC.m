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

typedef void(^BlkBookSelectedChange)(NoteBooks *book);

@interface LeftDrawerVC () <UITableViewDelegate,UITableViewDataSource> {
    BOOL isFirst ;
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (copy, nonatomic) NSArray *booklist ;
@property (copy, nonatomic) BlkBookSelectedChange blkBookChange ;
@property (strong, nonatomic) UIView *btAdd ;
@end

@implementation LeftDrawerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _booklist = @[] ;
    
    @weakify(self)
    [RACObserve(self.currentBook, icRecordName) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        self.blkBookChange(self.currentBook) ;
    }] ;
}

- (void)prepareUI {
    [LDNotebookCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    self.table.separatorStyle = 0 ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.estimatedRowHeight           = 0 ;
    self.table.estimatedSectionHeaderHeight = 0 ;
    self.table.estimatedSectionFooterHeight = 0 ;
    
    self.btAdd.userInteractionEnabled = YES ;
    @weakify(self)
    [self.btAdd bk_whenTapped:^{
        @strongify(self)
        
        [UIAlertController xt_showTextFieldAlertWithTitle:@"新建笔记本" subtitle:nil cancel:@"取消" commit:@"确认" placeHolder:@"笔记本" callback:^(NSString *text) {
            
            
            
        }] ;
        
    }] ;
    
}

#pragma mark -

- (void)render {
    
    [NoteBooks fetchAllNoteBook:^(NSArray<NoteBooks *> * _Nonnull array) {
        
        self.booklist = [NoteBooks appendWithArray:array] ;
        [self.table reloadData] ;
        
        [self setCurrentBook:self.currentBook] ;
        if (!self->isFirst) {
            self->isFirst = YES ;
            [self setCurrentBook:[self.booklist firstObject]] ;
            self.blkBookChange([self.booklist firstObject]) ;
        }
    }] ;
}

- (void)setCurrentBook:(NoteBooks *)currentBook {
    _currentBook = currentBook ;
    
    [self.booklist enumerateObjectsUsingBlock:^(NoteBooks  *book, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([book.name isEqualToString:currentBook.name]) {
            [self.table selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:(UITableViewScrollPositionNone)] ;
        }
    }] ;
}

- (void)currentBookChanged:(void (^)(NoteBooks * _Nonnull))blkChange {
    self.blkBookChange = blkChange ;
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.booklist.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LDNotebookCell *cell = [LDNotebookCell xt_fetchFromTable:tableView] ;
    [cell setDistance:self.distance] ;
    [cell xt_configure:self.booklist[indexPath.row] indexPath:indexPath] ;
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
    [self setCurrentBook:self.booklist[row]] ;

}

#pragma mark -

- (UIView *)btAdd{
    if(!_btAdd){
        _btAdd = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 49, 49)];
            view.xt_gradientPt0 = CGPointMake(0,.5) ;
            view.xt_gradientPt1 = CGPointMake(0, 1) ;
            view.xt_gradientColor0 = UIColorHex(@"fe4241") ;
            view.xt_gradientColor1 = UIColorHex(@"fe8c68") ;
            
            UIImage *img = [UIImage image:[UIImage getImageFromView:view] rotation:(UIImageOrientationUp)] ;
            view = [[UIImageView alloc] initWithImage:img] ;
            view.xt_completeRound = YES ;
            if (!view.superview) {
                [self.view addSubview:view] ;
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(49, 49)) ;
                    make.left.equalTo(@(self.distance - 12 - 49)) ;
                    make.bottom.equalTo(@-28) ;
                }] ;
            }
            
            img = [img boxblurImageWithBlur:.2] ;
            UIView *shadow = [[UIImageView alloc] initWithImage:img] ;
            [self.view insertSubview:shadow belowSubview:view] ;
            shadow.alpha = .1 ;
            shadow.xt_completeRound = YES ;
            [shadow mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(49, 49)) ;
                make.centerY.equalTo(view).offset(15) ;
                make.centerX.equalTo(view) ;
            }] ;
            
            UIImageView *btIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ld_bt_add"]] ;
            [view addSubview:btIcon] ;
            [btIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(28, 28)) ;
                make.center.equalTo(view) ;
            }] ;
            view ;
        }) ;
    }
    return _btAdd;
}

@end
