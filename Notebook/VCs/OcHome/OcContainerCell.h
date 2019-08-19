//
//  OcContainerCell.h
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OcContainerCellDelegate <NSObject>
- (void)containerCellDraggingDirection:(BOOL)directionUp ; // up - YES, down - NO.
@end

@interface OcContainerCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *contentCollection;
@property (weak, nonatomic) id <OcContainerCellDelegate> UIDelegate ;
@end

NS_ASSUME_NONNULL_END
