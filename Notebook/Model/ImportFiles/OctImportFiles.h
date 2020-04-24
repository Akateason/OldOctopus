//
//  OctImportFiles.h
//  Notebook
//
//  Created by teason23 on 2020/4/24.
//  Copyright © 2020 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OctImportFiles : NSObject

+ (void)getMDContentOnImportedFiles:(NSURL *)url
                         completion:(void(^)(NSString *contentStr))completion;

@end

NS_ASSUME_NONNULL_END
