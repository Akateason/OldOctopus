//
//  Note.m
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "Note.h"
#import "NoteBooks.h"
#import "XTMarkdownParser.h"

@implementation Note
@synthesize content = _content ;

- (void)setContent:(NSString *)content {
    _content = content ;
    
    self.baseContent = [content base64EncodedString] ;
    self.searchContent = [self.class filterSqliteString:content] ;
}

- (NSString *)content {
    return [self.baseContent base64DecodedString] ?: @"" ;
}

- (CKRecord *)record {
    if (!_record) {
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:_icRecordName zoneID:[XTCloudHandler sharedInstance].zoneID] ;
        _record = [[CKRecord alloc] initWithRecordType:@"Note" recordID:recordID] ;
    }
    
    [_record setObject:_noteBookId forKey:@"noteBookId"] ;
    [_record setObject:self.content forKey:@"content"] ;
    [_record setObject:_title forKey:@"title"] ;
    [_record setObject:@(_isDeleted) forKey:@"isDeleted"] ;

    return _record ;
}


+ (instancetype)recordToNote:(CKRecord *)record {
    Note *note = [Note new] ;
    note.record = record ;
    note.icRecordName = record.recordID.recordName ;
    note.content = record[@"content"] ;
    note.isDeleted = [record[@"isDeleted"] intValue] ;
    note.noteBookId = record[@"noteBookId"] ;
    note.title = record[@"title"] ;
    return note ;
}

- (instancetype)initWithBookID:(NSString *)bookID
                       content:(NSString *)content
                         title:(NSString *)title {
    
    self = [super init];
    if (self) {
        _icRecordName = [XTCloudHandler sharedInstance].createUniqueIdentifier ;
        _noteBookId = bookID ?: @"" ;
        _content = content ;
        _title = title ;
        _baseContent = [content base64EncodedString] ;
        _createDateOnServer = [[NSDate date] xt_getTick] ;
        _modifyDateOnServer = _createDateOnServer ;
    }
    return self;
}

+ (void)noteListWithNoteBook:(NoteBooks *)book
                  completion:(void(^)(NSArray *list))completion {
    
    if (!book || book.vType != Notebook_Type_notebook) {
        completion(nil) ;
        return ;
    }

    NSArray *tmplist = [[Note xt_findWhere:XT_STR_FORMAT(@"noteBookId == '%@' and isDeleted == 0",book.icRecordName)] xt_orderby:@"modifyDateOnServer" descOrAsc:1] ;
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(tmplist) ;
    }) ;
}

+ (void)createNewNote:(Note *)aNote {
    aNote.isSendOnICloud = NO ;
    [aNote xt_insert] ;
    
    [[XTCloudHandler sharedInstance] insert:aNote.record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error) {
            // succcess
            aNote.isSendOnICloud = YES ;
            aNote.createDateOnServer = [record.creationDate xt_getTick] ;
            aNote.modifyDateOnServer = [record.modificationDate xt_getTick] ;
            [aNote xt_update] ;
        }
        else {
            // false
            
        }
    }] ;
}

+ (void)updateMyNote:(Note *)aNote {
    aNote.isSendOnICloud = NO ;
    [aNote xt_upsertWhereByProp:@"icRecordName"] ;
    
    NSDictionary *dic = @{@"content" : aNote.content,
                          @"isDeleted" : @(aNote.isDeleted),
                          @"noteBookId" : aNote.noteBookId,
                          @"title" : aNote.title
                          } ;
    
    [[XTCloudHandler sharedInstance] updateWithRecId:aNote.icRecordName updateDic:dic completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error) {
            // succcess
            aNote.isSendOnICloud = YES ;
            aNote.modifyDateOnServer = [record.modificationDate xt_getTick] ;
            [aNote xt_update] ;
        }
        else {
            // false
        }
    
    }] ;
}

+ (void)deleteThisNoteFromICloud:(Note *)aNote
                        complete:(void(^)(bool success))completion {
    
    __block Note *delNote = aNote ;
    
    [XTCloudHandler.sharedInstance fetchWithId:aNote.icRecordName completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if(!error) {
            
            [XTCloudHandler.sharedInstance saveList:nil deleteList:@[record.recordID] complete:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
                
                if (!error) {
                    [delNote xt_deleteModel] ;
                    completion(YES) ;
                }
                else {
                    completion(NO) ;
                }
            }] ;
        }
        else {
            completion(NO) ; // query failed
        }
    }] ;
}


+ (void)deleteAllNoteComplete:(void(^)(bool success))completion {
    [[XTCloudHandler sharedInstance] fetchListWithTypeName:@"Note" completionHandler:^(NSArray<CKRecord *> *results, NSError *error) {
        NSMutableArray *tmplist = [@[] mutableCopy] ;
        [results enumerateObjectsUsingBlock:^(CKRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tmplist addObject:obj.recordID] ;
        }] ;
        
        [[XTCloudHandler sharedInstance] saveList:nil deleteList:tmplist complete:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
            
            completion(!error) ;
        }] ;
    }] ;
}

+ (void)getFromServerComplete:(void(^)(void))completion {
    
    [[XTCloudHandler sharedInstance] fetchListWithTypeName:@"Note" completionHandler:^(NSArray<CKRecord *> *results, NSError *error) {
        NSMutableArray *tmplist = [@[] mutableCopy] ;
        [results enumerateObjectsUsingBlock:^(CKRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Note *aNote = [Note recordToNote:obj] ;
            aNote.createDateOnServer = [obj.creationDate xt_getTick] ;
            aNote.modifyDateOnServer = [obj.modificationDate xt_getTick] ;
            aNote.isSendOnICloud = YES ;
            [tmplist addObject:aNote] ;
        }] ;
        
        [Note xt_insertOrReplaceWithList:tmplist] ;
        completion() ;
    }] ;
}


+ (NSString *)filterMarkdownString:(NSString *)markdownStr {
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"\n" withString:@" "] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"#" withString:@""] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"*" withString:@""] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"_" withString:@""] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"~" withString:@""] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"`" withString:@""] ;
    return markdownStr ;
}

+ (NSString *)filterSqliteString:(NSString *)markdownStr {
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"\"" withString:@""] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"'" withString:@""] ;
    return markdownStr ;
}


#pragma mark - db

// set sqlite Constraints of property
// props Sqlite Keywords
+ (NSDictionary *)modelPropertiesSqliteKeywords {
    return @{@"icRecordName":@"UNIQUE"} ;
}

// ignore Properties . these properties will not join db CURD .
+ (NSArray *)ignoreProperties {
    return @[@"record",@"content"] ;
}
// Container property , value should be Class or Class name. Same as YYmodel .
//+ (NSDictionary *)modelContainerPropertyGenericClass;


@end
