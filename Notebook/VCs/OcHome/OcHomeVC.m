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

#import <XTlib/XTStretchSegment.h>

@interface OcHomeVC () <UICollectionViewDelegate,UICollectionViewDataSource>

/**
 topbar的变化State Y - 短， N - 长， default - 长;
 */
@property (nonatomic)           BOOL                uiStatus_TopBar_turnSmall ;

@property (strong, nonatomic)   XTStretchSegment    *segmentBooks ;
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
    
}

#pragma mark - props

- (void)setUiStatus_TopBar_turnSmall:(BOOL)uiStatus_TopBar_turnSmall {
    _uiStatus_TopBar_turnSmall = uiStatus_TopBar_turnSmall ;
    
    float newMidHeight = uiStatus_TopBar_turnSmall ? 51. : 134. ;
    
    [UIView animateWithDuration:.3 animations:^{

        // hidden or show
        self.height_midBar.constant = newMidHeight ;
        self.lbMyNotes.alpha = self.lbAll.alpha = self.img_lbAllRight.alpha = self.bookCollectionView.alpha = uiStatus_TopBar_turnSmall ? 0 : 1 ;
        
        self.segmentBooks.hidden = !uiStatus_TopBar_turnSmall ;
        
        
        // collection flow
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
        layout.itemSize = CGSizeMake(APP_WIDTH, APP_HEIGHT - APP_SAFEAREA_STATUSBAR_FLEX - 49. - newMidHeight) ;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
        layout.minimumLineSpacing = 0 ;
        self.mainCollectionView.collectionViewLayout = layout ;
        
        
        
    } completion:^(BOOL finished) {
        
        
        
    }] ;
    
    
}

- (XTStretchSegment *)segmentBooks{
    if(!_segmentBooks){
        _segmentBooks = ({
            XTStretchSegment *object = [[XTStretchSegment alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, 51) dataList:@[@"1",@"1",@"133"]] ;
            if (!object.superview) {
                [self.midBar addSubview:object] ;
                [object mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.midBar) ;
                }] ;
            }
            object;
        });
    }
    return _segmentBooks;
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
        return cell ;
    }
    return nil ;
}

#pragma mark - OcContainerCell callback
// up - YES, down - NO.
- (void)containerCellDraggingDirection:(BOOL)directionUp {
    if (directionUp != self.uiStatus_TopBar_turnSmall) {
        self.uiStatus_TopBar_turnSmall = directionUp ;
    }
    else return ;
    
//    if (!directionUp) {NSLog(@"下")}
//    else {NSLog(@"上")} ;
}



@end
