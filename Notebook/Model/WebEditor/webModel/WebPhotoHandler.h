//
//  WebPhotoHandler.h
//  Notebook
//
//  Created by teason23 on 2019/6/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XTlib/XTlib.h>
#import <XTFMDB/XTFMDB.h>


@interface WebPhotoHandler : NSObject

@end


// 传过去之后， 删除一条记录。
@interface WebPhoto : NSObject
@property (nonatomic, copy) NSString    *localPath ; // pk
@property (nonatomic)       int         fromNoteClientID ; //note id
@property (nonatomic)       BOOL        isUploaded ;
@property (nonatomic, copy) NSString    *url ;

@end
