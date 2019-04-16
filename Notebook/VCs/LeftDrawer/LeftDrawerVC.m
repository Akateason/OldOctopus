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


typedef void(^BlkBookSelectedChange)(NoteBooks *book, BOOL isClick) ;

@interface LeftDrawerVC () <UITableViewDelegate, UITableViewDataSource, SWRevealTableViewCellDataSource> {
    BOOL isFirst ;
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (copy, nonatomic) NSArray *booklist ;
@property (copy, nonatomic) BlkBookSelectedChange blkBookChange ;
@property (strong, nonatomic) UIView *btAdd ;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flexTrailOfTable;
@property (weak, nonatomic) IBOutlet UIView *bottomArea;
@property (weak, nonatomic) IBOutlet UILabel *lbTrash;
@property (weak, nonatomic) IBOutlet UIButton *btTheme;

@property (strong, nonatomic) NoteBooks *bookRecent ;
@property (strong, nonatomic) NoteBooks *bookTrash ;

@property (strong, nonatomic) NewBookVC *nBookVC ;
@end

@implementation LeftDrawerVC

- (IBAction)themeChange:(UIButton *)sender {
    if (!sender.selected) {
        [sender setTitle:@"黑" forState:0] ;
        [[MDThemeConfiguration sharedInstance] changeTheme:@"themeDark"] ;
    }
    else {
        [sender setTitle:@"白" forState:0] ;
        [[MDThemeConfiguration sharedInstance] changeTheme:@"themeDefault"] ;
    }
    sender.selected = !sender.selected ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _booklist = @[] ;
    
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotification_AddBook object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        self.nBookVC =
        [NewBookVC showMeFromCtrller:self changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
            // create new book
            NoteBooks *aBook = [[NoteBooks alloc] initWithName:bookName emoji:emoji] ;
            [NoteBooks createNewBook:aBook] ;
            self.nBookVC = nil ;
            
            [self render] ;
            [self setCurrentBook:aBook] ;
            self.blkBookChange(aBook, NO) ;
            
        } cancel:^{
            self.nBookVC = nil ;
        }] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.table reloadData] ;
    }] ;
}

- (void)prepareUI {
//    self.view.backgroundColor = [UIColor blackColor] ;
    
    [LDNotebookCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    self.table.separatorStyle = 0 ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.estimatedRowHeight           = 0 ;
    self.table.estimatedSectionHeaderHeight = 0 ;
    self.table.estimatedSectionFooterHeight = 0 ;
    self.table.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.flexTrailOfTable.constant = APP_WIDTH - self.distance ;
    
    self.lbTrash.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    self.bottomArea.xt_theme_backgroundColor = k_md_bgColor ;
    self.bottomArea.userInteractionEnabled = YES ;
    @weakify(self)
    [self.bottomArea bk_whenTapped:^{
        @strongify(self)
        [self setCurrentBook:self.bookTrash] ;
        self.blkBookChange(self.bookTrash, YES) ;
    }] ;
}

#pragma mark -

- (void)render {
    [self render:YES] ;
}

- (void)render:(BOOL)goHome {
    self.bookRecent = [NoteBooks createOtherBookWithType:(Notebook_Type_recent)] ;
    self.bookTrash = [NoteBooks createOtherBookWithType:(Notebook_Type_trash)] ;
    self.lbTrash.text = XT_STR_FORMAT(@"垃圾桶 (%d)",[Note xt_countWhere:@"isDeleted == 1"]) ;
    
    [NoteBooks fetchAllNoteBook:^(NSArray<NoteBooks *> * _Nonnull array) {
        
        if (!array.count) return ;
                    
        self.booklist = array ;
        [self setCurrentBook:self.currentBook] ;
        
        if (!self->isFirst) {
            self->isFirst = YES ;
            [self setCurrentBook:self.booklist.firstObject] ;
            self.blkBookChange(self.booklist.firstObject, goHome) ;
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

- (void)currentBookChanged:(void(^)(NoteBooks *book, BOOL isClick))blkChange {
    self.blkBookChange = blkChange ;
}

- (void)refreshHomeWithBook:(NoteBooks *)book {
    self.currentBook = book ;
    self.blkBookChange(book, YES) ;
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
    cell.dataSource = self ;
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
        self.blkBookChange(self.currentBook, YES) ;
    }
    else if (section == 1) {
        [self setCurrentBook:self.booklist[row]] ;
        self.blkBookChange(self.currentBook, YES) ;
    }
}

- (NSArray*)rightButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell {
    SWCellButtonItem *item1 = [SWCellButtonItem itemWithImage:[UIImage imageNamed:@"home_del_note"] handler:^BOOL(SWCellButtonItem *item, SWRevealTableViewCell *cell) {
// delete book
        NoteBooks *aBook = ((LDNotebookCell *)cell).xt_model ;
        [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"删除笔记本" message:@"删除笔记本会将此笔记本内的文章都移入回收站" cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
            if (btnIndex == 1) {
                [NoteBooks deleteBook:aBook] ;
                self->isFirst = NO ;
                [self render:NO] ;
            }
        }] ;
        return YES ;
    }] ;
    item1.xt_theme_backgroundColor = k_md_themeColor ;    
    item1.tintColor = [UIColor whiteColor];
    item1.width = 60;
    
    SWCellButtonItem *item2 = [SWCellButtonItem itemWithImage:[UIImage imageNamed:@"home_edit_book"] handler:^BOOL(SWCellButtonItem *item, SWRevealTableViewCell *cell) {
// edit book
        NoteBooks *aBook = ((LDNotebookCell *)cell).xt_model ;
        [self editBook:aBook] ;
        return YES ;
    }] ;
    item2.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
    item2.tintColor = [UIColor whiteColor];
    item2.width = 60;
    return @[item1, item2] ;
}

- (void)editBook:(NoteBooks *)book {
    __block NoteBooks *aBook = book ;
    @weakify(self)
    self.nBookVC =
    [NewBookVC showMeFromCtrller:self editBook:aBook changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
        @strongify(self)
        aBook.name = bookName ;
        aBook.emoji = [@{@"native":emoji} yy_modelToJSONString] ;
        [NoteBooks updateMyBook:aBook] ;
        self.nBookVC = nil ;
        [self render] ;
        [self setCurrentBook:aBook] ;
    } cancel:^{
        @strongify(self)
        self.nBookVC = nil ;
    }] ;
}

@end
