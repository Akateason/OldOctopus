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
#import "Note.h"
#import "NewBookVC.h"
#import "HiddenUtil.h"
#import "NHSlidingController.h"
#import "UIViewController+SlidingController.h"
#import "HomeVC.h"
#import "SettingVC.h"
#import "SettingSave.h"


// lastBook
// @key     kUDCached_lastBook_RecID
// @value   recID,  trash, recent , staging 这三种的话就保存vType.toStr
static NSString *const kUDCached_lastBook_RecID = @"kUDCached_lastBook_RecID" ;

typedef void(^BlkBookSelectedHasChanged)(NoteBooks *book) ;
typedef void(^BlkTapBookCell)(void);

@interface LeftDrawerVC () <UITableViewDelegate, UITableViewDataSource, SWRevealTableViewCellDataSource, SWRevealTableViewCellDelegate, LDHeadViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btSetting;
@property (nonatomic)       BOOL    isFirstTime ;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top_table;

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (copy, nonatomic) NSArray *booklist ;
@property (copy, nonatomic) BlkBookSelectedHasChanged blkBookChanged ;
@property (copy, nonatomic) BlkTapBookCell blkTapped ;
@property (strong, nonatomic) UIView *btAdd ;

@property (weak, nonatomic) IBOutlet UIView *bottomArea;
@property (weak, nonatomic) IBOutlet UILabel *lbTrash;
@property (weak, nonatomic) IBOutlet UIImageView *imgTrash;

@property (strong, nonatomic) NoteBooks *bookTrash ;
@property (strong, nonatomic) NoteBooks *bookRecent ;
@property (strong, nonatomic) NoteBooks *bookStaging ;
@property (strong, nonatomic) NoteBooks *addBook ;

@property (strong, nonatomic) NewBookVC *nBookVC ;
@end

@implementation LeftDrawerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _booklist = @[] ;
    
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.table reloadData] ;
    }] ;        
}

- (void)prepareUI {
    self.top_table.constant = APP_STATUSBAR_HEIGHT ;
    
    [LDNotebookCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [self.table registerNib:[UINib nibWithNibName:@"LDHeadView" bundle:[NSBundle bundleForClass:self.class]] forCellReuseIdentifier:@"LDHeadView"] ;
    self.table.separatorStyle = 0 ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.estimatedRowHeight           = 0 ;
    self.table.estimatedSectionHeaderHeight = 0 ;
    self.table.estimatedSectionFooterHeight = 0 ;
    
    self.view.xt_theme_backgroundColor = k_md_drawerColor ;
    self.table.xt_theme_backgroundColor = k_md_drawerColor ;
    self.bottomArea.xt_theme_backgroundColor = k_md_drawerColor ;
    
    self.lbTrash.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    self.imgTrash.xt_theme_imageColor = k_md_iconColor ;
    
//    self.bottomArea.userInteractionEnabled = YES ;
    @weakify(self)
//    [self.bottomArea bk_whenTapped:^{
//        @strongify(self)
////        [self setCurrentBook:self.bookTrash] ;
////        self.blkBookChanged(self.bookTrash) ;
////        self.blkTapped() ;
//    }] ;
    
    // 清数据 暗开关
    [self.bottomArea bk_whenTouches:2 tapped:7 handler:^{
        [HiddenUtil showAlert] ;
    }] ;
    
    [self.btSetting xt_enlargeButtonsTouchArea] ;
    [self.btSetting bk_whenTapped:^{
        @strongify(self)
        [SettingVC getMeFromCtrller:self.slidingController fromView:self.btSetting] ;
    }] ;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated] ;
    
    self.lbTrash.text = XT_STR_FORMAT(@"垃圾桶 (%d)",[Note xt_countWhere:@"isDeleted == 1"]) ;
}

#pragma mark -

- (void)render {
    self.bookTrash = [NoteBooks createOtherBookWithType:(Notebook_Type_trash)] ;
    self.lbTrash.text = XT_STR_FORMAT(@"垃圾桶 (%d)",[Note xt_countWhere:@"isDeleted == 1"]) ;
    
    bool lastRecentOnSelect = self.bookRecent.isOnSelect ;
    self.bookRecent = [NoteBooks createOtherBookWithType:Notebook_Type_recent] ;
    self.bookRecent.isOnSelect = lastRecentOnSelect ;
    
    bool lastStagingOnSelect = self.bookStaging.isOnSelect ;
    self.bookStaging = [NoteBooks createOtherBookWithType:Notebook_Type_staging] ;
    self.bookStaging.isOnSelect = lastStagingOnSelect ;
    
    // cell addBook can't be selected
    self.addBook = [NoteBooks createOtherBookWithType:Notebook_Type_add] ;
    
    [NoteBooks fetchAllNoteBook:^(NSArray<NoteBooks *> * _Nonnull array) {
        self.booklist = array ;
        
        if (self.currentBook == nil) {
            NoteBooks *book = [self nextUsefulBook] ;
            [self setCurrentBook:book] ;
        }
        else {
            [self setCurrentBook:self.currentBook] ;
        }
        
        self.blkBookChanged(self.currentBook) ;
        [self.table reloadData] ;
    }] ;
}

- (NoteBooks *)nextUsefulBook {
    if (!_isFirstTime) {
        NSString *value = XT_USERDEFAULT_GET_VAL(kUDCached_lastBook_RecID) ;
        NoteBooks *book ;
        if (value) {
            book = [NoteBooks xt_findFirstWhere:XT_STR_FORMAT(@"icRecordName == '%@'",value)] ;
            if (!book) book = [NoteBooks createOtherBookWithType:value.intValue] ;
            _isFirstTime = YES ;
        }
        else {
            book = [NoteBooks xt_findFirstWhere:@"icRecordName == 'book-default'"] ;
        }
        if (book) return book ;
    }
    
    if (self.booklist && self.booklist.count) {
        return self.booklist.firstObject ;
    }
    return  self.bookStaging ;
}

- (void)setCurrentBook:(NoteBooks *)currentBook {
    _currentBook = currentBook ;
    
    NSString *cachedValue ;
    if (currentBook.vType == Notebook_Type_trash || currentBook.vType == Notebook_Type_recent || currentBook.vType == Notebook_Type_staging) {
        cachedValue = @(currentBook.vType).stringValue ;
    }
    else {
        cachedValue = currentBook.icRecordName ;
    }
    if (currentBook.name) XT_USERDEFAULT_SET_VAL(cachedValue, kUDCached_lastBook_RecID) ;
    
    [self.booklist enumerateObjectsUsingBlock:^(NoteBooks  *book, NSUInteger idx, BOOL * _Nonnull stop) {
        book.isOnSelect = NO ;
        if ([book.icRecordName isEqualToString:currentBook.icRecordName]) {
            book.isOnSelect = YES ;
        }
    }] ;
    
    self.bookTrash.isOnSelect = currentBook.vType == Notebook_Type_trash ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData] ;
    }) ;
}

- (void)currentBookChanged:(void(^)(NoteBooks *book))blkChange {
    self.blkBookChanged = blkChange ;
}

- (void)bookCellTapped:(void(^)(void))blk {
    self.blkTapped = blk ;
}

- (void)refreshHomeWithBook:(NoteBooks *)book {
    self.currentBook = book ;
    self.blkBookChanged(book) ;
}

#pragma mark - LDHeadViewDelegate <NSObject>

- (void)LDHeadDidSelectedOneBook:(NoteBooks *)abook {
    self.addBook.isOnSelect = NO ; // abook.vType == Notebook_Type_add ;
    self.bookRecent.isOnSelect = abook.vType == Notebook_Type_recent ;
    self.bookStaging.isOnSelect = abook.vType == Notebook_Type_staging ;
    
    if (abook.vType == Notebook_Type_add) {
        [self addbook] ;
        return ;
    }
    
    self.bookTrash.isOnSelect = NO ;
    [self setCurrentBook:abook] ;
    self.blkBookChanged(self.currentBook) ;
    self.blkTapped() ;
}

- (void)addbook {
    @weakify(self)
    self.nBookVC =
    [NewBookVC showMeFromCtrller:self
                        fromView:self.table
                         changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
        @strongify(self)
        // create new book
        NoteBooks *aBook = [[NoteBooks alloc] initWithName:bookName emoji:emoji] ;
        [NoteBooks createNewBook:aBook] ;
        self.nBookVC = nil ;
        
        [self render] ;
        [self setCurrentBook:aBook] ;
        self.blkBookChanged(aBook) ;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.slidingController setDrawerOpened:NO animated:YES] ;
        });
        
    } cancel:^{
        self.nBookVC = nil ;
    }] ;
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.booklist.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LDNotebookCell *cell = [LDNotebookCell xt_fetchFromTable:tableView] ;
    cell.dataSource = self ;
    cell.delegate = self ;
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
    headView.ld_delegate = self ;
    [headView setupUser] ;
    headView.bookRecent = self.bookRecent ;
    headView.bookStaging = self.bookStaging ;
    headView.addBook = self.addBook ;
    
    return headView ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 287. ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row ;
//    NSInteger section = indexPath.section ;
    self.bookTrash.isOnSelect = NO ;
    self.bookRecent.isOnSelect = NO ;
    self.addBook.isOnSelect = NO ;
    self.bookStaging.isOnSelect = NO ;
    
    [self setCurrentBook:self.booklist[row]] ;
    self.blkBookChanged(self.currentBook) ;
    self.blkTapped() ;
}

- (NSArray*)rightButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell {
    UIColor *itemBgColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_drawerColor, 1) ;
    
    SWCellButtonItem *item1 = [SWCellButtonItem itemWithImage:[UIImage imageNamed:@"home_del_note"] handler:^BOOL(SWCellButtonItem *item, SWRevealTableViewCell *cell) {
// delete book
        NoteBooks *aBook = ((LDNotebookCell *)cell).xt_model ;
        [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"删除笔记本" message:@"删除笔记本会将此笔记本内的文章都移入回收站" cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
            if (btnIndex == 1) {
                
                [NoteBooks deleteBook:aBook done:^{
                    self.currentBook = nil ;
                    [self render] ;
                }] ;
                
            }
        }] ;
        return YES ;
    }] ;
    item1.backgroundColor = itemBgColor ;
    item1.tintColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .6) ;
    item1.width = 60;
    
    SWCellButtonItem *item2 = [SWCellButtonItem itemWithImage:[UIImage imageNamed:@"home_edit_book"] handler:^BOOL(SWCellButtonItem *item, SWRevealTableViewCell *cell) {
// edit book
        NoteBooks *aBook = ((LDNotebookCell *)cell).xt_model ;
        [self editBook:aBook] ;
        return YES ;
    }] ;
    item2.backgroundColor = itemBgColor ;
    item2.tintColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .6) ;
    item2.width = 60;
    return @[item1, item2] ;
}

- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell willMoveToPosition:(SWCellRevealPosition)position {
    if (position == SWCellRevealPositionLeft) {
        LDNotebookCell *aCell = (LDNotebookCell *)revealTableViewCell ;
        NSArray *visibleCells = [self.table visibleCells] ;
        for (UITableViewCell *cell in visibleCells) {
            
            if ( [cell isKindOfClass:[SWRevealTableViewCell class]] &&
                ((SWRevealTableViewCell *)cell).revealPosition != SWCellRevealPositionCenter &&
                cell.xt_indexPath.row != aCell.xt_indexPath.row )
                
                [(SWRevealTableViewCell *)cell setRevealPosition:SWCellRevealPositionCenter animated:YES] ;
        }
    }
}

- (void)editBook:(NoteBooks *)book {
    __block NoteBooks *aBook = book ;
    @weakify(self)
    self.nBookVC =
    [NewBookVC showMeFromCtrller:self
                        fromView:self.table
                        editBook:aBook
                         changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
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
