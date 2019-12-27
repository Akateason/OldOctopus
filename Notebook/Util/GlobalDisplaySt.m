//
//  GlobalDisplaySt.m
//  Notebook
//
//  Created by teason23 on 2019/6/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "GlobalDisplaySt.h"



@implementation GlobalDisplaySt
XT_SINGLETON_M(GlobalDisplaySt)


- (void)correctCurrentCondition:(UIViewController *)ctrller {
//    DLogINFO(@"traitCollection : %@",ctrller.traitCollection) ;
    
#ifdef ISMAC
    [GlobalDisplaySt sharedInstance].vType = SC_Home_mode_iPad_Horizon_6_collumn ;
    return ;
#endif
    
    
    if (IS_IPAD) {
        if (ctrller.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact &&
            ctrller.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular ) {
                [GlobalDisplaySt sharedInstance].vType = SC_Home_mode_default_iPhone_2_collumn ;
        }
        else if (ctrller.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
                 ctrller.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
            
            if (CGSizeEqualToSize(self.containerSize, APPFRAME.size) ) {
                if (self.containerSize.width > self.containerSize.height) {
                    [GlobalDisplaySt sharedInstance].vType = SC_Home_mode_iPad_Horizon_6_collumn ;
                }
                else {
                    [GlobalDisplaySt sharedInstance].vType = SC_Home_mode_iPad_Verical_4_collumn ;
                }
            }
            else {
                if (self.containerSize.width > self.containerSize.height) {
                 }
                else {
                    [GlobalDisplaySt sharedInstance].vType = SC_Home_mode_default_iPhone_2_collumn ;
                }
            }
        }
        else {
            [GlobalDisplaySt sharedInstance].vType = SC_Home_mode_default_iPhone_2_collumn ;
        }
    }
    else {
        [GlobalDisplaySt sharedInstance].vType = SC_Home_mode_default_iPhone_2_collumn ;
    }
}


- (BOOL)isPopOverFromIpad {
#ifdef ISMAC
    return YES ;
#endif
    
    return IS_IPAD ;
}


- (UICollectionViewFlowLayout *)homeContentLayout {
    SettingSave *ssave = [SettingSave fetch] ;
    if (ssave.homePageCellDisplayWay_isLine) {
        NSLog(@"------------ is line") ;
        return [self lineLayout] ;
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    if ([GlobalDisplaySt sharedInstance].vType == SC_Home_mode_iPad_Horizon_6_collumn) {
        float wid = ( self.containerSize.width - 20. * 2 - 5 * 24. ) / 6. ;
        float height = wid  / 345. * 432. ;
        layout.itemSize = CGSizeMake(wid, height) ;
        layout.minimumInteritemSpacing = 24. ;
        layout.minimumLineSpacing = 24. ;
        layout.sectionInset = UIEdgeInsetsMake(24., 20., 24., 20.) ;
    }
    else if ([GlobalDisplaySt sharedInstance].vType == SC_Home_mode_iPad_Verical_4_collumn) {
        float wid = ( self.containerSize.width - 20. * 2 - 3 * 35. ) / 4. ;
        float height = wid  / 345. * 432. ;
        layout.itemSize = CGSizeMake(wid, height) ;
        layout.minimumInteritemSpacing = 35. ;
        layout.minimumLineSpacing = 35. ;
        layout.sectionInset = UIEdgeInsetsMake(35., 20., 35., 20.) ;
    }
    else if ([GlobalDisplaySt sharedInstance].vType == SC_Home_mode_iPad_Spilit_4_collumn) {
        float wid = ( self.containerSize.width - 10. * 5. ) / 4. ;
        float height = wid  / 345. * 432. ;
        layout.itemSize = CGSizeMake(wid, height) ;
        layout.minimumInteritemSpacing = 10. ;
        layout.minimumLineSpacing = 10. ;
        layout.sectionInset = UIEdgeInsetsMake(10., 10., 10., 10.) ;
    }
    
    else {
        float wid = ( self.containerSize.width - 10. * 3. ) / 2. ;
        float height = wid  / 345. * 432. ;
        layout.itemSize = CGSizeMake(wid, height) ;
        layout.minimumInteritemSpacing = 10. ;
        layout.minimumLineSpacing = 10. ;
        layout.sectionInset = UIEdgeInsetsMake(10., 10., 10., 10.) ;
    }
    
    return layout ;
}

- (UICollectionViewFlowLayout *)lineLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    layout.itemSize = CGSizeMake(self.containerSize.width, 132.) ;
    layout.minimumInteritemSpacing = 10. ;
    layout.minimumLineSpacing = 10. ;
    layout.sectionInset = UIEdgeInsetsMake(10., 0., 10., 0.) ;
    return layout ;
}

@end
