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
        _noteBookId = bookID ;
        _content = content ;
        _title = title ;
    }
    return self;
}

+ (void)noteListWithNoteBook:(NoteBooks *)book
                  completion:(void(^)(NSArray *list))completion {
    
    if (!book) return ;

    NSMutableArray *tmplist = [@[] mutableCopy] ;
    

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"noteBookId == %@",book.icRecordName];
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


@end
