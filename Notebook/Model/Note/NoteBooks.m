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
                       emoji:(NSString *)emoji
{
    self = [super init];
    if (self) {
        _icRecordName = [XTCloudHandler sharedInstance].createUniqueIdentifier ;
        _emoji = emoji ;
        _isDeleted = 0 ;
        _name = name ;
    }
    return self;
}

+ (void)fetchAllNoteBook:(void(^)(NSArray<NoteBooks *> *array))completion {
    
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    [[XTCloudHandler sharedInstance] fetchListWithTypeName:@"NoteBook" completionHandler:^(NSArray<CKRecord *> * _Nonnull results, NSError * _Nonnull error) {
        
        [results enumerateObjectsUsingBlock:^(CKRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NoteBooks *book = [NoteBooks recordToNoteBooks:obj] ;
            [tmplist addObject:book] ;
        }] ;
        
        completion(tmplist) ;
    }] ;
}

@end
