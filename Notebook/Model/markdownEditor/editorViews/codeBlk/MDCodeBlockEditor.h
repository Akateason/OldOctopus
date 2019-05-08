//
//  MDCodeBlockEditor.h
//  Notebook
//
//  Created by teason23 on 2019/4/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MdBlockModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDCodeBlockEditor : UITextView

- (instancetype)initWithFrame:(CGRect)frame
                        model:(MdBlockModel *)model ;
    
@end

NS_ASSUME_NONNULL_END
