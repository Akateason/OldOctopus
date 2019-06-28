//
//  SettingSave.h
//  Notebook
//
//  Created by teason23 on 2019/6/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SettingSave : NSObject

// sort
@property (nonatomic) BOOL sort_isNewestFirst    ; //最新优先
@property (nonatomic) BOOL sort_isBookUpdateTime ; // 0 updateTime 1 createTime 笔记本
@property (nonatomic) BOOL sort_isNoteUpdateTime ; // 0 updateTime 1 createTime 笔记




- (void)save ;
+ (instancetype)fetch ;

@end


