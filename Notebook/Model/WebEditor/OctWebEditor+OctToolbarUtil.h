//
//  OctWebEditor+OctToolbarUtil.h
//  Notebook
//
//  Created by teason23 on 2019/6/4.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor.h"
@class WebPhoto, XTImageItem ;

NS_ASSUME_NONNULL_BEGIN

@interface OctWebEditor (OctToolbarUtil)

- (void)uploadWebPhoto:(WebPhoto *)photo image:(UIImage *)image ;
- (void)hideKeyboard ;
- (void)openKeyboard ;
- (void)sendImageLocalPathWithImageItem:(XTImageItem *)imageItem ;

- (void)subscription ;


- (void)toolbarDidSelectUndo ;
- (void)toolbarDidSelectRedo ;

@end

NS_ASSUME_NONNULL_END
