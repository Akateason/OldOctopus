//
//  NoteBooks.m
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "NoteBooks.h"
#import "Note.h"
#import "SettingSave.h"

@implementation NoteBooks

- (CKRecord *)record {
    if (!_record) {
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:_icRecordName zoneID:[XTCloudHandler sharedInstance].zoneID] ;
        _record = [[CKRecord alloc] initWithRecordType:@"NoteBook" recordID:recordID] ;
    }
    [_record setObject:@(_isDeleted) forKey:@"isDeleted"] ;
    [_record setObject:_emoji forKey:@"emoji"] ;
    [_record setObject:_name forKey:@"name"] ;
    [_record setObject:@(_isTop) forKey:@"isTop"] ;
    [_record setObject:_comeFrom forKey:@"comeFrom"] ;
    
    return _record ;
}

+ (NoteBooks *)recordToNoteBooks:(CKRecord *)record {
    NoteBooks *book = [NoteBooks new] ;
    book.icRecordName = record.recordID.recordName ;
    book.emoji = record[@"emoji"] ;
    book.isDeleted = [record[@"isDeleted"] intValue] ;
    book.name = record[@"name"] ;
    book.isTop = [record[@"isTop"] intValue] ;
    book.comeFrom = record[@"comeFrom"] ;
    return book ;
}

- (instancetype)initWithName:(NSString *)name
                       emoji:(NSString *)emoji {
    
    self = [super init] ;
    if (self) {
        _icRecordName = [XTCloudHandler sharedInstance].createUniqueIdentifier ;
        _emoji = [@{@"native":emoji} yy_modelToJSONString] ;
        _isDeleted = 0 ;
        _name = name ;
        _createDateOnServer = [[NSDate date] xt_getTick] ;
        _modifyDateOnServer = _createDateOnServer ;
        _isTop = NO ;
        _comeFrom = IS_IPAD ? @"iPad" : @"iPhone" ;
    }
    return self;
}

+ (void)fetchAllNoteBook:(void(^)(NSArray<NoteBooks *> *array))completion {
    SettingSave *sSave = [SettingSave fetch] ;
    NSString *orderBy = sSave.sort_isBookUpdateTime ? @"createDateOnServer" : @"modifyDateOnServer" ;
    NSArray *tmplist = [[NoteBooks xt_findWhere:@"isDeleted == 0"] xt_orderby:orderBy descOrAsc:sSave.sort_isNewestFirst] ;
    
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
    else if (type == Notebook_Type_staging) {
        book1.emoji = @"ld_bt_staging" ;
        book1.name = @"暂存区" ;
    }
    else if (type == Notebook_Type_add) {
        book1.emoji = @"ld_bt_addbook" ;
        book1.name = @"新建笔记本" ;
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
            book.createDateOnServer = [record.creationDate xt_getTick] ;
            book.modifyDateOnServer = [record.modificationDate xt_getTick] ;
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
                          @"name" : book.name,
                          @"isTop" : @(book.isTop)
                          } ;
    
    [[XTCloudHandler sharedInstance] updateWithRecId:book.icRecordName updateDic:dic completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        
        if (!error) {
            // succcess
            book.isSendOnICloud = YES ;
            book.modifyDateOnServer = [record.modificationDate xt_getTick] ;
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
            aBook.createDateOnServer = [obj.creationDate xt_getTick] ;
            aBook.modifyDateOnServer = [obj.modificationDate xt_getTick] ;
            aBook.isSendOnICloud = YES ;
            [tmplist addObject:aBook] ;
        }] ;
        
        [NoteBooks xt_insertOrReplaceWithList:tmplist] ;
        completion(YES) ;
    }] ;
}

+ (void)deleteBook:(NoteBooks *)book done:(void(^)(void))doneblk {
    book.isDeleted = YES ;
    [self updateMyBook:book] ;
    
    if (doneblk) doneblk() ;
    
    NSArray *notelist = [Note xt_findWhere:XT_STR_FORMAT(@"noteBookId == '%@'",book.icRecordName)] ;
    [notelist enumerateObjectsUsingBlock:^(Note *aNote, NSUInteger idx, BOOL * _Nonnull stop) {
        aNote.isDeleted = YES ;
        [Note updateMyNote:aNote] ;
    }] ;
}

+ (void)deleteAllNoteBookComplete:(void(^)(bool success))completion {
    [[XTCloudHandler sharedInstance] fetchListWithTypeName:@"NoteBook" completionHandler:^(NSArray<CKRecord *> *results, NSError *error) {
        NSMutableArray *tmplist = [@[] mutableCopy] ;
        [results enumerateObjectsUsingBlock:^(CKRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tmplist addObject:obj.recordID] ;
        }] ;
        
        [[XTCloudHandler sharedInstance] saveList:nil deleteList:tmplist complete:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
            
            completion(!error) ;
        }] ;
    }] ;
}


- (NSString *)displayEmoji {
    NBEmoji *emo = [NBEmoji yy_modelWithJSON:self.emoji] ;
    return emo.native ;
}

- (NSString *)displayBookName {
    return [self.displayEmoji stringByAppendingString:self.name] ;
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
