//
//  Note.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XTFMDB/XTFMDB.h>

@class NoteBooks,CKRecord ;



@interface Note : NSObject
@property (nonatomic)         BOOL        isSendOnICloud ;
@property (strong, nonatomic) CKRecord    *record ;
@property (copy, nonatomic)   NSString    *icRecordName ;
@property (nonatomic)         long long   modifyDateOnServer ;
@property (nonatomic)         long long   createDateOnServer ;


// icloud
@property (copy, nonatomic) NSString *content ; // ignore local
@property (copy, nonatomic) NSString *baseContent ; // only save in local
@property (copy, nonatomic) NSString *searchContent ; // only save in local
@property (nonatomic)       int      isDeleted ;
@property (copy, nonatomic) NSString *noteBookId ;
@property (copy, nonatomic) NSString *title ;
@property (nonatomic)       int      isTop ; // 置顶
@property (copy, nonatomic) NSString *comeFrom ; // 发自
@property (copy, nonatomic) NSString *previewPicture ; // 预览图数组 jsonstr [ imgUrl , ... ]


+ (instancetype)recordToNote:(CKRecord *)record ;

- (instancetype)initWithBookID:(NSString *)bookID
                       content:(NSString *)content
                         title:(NSString *)title ;

+ (void)noteListWithNoteBook:(NoteBooks *)book
                  completion:(void(^)(NSArray *list))completion ;

+ (void)createNewNote:(Note *)aNote ;

+ (void)updateMyNote:(Note *)aNote ;

+ (void)deleteThisNoteFromICloud:(Note *)aNote
                        complete:(void(^)(bool success))completion ;

+ (void)deleteTheseNotes:(NSArray *)notes
      fromICloudComplete:(void(^)(bool success))completion ;

+ (void)deleteAllNoteComplete:(void(^)(bool success))completion ;

+ (void)getFromServerComplete:(void(^)(void))completion ;



+ (NSString *)filterSqliteString:(NSString *)markdownStr ;
+ (NSString *)contentReplaceAllImages:(NSString *)content ;
+ (NSString *)getTitleWithContent:(NSString *)content ;

+ (NSString *)filterMD:(NSString *)originString ;

+ (NSString *)filterTitle:(NSString *)title ;

// 获取预览图
+ (NSString *)getMDImageWithContent:(NSString *)content ;

// 启动时, 检查所有笔记并加入预览图
+ (void)addPreviewPictureInLaunchingTime ;


- (NSString *)displayDesciptionString ;

@end


