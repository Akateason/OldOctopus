//
//  OcHomeVC.m
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcHomeVC.h"
#import "OcBookCell.h"
#import "OcContainerCell.h"
#import "MDNavVC.h"


@interface OcHomeVC () <UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btUser;
@property (weak, nonatomic) IBOutlet UIButton *btSearch;
@property (weak, nonatomic) IBOutlet UIView *midBar;
@property (weak, nonatomic) IBOutlet UILabel *lbMyNotes;
@property (weak, nonatomic) IBOutlet UILabel *lbAll;
@property (weak, nonatomic) IBOutlet UIImageView *img_lbAllRight;//全部右角
@property (weak, nonatomic) IBOutlet UICollectionView *bookCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;

@property (nonatomic)                BOOL uiStatus_TopBar_turnSmall ; // Y - 短， N - 长， default - 长 ；

@end

@implementation OcHomeVC

+ (UIViewController *)getMe {
    OcHomeVC *topVC = [OcHomeVC getCtrllerFromStory:@"Home" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"OcHomeVC"] ;
    MDNavVC *navVC = [[MDNavVC alloc]initWithRootViewController:topVC] ;
    return navVC ;
}

#pragma mark - life

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_prefersNavigationBarHidden = YES ;
}

- (void)prepareUI {
    [OcBookCell      xt_registerNibFromCollection:self.bookCollectionView] ;
    [OcContainerCell xt_registerNibFromCollection:self.mainCollectionView] ;
    
    self.bookCollectionView.delegate    = self ;
    self.bookCollectionView.dataSource  = self ;
    self.mainCollectionView.delegate    = self ;
    self.mainCollectionView.dataSource  = self ;
    self.mainCollectionView.pagingEnabled = YES ;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    layout.itemSize = CGSizeMake(APP_WIDTH, APP_HEIGHT - APP_SAFEAREA_STATUSBAR_FLEX - 49. - 134.) ;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
    layout.minimumLineSpacing = 0 ;
    self.mainCollectionView.collectionViewLayout = layout ;
    
    
//    self.mainCollectionView.head
}

#pragma mark - props

- (void)setUiStatus_TopBar_turnSmall:(BOOL)uiStatus_TopBar_turnSmall {
    _uiStatus_TopBar_turnSmall = uiStatus_TopBar_turnSmall ;
    
    // todo
//    在这里变化UI
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.bookCollectionView) {
        return 5 ;
    }
    else if (collectionView == self.mainCollectionView) {
        return 4 ;
    }
    return 0 ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.bookCollectionView) {
        OcBookCell *cell = [OcBookCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
        return cell ;
    }
    else if (collectionView == self.mainCollectionView) {
        OcContainerCell *cell = [OcContainerCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
        cell.UIDelegate = (id<OcContainerCellDelegate>)self ;
        return cell ;
    }
    return nil ;
}

#pragma mark - OcContainerCellDelegate <NSObject>
// up - YES, down - NO.
- (void)containerCellDraggingDirection:(BOOL)directionUp {
    if (directionUp != self.uiStatus_TopBar_turnSmall) {
        self.uiStatus_TopBar_turnSmall = directionUp ;
    }
    else {
        return ;
    }
    
    if (!directionUp) {NSLog(@"下")}
    else {NSLog(@"上")} ;
}

@end
