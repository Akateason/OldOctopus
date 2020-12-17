//
//  OcContainerCell.h
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
// 笔记本容器cell

#import <UIKit/UIKit.h>

@interface OcContainerCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *contentCollection ;
@property (copy, nonatomic) NSArray *noteList ;
- (void)refresh ;
@end


