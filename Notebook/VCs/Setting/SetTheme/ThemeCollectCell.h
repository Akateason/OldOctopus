//
//  ThemeCollectCell.h
//  Notebook
//
//  Created by teason23 on 2019/6/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThemeCollectCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imgLock;

- (void)setThemeStr:(NSString *)str ;
- (void)setOnSelect:(BOOL)on ;
@end

NS_ASSUME_NONNULL_END
