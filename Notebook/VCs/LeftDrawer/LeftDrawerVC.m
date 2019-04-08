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
#import <UIViewController+CWLateralSlide.h>
#import "Note.h"
#import "NewBookVC.h"

typedef void(^BlkBookSelectedChange)(NoteBooks *book);

@interface LeftDrawerVC () <UITableViewDelegate, UITableViewDataSource> {
    BOOL isFirst ;
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (copy, nonatomic) NSArray *booklist ;
@property (copy, nonatomic) BlkBookSelectedChange blkBookChange ;
@property (strong, nonatomic) UIView *btAdd ;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flexTrailOfTable;
@property (weak, nonatomic) IBOutlet UIView *bottomArea;
@property (weak, nonatomic) IBOutlet UILabel *lbTrash;

@property (strong, nonatomic) NoteBooks *bookRecent ;
@property (strong, nonatomic) NoteBooks *bookTrash ;

@property (strong, nonatomic) NewBookVC *nBookVC ;
@end

@implementation LeftDrawerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _booklist = @[] ;
    
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotification_AddBook object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        self.nBookVC = [NewBookVC showMeFromCtrller:self changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
            // create new book
            NoteBooks *aBook = [[NoteBooks alloc] initWithName:bookName emoji:emoji] ;
            [NoteBooks createNewBook:aBook] ;
            self.nBookVC = nil ;
            
            [self render] ;
            [self setCurrentBook:aBook] ;
//            self.blkBookChange(aBook) ;
        } cancel:^{
            self.nBookVC = nil ;
        }] ;
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
    
    self.flexTrailOfTable.constant = APP_WIDTH - self.distance ;
    
    self.lbTrash.textColor = [MDThemeConfiguration sharedInstance].textColor ;
    self.lbTrash.alpha = .4 ;
    self.bottomArea.userInteractionEnabled = YES ;
    @weakify(self)
    [self.bottomArea bk_whenTapped:^{
        @strongify(self)
        [self setCurrentBook:self.bookTrash] ;
        self.blkBookChange(self.bookTrash) ;
    }] ;
}

#pragma mark -

- (void)render {
    self.bookRecent = [NoteBooks createOtherBookWithType:(Notebook_Type_recent)] ;
    self.bookTrash = [NoteBooks createOtherBookWithType:(Notebook_Type_trash)] ;
    self.lbTrash.text = XT_STR_FORMAT(@"垃圾桶 (%d)",[Note xt_countWhere:@"isDeleted == 1"]) ;
    
    [NoteBooks fetchAllNoteBook:^(NSArray<NoteBooks *> * _Nonnull array) {
        
        if (!array.count) return ;
                    
        self.booklist = [NoteBooks appendWithArray:array] ;
        [self setCurrentBook:self.currentBook] ;
        
        if (!self->isFirst) {
            self->isFirst = YES ;
            [self setCurrentBook:self.bookRecent] ;
            self.blkBookChange(self.bookRecent) ;
        }
    }] ;
}

- (void)setCurrentBook:(NoteBooks *)currentBook {
    _currentBook = currentBook ;
    
    [self.booklist enumerateObjectsUsingBlock:^(NoteBooks  *book, NSUInteger idx, BOOL * _Nonnull stop) {
        book.isOnSelect = NO ;
        if ([book.icRecordName isEqualToString:currentBook.icRecordName]) {
            book.isOnSelect = YES ;
        }
    }] ;
    
    self.bookRecent.isOnSelect = currentBook.vType == Notebook_Type_recent ;
    self.bookTrash.isOnSelect = currentBook.vType == Notebook_Type_trash ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData] ;
    }) ;
}

- (void)currentBookChanged:(void (^)(NoteBooks * _Nonnull))blkChange {
    self.blkBookChange = blkChange ;
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2 ;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1 ;
    }
    else if (section == 1) {
        return self.booklist.count ;
    }
    return 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LDNotebookCell *cell = [LDNotebookCell xt_fetchFromTable:tableView] ;
    if (indexPath.section == 0) {
        [cell xt_configure:self.bookRecent indexPath:indexPath] ;
    }
    else if (indexPath.section == 1) {
        [cell xt_configure:self.booklist[indexPath.row] indexPath:indexPath] ;
    }
    
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LDNotebookCell xt_cellHeight] ;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section != 0) return nil ;
    
    LDHeadView *headView = (LDHeadView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"LDheadView"] ;
    if (!headView) {
        headView = [LDHeadView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    }
    [headView setupUser] ;
    return headView ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section != 0) return 0 ;
    return 137.5 ;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section != 0) return nil ;
    return [UIView new] ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section != 0) return 0 ;
    return 10. ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row ;
    NSInteger section = indexPath.section ;
    self.bookRecent.isOnSelect = NO ;
    self.bookTrash.isOnSelect = NO ;
    
    if (section == 0) {
        self.currentBook = self.bookRecent ;
        self.blkBookChange(self.currentBook) ;
    }
    else if (section == 1) {
        [self setCurrentBook:self.booklist[row]] ;
        self.blkBookChange(self.currentBook) ;
    }
}

@end
