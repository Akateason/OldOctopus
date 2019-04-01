//
//  Note.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NoteBooks,CKRecord ;



@interface Note : NSObject
@property (copy, nonatomic) NSString *icRecordName ;
@property (strong, nonatomic) CKRecord *record ;

// icloud
@property (copy, nonatomic) NSString *content ;
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


@end


