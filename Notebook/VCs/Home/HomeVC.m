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


@interface HomeVC () <UITableViewDelegate, UITableViewDataSource, UITableViewXTReloaderDelegate, CYLTableViewPlaceHolderDelegate, MarkdownVCDelegate, SWRevealTableViewCellDataSource>
@property (weak, nonatomic) IBOutlet UIView *topSafeAreaView;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *topArea;
@property (weak, nonatomic) IBOutlet UILabel *nameOfNoteBook;
@property (weak, nonatomic) IBOutlet UIButton *btLeftDrawer;
@property (weak, nonatomic) IBOutlet UIImageView *ImgBtSearch;
@property (weak, nonatomic) IBOutlet UILabel *bookEmoji;

@property (strong, nonatomic) UIView *btAdd ;

@property (strong, nonatomic) LeftDrawerVC *leftVC ;
@property (copy, nonatomic) NSArray *listNotes ;
@end

@implementation HomeVC

#pragma mark - life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listNotes = @[] ;
    
    self.fd_prefersNavigationBarHidden = YES ;
    
    @weakify(self)
    [self.leftVC currentBookChanged:^(NoteBooks * _Nonnull book, BOOL isClick) {
        @strongify(self)        
        [self.table xt_loadNewInfoInBackGround:YES] ;
        if (isClick) [self.leftVC dismissViewControllerAnimated:YES completion:nil] ;
    }] ;
    
    [[[[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kNotificationSyncCompleteAllPageRefresh object:nil]
        takeUntil:self.rac_willDeallocSignal]
       deliverOnMainThread]
      throttle:1] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.leftVC render] ;
        [self.table xt_loadNewInfo] ;
//        [self.table xt_loadNewInfoInBackGround:YES] ;
    }] ;
    
    
}

- (void)renderTable:(void(^)(void))completion {
    if (self.leftVC.currentBook.vType == Notebook_Type_recent) {
        self.nameOfNoteBook.text = @"最近使用" ;
        self.bookEmoji.text = @"" ;
        self.listNotes = [Note xt_findWhere:@"isDeleted == 0 order by xt_updateTime DESC limit 20"] ;
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
    [self.leftVC render] ;
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:self.movingDistance maskAlpha:0.1 scaleY:1 direction:CWDrawerTransitionFromLeft backImage:nil] ;
    [self cw_showDrawerViewController:self.leftVC animationType:0 configuration:conf];
}

- (void)prepareUI {
    [NoteCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [self.table xt_setup] ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.xt_Delegate = self ;
    self.table.mj_footer = nil ;
    self.table.backgroundColor = [MDThemeConfiguration sharedInstance].homeTableBGColor ;
    self.table.contentInset = UIEdgeInsetsMake(10, 0, 0, 0) ;
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag ;
    
    self.topSafeAreaView.backgroundColor = [UIColor whiteColor] ;
    
    self.bookEmoji.text = @"" ;
    self.nameOfNoteBook.text = @"";
    self.nameOfNoteBook.textColor = [MDThemeConfiguration sharedInstance].homeTitleTextColor ;
    self.topArea.backgroundColor = [UIColor whiteColor] ;
    
    self.btAdd.userInteractionEnabled = YES ;
    @weakify(self)
    [self.btAdd bk_whenTapped:^{
        @strongify(self)
        [MarkdownVC newWithNote:nil bookID:self.leftVC.currentBook.icRecordName fromCtrller:self] ;
    }] ;
    
    [self.btLeftDrawer bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self openDrawer] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [self.leftVC render] ;
    [self cw_registerShowIntractiveWithEdgeGesture:NO transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        @strongify(self)
        if (direction == CWDrawerTransitionFromLeft) [self openDrawer] ;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listNotes.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteCell *cell = [NoteCell xt_fetchFromTable:tableView] ;
    [cell xt_configure:self.listNotes[indexPath.row] indexPath:indexPath] ;
    cell.dataSource = self;
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoteCell xt_cellHeight] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row ;
    Note *aNote = self.listNotes[row] ;
    [MarkdownVC newWithNote:aNote bookID:self.leftVC.currentBook.icRecordName fromCtrller:self] ;
}

- (UIView *)makePlaceHolderView {
    HomeEmptyPHView *phView = [HomeEmptyPHView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    WEAK_SELF
    [phView.btNewNote bk_addEventHandler:^(id sender) {
        [MarkdownVC newWithNote:nil bookID:weakSelf.leftVC.currentBook.icRecordName fromCtrller:weakSelf] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    return phView ;
}

- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES ;
}

- (NSArray *)rightButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)cell1 {
    SWCellButtonItem *item1 = [SWCellButtonItem itemWithTitle:@"删除" handler:^BOOL(SWCellButtonItem *item, SWRevealTableViewCell *cell) {
        Note *aNote = ((NoteCell *)cell).xt_model ;
// Delete Note
        [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"确认要删除此文章吗?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
            if (btnIndex == 1) {
                aNote.isDeleted = YES ;
                [Note updateMyNote:aNote] ;
                [self.table xt_loadNewInfoInBackGround:YES] ;
            }
        }] ;
        return YES ;
    }] ;
    item1.backgroundColor = [MDThemeConfiguration sharedInstance].themeColor ;
    item1.tintColor = [UIColor whiteColor] ;
    item1.width = 60 ;
    item1.image = [UIImage imageNamed:@"home_del_note"] ;
    
    SWCellButtonItem *item2 = [SWCellButtonItem itemWithTitle:@"移动" handler:^BOOL(SWCellButtonItem *item, SWRevealTableViewCell *cell) {
        Note *aNote = ((NoteCell *)cell).xt_model ;
// Move Note
        [MoveNoteToBookVC showFromCtrller:self] ;
        // todo
        
        return YES ;
    }] ;
    item2.backgroundColor = [UIColor colorWithWhite:0 alpha:.6] ;
    item2.tintColor = [UIColor whiteColor] ;
    item2.width = 60 ;
    item2.image = [UIImage imageNamed:@"home_move_note"] ;
    return @[item1,item2] ;
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
                    make.right.equalTo(@-12) ;
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
            
            UIImageView *btIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bt_home_add"]] ;
            [view addSubview:btIcon] ;
            [btIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(28, 28)) ;
                make.center.equalTo(view) ;
            }] ;
            view ;
       }) ;
    }
    return _btAdd ;
}

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

- (CGFloat)movingDistance {
    return  62. / 75. * APP_WIDTH ;
}

@end
