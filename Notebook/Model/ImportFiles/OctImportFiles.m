//
//  OctImportFiles.m
//  Notebook
//
//  Created by teason23 on 2020/4/24.
//  Copyright © 2020 teason23. All rights reserved.
//

#import "OctImportFiles.h"

@implementation OctImportFiles

+ (void)getMDContentOnImportedFiles:(NSURL *)url
                         completion:(void(^)(NSString *contentStr))completion {
    
    NSString *path = url.path ;
    NSError *error;
    NSString *md = [[NSString alloc] initWithContentsOfFile:path encoding:(NSUTF8StringEncoding) error:&error] ;
    if (!error) {
        completion(md);
    } else {
        BOOL accessing = [url startAccessingSecurityScopedResource];
        if (accessing) {
            error = nil;
            NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            [fileCoordinator coordinateReadingItemAtURL:url
                                                options:NSFileCoordinatorReadingWithoutChanges
                                                  error:&error
                                             byAccessor:^(NSURL * _Nonnull newURL) {
                 
                NSString *fileName = [newURL lastPathComponent];
                NSString *contStr = [NSString stringWithContentsOfURL:newURL encoding:NSUTF8StringEncoding error:nil];
                NSLog(@"contStr: %@",contStr);
                completion(contStr);
            }];
            
        } else {
            completion(nil);
        }
        [url stopAccessingSecurityScopedResource];
    }
}


@end
