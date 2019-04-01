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


@interface HomeVC () <UITableViewDelegate, UITableViewDataSource, UITableViewXTReloaderDelegate>
@property (weak, nonatomic) IBOutlet UIView *topSafeAreaView;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *topArea;
@property (weak, nonatomic) IBOutlet UILabel *nameOfNoteBook;
@property (weak, nonatomic) IBOutlet UIButton *btLeftDrawer;
@property (weak, nonatomic) IBOutlet UIView *vSearchBar;
@property (weak, nonatomic) IBOutlet UIImageView *imgSearch;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;
@property (weak, nonatomic) IBOutlet UILabel *lbUserName;
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
    [self.leftVC currentBookChanged:^(NoteBooks * _Nonnull book) {
        @strongify(self)
        if (book.vType == Notebook_Type_recent) {
            // todo
            return ;
        }
        else if (book.vType == Notebook_Type_trash) {
            // todo
            return ;
        }
        
        // note book
        [self renderTable:^{
            [self.table reloadData] ;
        }] ;
//        self.nameOfNoteBook.text = book.name ;
//        [Note noteListWithNoteBook:book completion:^(NSArray * _Nonnull list) {
//            self.listNotes = list ;
////            [self.table re]
//        }] ;
        
    }] ;
}

- (void)renderTable:(void(^)(void))completion {
    self.nameOfNoteBook.text = self.leftVC.currentBook.name ;
    @weakify(self)
    [Note noteListWithNoteBook:self.leftVC.currentBook completion:^(NSArray * _Nonnull list) {
        @strongify(self)
        self.listNotes = list ;
        completion() ;
    }] ;
}

- (void)openDrawer {
    [self.leftVC render] ;
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:self.movingDistance maskAlpha:0.06 scaleY:1 direction:CWDrawerTransitionFromLeft backImage:nil] ;
    [self cw_showDrawerViewController:self.leftVC animationType:0 configuration:conf];
}

- (void)prepareUI {
    [NoteCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [self.table xt_setup] ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.xt_Delegate = self ;
    self.table.backgroundColor = nil ;
    
    self.table.contentInset = UIEdgeInsetsMake(12, 0, 0, 0) ;
    
    self.topSafeAreaView.backgroundColor = [UIColor whiteColor] ;
    
    self.topArea.layer.shadowColor = UIColorHexA(@"000000", .05).CGColor ;
    self.topArea.layer.shadowOffset = CGSizeMake(0, 13) ;
    self.topArea.layer.shadowRadius = 40 ;
    self.topArea.layer.shadowOpacity = 1;
    
    self.nameOfNoteBook.text = @"";
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag ;
    self.nameOfNoteBook.textColor = UIColorHex(@"222222") ;
    self.topArea.backgroundColor = [UIColor whiteColor] ;
    self.vSearchBar.xt_borderColor = UIColorRGBA(20, 20, 20, .1) ;
    self.lbUserName.text = @"🐙" ;
    
    self.lbUserName.backgroundColor = [MDThemeConfiguration sharedInstance].themeColor ;
    [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser * _Nonnull user) {
        self.lbUserName.text = [user.givenName substringToIndex:1] ;
    }] ;
    
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
            view;
       });
    }
    return _btAdd;
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
    return  265. / 375. * APP_WIDTH ;
}

@end
