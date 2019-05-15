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
#import <UIViewController+CWLateralSlide.h>
#import "HiddenUtil.h"


typedef void(^BlkBookSelectedHasChanged)(NoteBooks *book) ;
typedef void(^BlkTapBookCell)(void);

@interface LeftDrawerVC () <UITableViewDelegate, UITableViewDataSource, SWRevealTableViewCellDataSource, SWRevealTableViewCellDelegate, LDHeadViewDelegate> {
    
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (copy, nonatomic) NSArray *booklist ;
@property (copy, nonatomic) BlkBookSelectedHasChanged blkBookChanged ;
@property (copy, nonatomic) BlkTapBookCell blkTapped ;
@property (strong, nonatomic) UIView *btAdd ;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flexTrailOfTable;
@property (weak, nonatomic) IBOutlet UIView *bottomArea;
@property (weak, nonatomic) IBOutlet UILabel *lbTrash;
@property (weak, nonatomic) IBOutlet UIButton *btTheme;
@property (weak, nonatomic) IBOutlet UIImageView *imgTrash;

@property (strong, nonatomic) NoteBooks *bookTrash ;
@property (strong, nonatomic) NoteBooks *bookRecent ;
@property (strong, nonatomic) NoteBooks *bookStaging ;
@property (strong, nonatomic) NoteBooks *addBook ;

@property (strong, nonatomic) NewBookVC *nBookVC ;
@end

@implementation LeftDrawerVC

- (IBAction)themeChange:(UIButton *)sender {
    
    __block UIButton *bt = sender ;
    
    UIView *circle = [UIView new] ;
    circle.backgroundColor = sender.selected ? UIColorHex(@"f9f6f6") : UIColorHex(@"2b2f33") ;
    CGPoint point = [self.bottomArea convertPoint:self.btTheme.center toView:self.view.window] ;
    circle.frame = CGRectMake(0, 0, APP_HEIGHT * 2, APP_HEIGHT * 2) ;
    circle.center = point ;
    circle.xt_completeRound = YES ;
    [self.view.window addSubview:circle] ;
    
    circle.layer.transform = CATransform3DMakeScale(0, 0, 1) ;
    
    [UIView animateWithDuration:.25 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
        circle.layer.transform = CATransform3DIdentity ;
        circle.alpha = .8 ;
    } completion:^(BOOL finished) {

        (!bt.selected) ? [[MDThemeConfiguration sharedInstance] changeTheme:@"themeDark"] : [[MDThemeConfiguration sharedInstance] changeTheme:@"themeDefault"] ;
        (!bt.selected) ? [bt setImage:[UIImage imageNamed:@"ld_theme_day"] forState:0] : [bt setImage:[UIImage imageNamed:@"ld_theme_night"] forState:0] ;
        bt.selected = !bt.selected ;
        
        [circle removeFromSuperview] ;
    }] ;
}

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
    
    (self.btTheme.selected) ? [self.btTheme setImage:[UIImage imageNamed:@"ld_theme_day"] forState:0] : [self.btTheme setImage:[UIImage imageNamed:@"ld_theme_night"] forState:0] ;

}

- (void)prepareUI {
    [LDNotebookCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    self.table.separatorStyle = 0 ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.estimatedRowHeight           = 0 ;
    self.table.estimatedSectionHeaderHeight = 0 ;
    self.table.estimatedSectionFooterHeight = 0 ;
    
    self.view.xt_theme_backgroundColor = k_md_drawerColor ;
    self.table.xt_theme_backgroundColor = k_md_drawerColor ;
    self.bottomArea.xt_theme_backgroundColor = k_md_drawerColor ;
    
    self.flexTrailOfTable.constant = APP_WIDTH - self.distance ;
    
    self.lbTrash.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    self.imgTrash.xt_theme_imageColor = k_md_iconColor ;
    
    self.btTheme.xt_theme_imageColor = k_md_iconColor ;
    [self.btTheme xt_enlargeButtonsTouchArea] ;
    self.btTheme.selected = ![[MDThemeConfiguration sharedInstance].currentThemeKey isEqualToString:@"themeDefault"] ;
    
    self.bottomArea.userInteractionEnabled = YES ;
    @weakify(self)
    [self.bottomArea bk_whenTapped:^{
        @strongify(self)
        [self setCurrentBook:self.bookTrash] ;
        self.blkBookChanged(self.bookTrash) ;
        self.blkTapped() ;
    }] ;
    
    
    // 暗开关
    [self.bottomArea bk_whenTouches:2 tapped:7 handler:^{
        [HiddenUtil showAlert] ;
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
    if (self.booklist && self.booklist.count) {
        return self.booklist.firstObject ;
    }
    return  self.bookStaging ;
}

- (void)setCurrentBook:(NoteBooks *)currentBook {
    _currentBook = currentBook ;
    
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
    [NewBookVC showMeFromCtrller:self changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
        @strongify(self)
        // create new book
        NoteBooks *aBook = [[NoteBooks alloc] initWithName:bookName emoji:emoji] ;
        [NoteBooks createNewBook:aBook] ;
        self.nBookVC = nil ;
        
        [self render] ;
        [self setCurrentBook:aBook] ;
        self.blkBookChanged(aBook) ;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil] ;
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
    return 239. ;
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
