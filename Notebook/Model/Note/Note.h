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
@property (nonatomic)       BOOL     isSendOnICloud ;
@property (strong, nonatomic) CKRecord *record ;
@property (copy, nonatomic) NSString *icRecordName ;
@property (nonatomic)       long long modifyDateOnServer ;
@property (nonatomic)       long long createDateOnServer ;


// icloud
@property (copy, nonatomic) NSString *content ; // ignore local
@property (copy, nonatomic) NSString *baseContent ; // only save in local
@property (copy, nonatomic) NSString *searchContent ; // only save in local
@property (nonatomic)       int      isDeleted ;
@property (copy, nonatomic) NSString *noteBookId ;
@property (copy, nonatomic) NSString *title ;




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

+ (void)deleteAllNoteComplete:(void(^)(bool success))completion ;

+ (void)getFromServerComplete:(void(^)(void))completion ;



+ (NSString *)filterMarkdownString:(NSString *)markdownStr ;
+ (NSString *)filterSqliteString:(NSString *)markdownStr ;

@end


