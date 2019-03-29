//
//  NoteBooks.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XTlib/XTlib.h>
#import "XTCloudHandler.h"

typedef enum : NSUInteger {
    Notebook_Type_notebook ,
    Notebook_Type_recent,
    Notebook_Type_trash
} Notebook_Type;

NS_ASSUME_NONNULL_BEGIN

@interface NoteBooks : NSObject
@property (nonatomic)       Notebook_Type vType ;
@property (nonatomic)       BOOL     canUpload ;
@property (nonatomic)       BOOL     isOnSelect ;
@property (copy, nonatomic) NSString *icRecordName ;

@property (copy, nonatomic) NSString *emoji ;
@property (nonatomic)       int      isDeleted ;
@property (copy, nonatomic) NSString *name ;

+ (void)fetchAllNoteBook:(void(^)(NSArray<NoteBooks *> *array))completion ;

+ (NoteBooks *)recordToNoteBooks:(CKRecord *)record ;

- (instancetype)initWithName:(NSString *)name
                       emoji:(NSString *)emoji ;

+ (NoteBooks *)createOtherBookWithType:(Notebook_Type)type ;

+ (NSArray *)appendWithArray:(NSArray *)booklist ;

@end

NS_ASSUME_NONNULL_END
