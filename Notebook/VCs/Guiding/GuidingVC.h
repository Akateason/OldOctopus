//
//  GuidingVC.h
//  Notebook
//
//  Created by teason23 on 2019/4/23.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
static NSString *const kKey_markForGuidingDisplay = @"kKey_markForGuidingDisplay" ;

NS_ASSUME_NONNULL_BEGIN

@interface GuidingVC : BasicVC

+ (GuidingVC *)show ;
    
@end

NS_ASSUME_NONNULL_END
