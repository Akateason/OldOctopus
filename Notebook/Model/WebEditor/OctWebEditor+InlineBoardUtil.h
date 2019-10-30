//
//  OctWebEditor+InlineBoardUtil.h
//  Notebook
//
//  Created by teason23 on 2019/6/4.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor.h"

NS_ASSUME_NONNULL_BEGIN

@interface OctWebEditor (InlineBoardUtil)
- (void)toolbarDidSelectClearToCleanPara ;
- (void)toolbarDidSelectH1 ;
- (void)toolbarDidSelectH2 ;
- (void)toolbarDidSelectH3 ;
- (void)toolbarDidSelectH4 ;
- (void)toolbarDidSelectH5 ;
- (void)toolbarDidSelectH6 ;

- (void)toolbarDidSelectBold ;
- (void)toolbarDidSelectItalic ;
- (void)toolbarDidSelectDeletion ;
- (void)toolbarDidSelectInlineCode ;
- (void)toolbarDidSelectUnderline ;
@end

NS_ASSUME_NONNULL_END
