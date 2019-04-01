//
//  Note.m
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "Note.h"
#import "NoteBooks.h"

@implementation Note

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
        _noteBookId = bookID ;
        _content = content ;
        _title = title ;
        
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:_icRecordName zoneID:[XTCloudHandler sharedInstance].zoneID] ;
        _record = [[CKRecord alloc] initWithRecordType:@"Note" recordID:recordID] ;
        [_record setObject:_noteBookId forKey:@"noteBookId"] ;
        [_record setObject:_content forKey:@"content"] ;
        [_record setObject:_title forKey:@"title"] ;
        [_record setObject:@0 forKey:@"isDeleted"] ;
    }
    return self;
}

+ (void)noteListWithNoteBook:(NoteBooks *)book
                  completion:(void(^)(NSArray *list))completion {
    
    if (!book || book.vType != Notebook_Type_notebook) return ;

    NSMutableArray *tmplist = [@[] mutableCopy] ;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"noteBookId == %@ && isDeleted == 0",book.icRecordName];
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate" ascending:NO] ;
    NSArray *sortDescriptors = @[firstDescriptor];
    
    [[XTCloudHandler sharedInstance] fetchListWithTypeName:@"Note" predicate:predicate sort:sortDescriptors completionHandler:^(NSArray<CKRecord *> * _Nonnull results, NSError * _Nonnull error) {
        
        [results enumerateObjectsUsingBlock:^(CKRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Note *note = [Note recordToNote:obj] ;
            [tmplist addObject:note] ;
        }] ;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(tmplist) ;
        }) ;
    }] ;
}

+ (void)createNewNote:(Note *)aNote {
    
    [[XTCloudHandler sharedInstance] insert:aNote.record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        
        if (!error) {
            // succcess
        }
        else {
            // false
        }
        
    }] ;
}

+ (void)updateMyNote:(Note *)aNote {
//    @property (copy, nonatomic) NSString *content ;
//    @property (nonatomic)       int      isDeleted ;
//    @property (copy, nonatomic) NSString *noteBookId ;
//    @property (copy, nonatomic) NSString *title ;
    
    NSDictionary *dic = @{@"content" : aNote.content,
                          @"isDeleted" : @(aNote.isDeleted),
                          @"noteBookId" : aNote.noteBookId,
                          @"title" : aNote.title
                          } ;
    
    [[XTCloudHandler sharedInstance] updateWithRecId:aNote.icRecordName updateDic:dic completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        
        if (!error) {
            // succcess
        }
        else {
            // false
        }
    }] ;
}

@end
