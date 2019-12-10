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

// animation
@property (nonatomic) int animate_duration ; //-1,0,1  慢,正常,快
@property (nonatomic) BOOL animate_isSpring ;


// theme
@property (nonatomic) BOOL theme_isChangeWithSystemDarkmode ; // 是否跟随系统darkmode主题切换

// editor
@property (nonatomic)       BOOL        editor_autoAddBracket ;
@property (nonatomic)       float       editor_lightHeightRate ;
@property (nonatomic, copy) NSString    *editor_md_ulistSymbol ;
@property (nonatomic)       BOOL        editor_isLooseList ;

- (void)save ;
+ (instancetype)fetch ;


- (CGFloat)currentAnimationDuration ;


@end


