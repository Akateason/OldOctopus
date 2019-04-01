//
//  NoteBooks.m
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "NoteBooks.h"


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
        _emoji = emoji ;
        _isDeleted = 0 ;
        _name = name ;
        
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:_icRecordName zoneID:[XTCloudHandler sharedInstance].zoneID] ;
        _record = [[CKRecord alloc] initWithRecordType:@"NoteBook" recordID:recordID] ;
        [_record setObject:@0 forKey:@"isDeleted"] ;
        [_record setObject:emoji forKey:@"emoji"] ;
        [_record setObject:name forKey:@"name"] ;
    }
    return self;
}

+ (void)fetchAllNoteBook:(void(^)(NSArray<NoteBooks *> *array))completion {
    
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isDeleted == 0"] ;
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate" ascending:NO] ;
    NSArray *sortDescriptors = @[firstDescriptor] ;
    
    [[XTCloudHandler sharedInstance] fetchListWithTypeName:@"NoteBook" predicate:predicate sort:sortDescriptors completionHandler:^(NSArray<CKRecord *> *results, NSError *error) {
        
        [results enumerateObjectsUsingBlock:^(CKRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NoteBooks *book = [NoteBooks recordToNoteBooks:obj] ;
            [tmplist addObject:book] ;
        }] ;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(tmplist) ;
        }) ;
        
    }] ;
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

+ (NSArray *)appendWithArray:(NSArray *)booklist {
    NSMutableArray *list = [booklist mutableCopy] ;
    NoteBooks *book1 = [self createOtherBookWithType:(Notebook_Type_recent)] ;
    NoteBooks *book2 = [self createOtherBookWithType:(Notebook_Type_trash)] ;
    [list addObject:book1] ;
    [list addObject:book2] ;
    return list ;
}

+ (void)createNewBook:(NoteBooks *)book {
    
    [[XTCloudHandler sharedInstance] insert:book.record completionHandler:^(CKRecord *record, NSError *error) {
        
        if (!error) {
            // succcess
        }
        else {
            // false
        }

    }] ;
}

+ (void)updateMyBook:(NoteBooks *)book {
    
    NSDictionary *dic = @{@"emoji" : book.emoji,
                          @"isDeleted" : @(book.isDeleted),
                          @"name" : book.name
                          } ;
    
    [[XTCloudHandler sharedInstance] updateWithRecId:book.icRecordName updateDic:dic completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        
        if (!error) {
            // succcess
        }
        else {
            // false
        }
    }] ;        
}

@end
