//
//  ArticlePhotoPreviewVC.h
//  Notebook
//
//  Created by teason23 on 2019/5/7.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
#import "WebModel.h"
@class MdInlineModel ;

NS_ASSUME_NONNULL_BEGIN

@interface ArticlePhotoPreviewVC : UIView

+ (instancetype)showFromView:(UIView *)fromView
                        json:(NSString *)json
               deleteOnClick:(void(^)(ArticlePhotoPreviewVC *vc))deleteOnClick ;




@property (nonatomic, strong) MdInlineModel *modelImage ;

+ (instancetype)showFromCtrller:(UIViewController *)fromCtrller
                          model:(MdInlineModel *)model
                  deleteOnClick:(void(^)(ArticlePhotoPreviewVC *vc))deleteOnClick ;

@end

NS_ASSUME_NONNULL_END
