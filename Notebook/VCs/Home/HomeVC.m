//
//  HomeVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeVC.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import <UIViewController+CWLateralSlide.h>
#import "LeftDrawerVC.h"
#import "NoteBooks.h"
#import "Note.h"
#import "NoteCell.h"
#import "MarkdownVC.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>
#import "HomeEmptyPHView.h"
#import "AppDelegate.h"
#import "LDHeadView.h"
#import "NewBookVC.h"
#import "MoveNoteToBookVC.h"
#import "LaunchingEvents.h"
#import "SearchVC.h"
#import "HomeVC+PanGestureHandler.h"
#import "HomeSearchCell.h"
#import "NewBookVC.h"


@interface HomeVC () <UITableViewDelegate, UITableViewDataSource, UITableViewXTReloaderDelegate, CYLTableViewPlaceHolderDelegate, MarkdownVCDelegate, SWRevealTableViewCellDataSource>
@property (weak, nonatomic) IBOutlet UIView *topSafeAreaView;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *topArea;
@property (weak, nonatomic) IBOutlet UILabel *nameOfNoteBook;
@property (weak, nonatomic) IBOutlet UILabel *lbUser;
@property (weak, nonatomic) IBOutlet UIButton *btAdd;
@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet UILabel *bookEmoji;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *juhua;

@property (strong, nonatomic) LeftDrawerVC *leftVC ;
@property (copy, nonatomic) NSArray *listNotes ;
@property (strong, nonatomic) HomeEmptyPHView *phView ;
@property (strong, nonatomic) NewBookVC *nBookVC ;
@end

@implementation HomeVC

#pragma mark - life

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    [self leftVC] ;
    self.listNotes = @[] ;
    
    self.fd_prefersNavigationBarHidden = YES ;
    
    @weakify(self)
    [self.leftVC currentBookChanged:^(NoteBooks *book, BOOL isClick) {
        @strongify(self)        
        [self.table xt_loadNewInfoInBackGround:YES] ;
        if (isClick) [self.leftVC dismissViewControllerAnimated:YES completion:nil] ;
        self.btAdd.hidden = book.vType == Notebook_Type_trash ;
        self.btMore.hidden = book.vType == Notebook_Type_trash || book.vType == Notebook_Type_recent || book.vType == Notebook_Type_staging ;
    }] ;
    
    [[[[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kNotificationSyncCompleteAllPageRefresh object:nil]
        takeUntil:self.rac_willDeallocSignal]
       deliverOnMainThread]
      throttle:.5] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.leftVC render] ;
        [self.table xt_loadNewInfoInBackGround:YES] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         [self.table reloadData] ;
     }] ;
    
    [[[RACSignal interval:5 onScheduler:[RACScheduler mainThreadScheduler]]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSDate * _Nullable x) {
         @strongify(self)
         if (self.view.window) {
             LaunchingEvents *events = ((AppDelegate *)[UIApplication sharedApplication].delegate).launchingEvents ;
             [events icloudSync:^{}] ;
         }
     }]  ;
    
    [self.leftVC render] ;
    [self.table xt_loadNewInfoInBackGround:YES] ;
}

- (void)renderTable:(void(^)(void))completion {
    if (self.leftVC.currentBook.vType == Notebook_Type_recent) {
        self.nameOfNoteBook.text = @"最近使用" ;
        self.bookEmoji.text = @"" ;
        self.listNotes = [Note xt_findWhere:@"isDeleted == 0 order by modifyDateOnServer DESC limit 20"] ;
        completion() ;
        return ;
    }
    else if (self.leftVC.currentBook.vType == Notebook_Type_trash) {
        self.nameOfNoteBook.text = @"垃圾桶" ;
        self.bookEmoji.text = @"" ;
        self.listNotes = [Note xt_findWhere:@"isDeleted == 1"] ;
        completion() ;
        return ;
    }
    else if (self.leftVC.currentBook.vType == Notebook_Type_staging) {
        self.nameOfNoteBook.text = @"暂存区" ;
        self.bookEmoji.text = @"" ;
        self.listNotes = [[Note xt_findWhere:@"noteBookId == '' and isDeleted == 0"] xt_orderby:@"modifyDateOnServer" descOrAsc:YES] ;
        completion() ;
        return ;
    }
    
    // note book normal
    self.nameOfNoteBook.text = self.leftVC.currentBook.name ;
    self.bookEmoji.text = self.leftVC.currentBook.displayEmoji ;
    
    @weakify(self)
    [Note noteListWithNoteBook:self.leftVC.currentBook completion:^(NSArray * _Nonnull list) {
        @strongify(self)
        self.listNotes = list ;
        completion() ;
    }] ;
}

- (void)openDrawer {
    if (![XTIcloudUser hasLogin]) {
        [XTIcloudUser alertUserToLoginICloud] ;
        return ;
    }
    
    [self.leftVC render] ;
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:self.movingDistance maskAlpha:0.1 scaleY:1 direction:CWDrawerTransitionFromLeft backImage:nil] ;
    [self cw_showDrawerViewController:self.leftVC animationType:0 configuration:conf] ;
}

- (void)prepareUI {
    self.lbUser.xt_theme_backgroundColor = k_md_themeColor ;
    self.lbUser.textColor = [UIColor whiteColor] ;
    
    [NoteCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [HomeSearchCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [self.table xt_setup] ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.xt_Delegate = self ;
    self.table.mj_footer = nil ;
    
    self.table.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_bgColor,1) ;
    
    self.table.contentInset = UIEdgeInsetsMake(10, 0, 0, 0) ;
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag ;
    
    self.topSafeAreaView.xt_theme_backgroundColor = k_md_bgColor ;
    self.topArea.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.bookEmoji.text = @"" ;
    self.nameOfNoteBook.text = @"";
    self.nameOfNoteBook.xt_theme_textColor = XT_MAKE_theme_color(k_md_homeTitleTextColor, .8) ;
    
    self.btAdd.xt_theme_imageColor = k_md_iconColor ;
    @weakify(self)
    [self.btAdd bk_addEventHandler:^(id sender) {
        @strongify(self)
        if (![XTIcloudUser hasLogin]) {
            [XTIcloudUser alertUserToLoginICloud] ;
            return ;
        }
        
        [MarkdownVC newWithNote:nil bookID:self.leftVC.currentBook.icRecordName fromCtrller:self] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    self.btMore.xt_theme_imageColor = k_md_iconColor ;
    [self.btMore bk_addEventHandler:^(id sender) {
        
        if (![XTIcloudUser hasLogin]) {
            [XTIcloudUser alertUserToLoginICloud] ;
            return ;
        }
        @weakify(self)
        [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除笔记本" otherButtonTitles:@[@"重命名笔记本"] callBackBlock:^(NSInteger btnIndex) {
            @strongify(self)
            if (btnIndex == 1) { //  rename book
                __block NoteBooks *aBook = self.leftVC.currentBook ;
                @weakify(self)
                self.nBookVC =
                [NewBookVC showMeFromCtrller:self editBook:aBook changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
                    @strongify(self)
                    aBook.name = bookName ;
                    aBook.emoji = [@{@"native":emoji} yy_modelToJSONString] ;
                    [NoteBooks updateMyBook:aBook] ;
                    self.nBookVC = nil ;
                    [self.leftVC render] ;
                    [self.leftVC setCurrentBook:aBook] ;
                } cancel:^{
                    @strongify(self)
                    self.nBookVC = nil ;
                }] ;
            }
            else if (btnIndex == 2) { // delete book
                @weakify(self)
                [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"删除笔记本" message:@"删除笔记本会将此笔记本内的文章都移入回收站" cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex1) {
                    @strongify(self)
                    if (btnIndex1 == 1) {
                        [NoteBooks deleteBook:self.leftVC.currentBook] ;
                        NoteBooks *book = [self.leftVC nextUsefulBook] ;
                        [self.leftVC refreshHomeWithBook:book] ;
                        [self.leftVC render:NO] ;
                    }
                }] ;

            }
        }] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    self.lbUser.userInteractionEnabled = YES ;
    [self.lbUser bk_whenTapped:^{
        @strongify(self)
        [self openDrawer] ;
    }] ;
    
    [self.leftVC render] ;
    [self cw_registerShowIntractiveWithEdgeGesture:NO transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        @strongify(self)
        if (direction == CWDrawerTransitionFromLeft) [self openDrawer] ;
    }] ;
    
    [[RACObserve([XTCloudHandler sharedInstance], isSyncingOnICloud) deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        bool isSync = [x boolValue] ;
        if (isSync) {
            [self.juhua startAnimating] ;
        }
        else {
            [self.juhua stopAnimating] ;
        }
        
        self.juhua.hidden = !isSync ;
    }] ;
    
    [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser *user) {
        @strongify(self)
        self.lbUser.text = [user.givenName substringToIndex:1] ;
    }] ;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
    [self.navigationController setNavigationBarHidden:YES animated:NO] ;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
}

#pragma mark - table

- (void)tableView:(UITableView *)table loadNew:(void (^)(void))endRefresh {
    [self renderTable:^{
        endRefresh() ;
    }] ;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1 ;
    return self.listNotes.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HomeSearchCell *cell = [HomeSearchCell xt_fetchFromTable:tableView] ;
        return cell ;
    }
    NoteCell *cell = [NoteCell xt_fetchFromTable:tableView] ;
    [cell xt_configure:self.listNotes[indexPath.row] indexPath:indexPath] ;
    cell.revealPosition = SWCellRevealPositionRightExtended ;
    cell.draggableBorderWidth = 200 ;
    cell.dataSource = self ;
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [HomeSearchCell xt_cellHeight] ;
    }
    return [NoteCell xt_cellHeight] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [SearchVC showSearchVCFrom:self] ;
        return ;
    }
    
    NSInteger row = indexPath.row ;
    Note *aNote = self.listNotes[row] ;
    [MarkdownVC newWithNote:aNote bookID:self.leftVC.currentBook.icRecordName fromCtrller:self] ;
}

- (UIView *)makePlaceHolderView {
    return self.phView ;
}

- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES ;
}

- (NSArray *)rightButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)cell1 {
    return [self setupPanList] ;
}

#pragma mark - MarkdownVCDelegate <NSObject>

- (void)addNoteComplete:(Note *)aNote {
    NSMutableArray *tmplist = [self.listNotes mutableCopy] ;
    [tmplist insertObject:aNote atIndex:0] ;
    self.listNotes = tmplist ;
    [self.table reloadData] ;
}

- (void)editNoteComplete:(Note *)aNote {
    NSMutableArray *tmplist = [self.listNotes mutableCopy] ;
    [self.listNotes enumerateObjectsUsingBlock:^(Note  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.icRecordName isEqualToString:aNote.icRecordName]) {
            [tmplist removeObjectAtIndex:idx] ;
            [tmplist insertObject:aNote atIndex:0] ;
            *stop = YES;
            return;
        }
    }] ;
    self.listNotes = tmplist ;
    [self.table reloadData] ;
}

#pragma mark - prop

- (LeftDrawerVC *)leftVC{
    if(!_leftVC){
        _leftVC = ({
            LeftDrawerVC * object = [LeftDrawerVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"LeftDrawerVC"] ;
            object.distance = self.movingDistance ;
            object;
       });
    }
    return _leftVC;
}

- (HomeEmptyPHView *)phView {
    if (!_phView) {
        _phView = [HomeEmptyPHView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        WEAK_SELF
        [_phView.btNewNote bk_addEventHandler:^(id sender) {
            [MarkdownVC newWithNote:nil bookID:weakSelf.leftVC.currentBook.icRecordName fromCtrller:weakSelf] ;
        } forControlEvents:(UIControlEventTouchUpInside)] ;
    }
    return _phView ;
}

- (CGFloat)movingDistance {
    return  62. / 75. * APP_WIDTH ;
}

@end
