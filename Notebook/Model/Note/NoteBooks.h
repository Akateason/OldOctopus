//
//  NoteBooks.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XTFMDB/XTFMDB.h>

typedef enum : NSUInteger {
    Notebook_Type_notebook ,
    Notebook_Type_recent,
    Notebook_Type_trash,
    Notebook_Type_staging,
    Notebook_Type_add,
} Notebook_Type;

NS_ASSUME_NONNULL_BEGIN

@interface NoteBooks : NSObject
@property (nonatomic)       BOOL     isSendOnICloud ;
@property (nonatomic)       Notebook_Type vType ;
@property (nonatomic)       BOOL     canUpload ;
@property (nonatomic)       BOOL     isOnSelect ;
@property (copy, nonatomic) NSString *icRecordName ;
@property (strong, nonatomic) CKRecord *record ;
@property (nonatomic)       long long modifyDateOnServer ;
@property (nonatomic)       long long createDateOnServer ;


// icloud
@property (copy, nonatomic) NSString *emoji ;
@property (nonatomic)       int      isDeleted ;
@property (copy, nonatomic) NSString *name ;
@property (nonatomic)       int      isTop ; // 置顶
@property (copy, nonatomic) NSString *comeFrom ; // 发自


- (NSString *)displayEmoji ;
- (NSString *)displayBookName ;

+ (void)fetchAllNoteBook:(void(^)(NSArray<NoteBooks *> *array))completion ;

+ (NoteBooks *)recordToNoteBooks:(CKRecord *)record ;
+ (NoteBooks *)getBookWithBookID:(NSString *)bookID ;

- (instancetype)initWithName:(NSString *)name
                       emoji:(NSString *)emoji ;

+ (NoteBooks *)createOtherBookWithType:(Notebook_Type)type ;


+ (void)createNewBook:(NoteBooks *)book ;
    
+ (void)updateMyBook:(NoteBooks *)book ;

+ (void)getFromServerComplete:(void(^)(bool hasData))completion ;

+ (void)deleteBook:(NoteBooks *)book
              done:(void(^)(void))doneblk ;

+ (void)deleteAllNoteBookComplete:(void(^)(bool success))completion ;

@end


@interface NBEmoji : NSObject
@property (copy, nonatomic) NSString *native ;
@end

NS_ASSUME_NONNULL_END
