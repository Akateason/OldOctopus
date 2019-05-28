//
//  MDCodeBlockEditor.h
//  Notebook
//
//  Created by teason23 on 2019/4/29.
//  Copyright © 2019 teason23. All rights reserved.
//还没开始用 .

#import <UIKit/UIKit.h>
#import "MdBlockModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDCodeBlockEditor : UIView

- (instancetype)initWithFrame:(CGRect)frame
                        model:(MdBlockModel *)model ;
    
@end

NS_ASSUME_NONNULL_END
