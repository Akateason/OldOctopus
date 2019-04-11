//
//  NoteBooks.m
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "NoteBooks.h"
#import "Note.h"

@implementation NoteBooks

+ (NoteBooks *)recordToNoteBooks:(CKRecord *)record {
    NoteBooks *book = [NoteBooks new] ;
    book.icRecordName = record.recordID.recordName ;
    book.emoji = record[@"emoji"] ;
    book.isDeleted = [record[@"isDeleted"] intValue] ;
    book.name = record[@"name"] ;
    return book ;
}

- (instancetype)initWithName:(NSString *)name
                       emoji:(NSString *)emoji {
    
    self = [super init];
    if (self) {
        _icRecordName = [XTCloudHandler sharedInstance].createUniqueIdentifier ;
        _emoji = [@{@"native":emoji} yy_modelToJSONString] ;
        _isDeleted = 0 ;
        _name = name ;
        
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:_icRecordName zoneID:[XTCloudHandler sharedInstance].zoneID] ;
        _record = [[CKRecord alloc] initWithRecordType:@"NoteBook" recordID:recordID] ;
        [_record setObject:@0 forKey:@"isDeleted"] ;
        [_record setObject:_emoji forKey:@"emoji"] ;
        [_record setObject:_name forKey:@"name"] ;
    }
    return self;
}

+ (void)fetchAllNoteBook:(void(^)(NSArray<NoteBooks *> *array))completion {
    
    NSArray *tmplist = [[NoteBooks xt_findWhere:@"isDeleted == 0"] xt_orderby:@"xt_createTime" descOrAsc:0] ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(tmplist) ;
    }) ;
}

+ (NoteBooks *)createOtherBookWithType:(Notebook_Type)type {
    NoteBooks *book1 = [NoteBooks new] ;
    book1.vType = type ;
    book1.canUpload = NO ;
    if (type == Notebook_Type_recent) {
        book1.emoji = @"ld_bt_recent" ;
        book1.name = @"最近使用" ;
    }
    else if (type == Notebook_Type_trash) {
        book1.emoji = @"ld_bt_trash" ;
        book1.name = @"垃圾桶" ;
    }
    return book1 ;
}

+ (void)createNewBook:(NoteBooks *)book {
    book.isSendOnICloud = NO ;
    [book xt_insert] ;
    
    [[XTCloudHandler sharedInstance] insert:book.record completionHandler:^(CKRecord *record, NSError *error) {
        if (!error) {
            // succcess
            book.isSendOnICloud = YES ;
            [book xt_update] ;
        }
        else {
            // false
            
        }
    }] ;
}

+ (void)updateMyBook:(NoteBooks *)book {
    book.isSendOnICloud = NO ;
    [book xt_upsertWhereByProp:@"icRecordName"] ;
    
    NSDictionary *dic = @{@"emoji" : book.emoji,
                          @"isDeleted" : @(book.isDeleted),
                          @"name" : book.name
                          } ;
    [[XTCloudHandler sharedInstance] updateWithRecId:book.icRecordName updateDic:dic completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        
        if (!error) {
            // succcess
            book.isSendOnICloud = YES ;
            [book xt_update] ;
        }
        else {
            // false
        }
    }] ;        
}

+ (void)getFromServerComplete:(void(^)(bool hasData))completion {
    
    [[XTCloudHandler sharedInstance] fetchListWithTypeName:@"NoteBook" completionHandler:^(NSArray<CKRecord *> *results, NSError *error) {
        
        if (!results.count) {
            completion(NO) ;
            return ;
        }
        
        NSMutableArray *tmplist = [@[] mutableCopy] ;
        [results enumerateObjectsUsingBlock:^(CKRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NoteBooks *aBook = [NoteBooks recordToNoteBooks:obj] ;
            aBook.xt_createTime = [obj.creationDate xt_getTick] ;
            aBook.xt_updateTime = [obj.modificationDate xt_getTick] ;
            aBook.isSendOnICloud = YES ;
            [tmplist addObject:aBook] ;
        }] ;
        
        [NoteBooks xt_insertOrReplaceWithList:tmplist] ;
        completion(YES) ;
    }] ;
}

+ (void)deleteBook:(NoteBooks *)book {
    book.isDeleted = YES ;
    [self updateMyBook:book] ;
    
    NSArray *notelist = [Note xt_findWhere:XT_STR_FORMAT(@"noteBookId == '%@'",book.icRecordName)] ;
    [notelist enumerateObjectsUsingBlock:^(Note *aNote, NSUInteger idx, BOOL * _Nonnull stop) {
        aNote.isDeleted = YES ;
        [Note updateMyNote:aNote] ;
    }] ;
}

- (NSString *)displayEmoji {
    NBEmoji *emo = [NBEmoji yy_modelWithJSON:self.emoji] ;
    return emo.native ;
}




#pragma mark - db

// set sqlite Constraints of property
// props Sqlite Keywords
+ (NSDictionary *)modelPropertiesSqliteKeywords {
    return @{@"icRecordName":@"UNIQUE"} ;
}

// ignore Properties . these properties will not join db CURD .
+ (NSArray *)ignoreProperties {
    return @[@"record",@"vType"] ;
}

@end










@implementation NBEmoji

@end
