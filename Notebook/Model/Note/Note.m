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
#import "SettingSave.h"

@implementation Note
@synthesize content = _content ;

- (void)setContent:(NSString *)content {
    _content = content ;
    
    self.baseContent = [content base64EncodedString] ;
    self.searchContent = [self.class getSearchContent:content] ;
    self.previewPicture = [self.class getMDImageWithContent:content] ;
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
    [_record setObject:@(_isTop) forKey:@"isTop"] ;
    [_record setObject:_comeFrom forKey:@"comeFrom"] ;
    [_record setObject:_previewPicture forKey:@"previewPicture"] ;
    
    return _record ;
}


+ (instancetype)recordToNote:(CKRecord *)record {
    Note *note = [Note new] ;
    note.record = record ;
    note.icRecordName = record.recordID.recordName ;
    note.content = record[@"content"] ;
    note.isDeleted = [record[@"isDeleted"] intValue] ;
    note.noteBookId = record[@"noteBookId"] ;
    note.title = [self filterTitle:record[@"title"]] ;
    note.isTop = [record[@"isTop"] intValue] ;
    note.comeFrom = record[@"comeFrom"] ;
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
        _searchContent = [self.class getSearchContent:content] ;
        _title = [self.class filterTitle:title] ;
        _baseContent = [content base64EncodedString] ;
        _createDateOnServer = [[NSDate date] xt_getTick] ;
        _modifyDateOnServer = _createDateOnServer ;
        _isTop = NO ;
        _comeFrom = IS_IPAD ? @"iPad" : @"iPhone" ;
        _previewPicture = [self.class getMDImageWithContent:content] ;
    }
    return self;
}

+ (void)noteListWithNoteBook:(NoteBooks *)book
                  completion:(void(^)(NSArray *list))completion {
    
    if (!book || book.vType != Notebook_Type_notebook) {
        completion(nil) ;
        return ;
    }

    SettingSave *sSave = [SettingSave fetch] ;
    NSString *orderBy = sSave.sort_isNoteUpdateTime ? @"createDateOnServer" : @"modifyDateOnServer" ;
    NSArray *tmplist = [[Note xt_findWhere:XT_STR_FORMAT(@"noteBookId == '%@' and isDeleted == 0",book.icRecordName)] xt_orderby:orderBy descOrAsc:sSave.sort_isNewestFirst] ;
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(tmplist) ;
    }) ;
}

+ (void)createNewNote:(Note *)aNote {
    aNote.isSendOnICloud = NO ;
    [aNote xt_insert] ;
    
    [[XTCloudHandler sharedInstance] insert:aNote.record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error && record != nil) {
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
    if (!aNote.previewPicture) aNote.previewPicture = @"" ;
    
    NSDictionary *dic = @{@"content" : aNote.content,
                          @"isDeleted" : @(aNote.isDeleted),
                          @"noteBookId" : aNote.noteBookId,
                          @"title" : [self filterTitle:aNote.title],
                          @"isTop" : @(aNote.isTop),
                          @"previewPicture" : aNote.previewPicture
                          } ;
    
    [[XTCloudHandler sharedInstance] updateWithRecId:aNote.icRecordName updateDic:dic completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error && record != nil) {
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

+ (void)deleteTheseNotes:(NSArray *)notes
      fromICloudComplete:(void(^)(bool success))completion {
    
    NSMutableArray *list = [@[] mutableCopy] ;
    for (Note *aNote in notes) {
        [list addObject:aNote.record.recordID] ;
    }
    
    [[XTCloudHandler sharedInstance] saveList:nil deleteList:list complete:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
        
        completion(!error) ;
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

+ (void)getFromServerComplete:(void(^)(BOOL isPullAll))completion {
    
    [[XTCloudHandler sharedInstance] fetchListWithTypeName:@"Note" completionHandler:^(NSArray<CKRecord *> *results, NSError *error) {
        NSMutableArray *tmplist = [@[] mutableCopy] ;
        [results enumerateObjectsUsingBlock:^(CKRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Note *aNote = [Note recordToNote:obj] ;
            aNote.createDateOnServer = [obj.creationDate xt_getTick] ;
            aNote.modifyDateOnServer = [obj.modificationDate xt_getTick] ;
            aNote.isSendOnICloud = YES ;
            [tmplist addObject:aNote] ;
        }] ;
        
        
        if ([Note xt_count] < tmplist.count) {
            [Note xt_insertOrReplaceWithList:tmplist] ;
            completion(YES) ;
        } else {
            completion(NO);
        }
                
    }] ;
}

+ (NSString *)filterMD:(NSString *)originString {
    NSString *MARKER_REG = @"[\\*\\_$`~]+" ;
    NSString *BULLET_LIST_REG = @"^([*+-]\\s+)" ;
    NSString *TASK_LIST_REG = @"^(\[[x\\s]{1}\\]\\s+)" ;
    NSString *IMAGE_REG = @"(\\!\\[)(.*?)(\\\\*)\\]\\((.*?)(\\\\*)\\)" ;
    NSString *LINK_REG = @"(\\[)((?:\\[[^\\]]*\\]|[^\\[\\]]|\\](?=[^\\[]*\\]))*?)(\\\\*)\\]\\((.*?)(\\\\*)\\)" ;
    NSString *CHECK_BOX = @"^\\[([ x])\\] +" ;
    
    NSArray *list = @[MARKER_REG,BULLET_LIST_REG,TASK_LIST_REG,IMAGE_REG,LINK_REG,CHECK_BOX] ;
    NSMutableString *tmpString = [originString mutableCopy] ;
    for (int i = 0; i < list.count; i++) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:list[i] options:0 error:nil] ;
        [regex replaceMatchesInString:tmpString options:0 range:NSMakeRange(0, [tmpString length]) withTemplate:@""] ;
    }
    tmpString = [tmpString stringByReplacingOccurrencesOfString:@"\n" withString:@" "].mutableCopy ;
    tmpString = [tmpString stringByReplacingOccurrencesOfString:@" " withString:@""].mutableCopy ;
    tmpString = [tmpString stringByReplacingOccurrencesOfString:@"#" withString:@""].mutableCopy ;

    return tmpString ;
}

+ (NSString *)filterTitle:(NSString *)title {
    if (title.length > 50) {
        return [title substringToIndex:49] ;
    }
    title = [self filterSqliteString:title];
    return title ;
}

+ (NSString *)filterSqliteString:(NSString *)markdownStr {
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"\"" withString:@""] ;
    markdownStr = [markdownStr stringByReplacingOccurrencesOfString:@"'" withString:@""] ;
    return markdownStr ;
}

+ (NSString *)getTitleWithContent:(NSString *)content {
    NSArray *listForBreak = [content componentsSeparatedByString:@"\n"] ;
    NSString *title = @"无标题" ;
    for (NSString *str in listForBreak) {
        if (str.length) {
            title = str ;
            break ;
        }
    }
    title = [self filterTitle:title];
    return title ;
}

+ (NSString *)getSearchContent:(NSString *)content {
    content = [self contentReplaceAllImages:content] ;
    content = [self filterSqliteString:content] ;
    return content ;
}

+ (NSString *)contentReplaceAllImages:(NSString *)content {
    if (!content || !content.length) return nil ;
    
    NSString *IMAGE_REG = @"(\\!\\[)(.*?)(\\\\*)\\]\\((.*?)(\\\\*)\\)" ;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:IMAGE_REG options:0 error:nil] ;
    NSArray *matsImage = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)] ;
    for (NSTextCheckingResult *result in matsImage) {
        content = [content stringByReplacingCharactersInRange:result.range withString:[self generateSpaceString:result.range.length]] ;
    }
    
    IMAGE_REG = @"/<img.*?src=\"(.*?)\".*?\\/?>/i" ;
    regex = [NSRegularExpression regularExpressionWithPattern:IMAGE_REG options:0 error:nil] ;
    matsImage = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)] ;
    for (NSTextCheckingResult *result in matsImage) {
        content = [content stringByReplacingCharactersInRange:result.range withString:[self generateSpaceString:result.range.length]] ;
    }
    
    IMAGE_REG = @"/^\\!\\[([^\\]]+?)(\\\\*)\\](?:\\[([^\\]]*?)(\\\\*)\\])?/" ;
    regex = [NSRegularExpression regularExpressionWithPattern:IMAGE_REG options:0 error:nil] ;
    matsImage = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)] ;
    for (NSTextCheckingResult *result in matsImage) {
        content = [content stringByReplacingCharactersInRange:result.range withString:[self generateSpaceString:result.range.length]] ;
    }
    
    IMAGE_REG = @"/^( {0,3}\[)([^\\]]+?)(\\\\*)(\\]: *)(<?)([^\\s>]+)(>?)(?:( +)([\"'(]?)([^\\n\"'\\(\\)]+)\\9)?( *)$/" ;
    regex = [NSRegularExpression regularExpressionWithPattern:IMAGE_REG options:0 error:nil] ;
    matsImage = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)] ;
    for (NSTextCheckingResult *result in matsImage) {
        content = [content stringByReplacingCharactersInRange:result.range withString:[self generateSpaceString:result.range.length]] ;
    }
    
    return content ;
}

+ (NSString *)generateSpaceString:(NSInteger)length {
    NSMutableString *tmpStr = [NSMutableString stringWithCapacity:length] ;
    for (NSInteger i = 0; i < length; i++) {
        [tmpStr appendString:@" "] ;
    }
    return tmpStr ;
}

// 获取 所有图片url数组
+ (NSString *)getMDImageWithContent:(NSString *)content {
    if (!content || !content.length) return nil ;
    
    NSString *IMAGE_REG = @"(\\!\\[)(.*?)(\\\\*)\\]\\((.*?)(\\\\*)\\)" ;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:IMAGE_REG options:0 error:nil] ;
    NSArray *matsImage = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)] ;
    if (!matsImage.count) return @"" ;
    
    NSMutableArray *results = [@[] mutableCopy] ;
    for (NSTextCheckingResult *result in matsImage) {
        NSString *strRes = [content substringWithRange:result.range] ;
        
        NSRange startRange = [strRes rangeOfString:@"("];
        NSRange endRange = [strRes rangeOfString:@")"];
        NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length) ;
        NSString *tmpStr = [strRes substringWithRange:range];
        
        [results addObject:tmpStr] ;
    }
    
    IMAGE_REG = @"/<img.*?src=\"(.*?)\".*?\\/?>/i" ;
    regex = [NSRegularExpression regularExpressionWithPattern:IMAGE_REG options:0 error:nil] ;
    matsImage = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)] ;
    for (NSTextCheckingResult *result in matsImage) {
        NSString *strRes = [content substringWithRange:result.range] ;
        [results addObject:strRes] ;
    }
            
    IMAGE_REG = @"/^\\!\\[([^\\]]+?)(\\\\*)\\](?:\\[([^\\]]*?)(\\\\*)\\])?/" ;
    regex = [NSRegularExpression regularExpressionWithPattern:IMAGE_REG options:0 error:nil] ;
    matsImage = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)] ;
    for (NSTextCheckingResult *result in matsImage) {
        NSString *strRes = [content substringWithRange:result.range] ;
        [results addObject:strRes] ;
    }
    
    IMAGE_REG = @"/^( {0,3}\[)([^\\]]+?)(\\\\*)(\\]: *)(<?)([^\\s>]+)(>?)(?:( +)([\"'(]?)([^\\n\"'\\(\\)]+)\\9)?( *)$/" ;
    regex = [NSRegularExpression regularExpressionWithPattern:IMAGE_REG options:0 error:nil] ;
    matsImage = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)] ;
    for (NSTextCheckingResult *result in matsImage) {
        NSString *strRes = [content substringWithRange:result.range] ;
        [results addObject:strRes] ;
    }
    
    if (results.count > 2) {
        @autoreleasepool {
            NSMutableArray *tmplist = [@[] mutableCopy];
            int idx = 0;
            for (NSString *strRes in results) {
                NSString *str = [strRes stringByReplacingOccurrencesOfString:@"'" withString:@""];
                [tmplist addObject:str];
                idx++;
                if (idx == 2) break;
            }
            results = tmplist;
        }
    }
    
    return [results yy_modelToJSONString];
}

// 启动时, 检查所有笔记并加入预览图, 第一把只在本地改动
+ (void)addPreviewPictureInLaunchingTime {
    NSArray *list = [Note xt_findWhere:@"previewPicture is NULL or previewPicture == ''"] ;
//    NSMutableArray *records = [@[] mutableCopy] ;
    
    [list enumerateObjectsUsingBlock:^(Note *note, NSUInteger idx, BOOL * _Nonnull stop) {
        note.previewPicture = [self getMDImageWithContent:note.content] ;
    }] ;
    if (!list || !list.count) return ;
    
    [Note xt_updateList:list whereByProp:@"icRecordName"] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ;
}

- (NSString *)displayDesciptionString {
    NSString *content = [Note filterMD:self.content] ;
    if (!content || !content.length) content = @"美好的故事，从小章鱼开始..." ;
    
    NSString *title = [Note filterMD:self.title] ;
    if (title.length < content.length && title.length > 0) {
        content = [content substringFromIndex:title.length] ;
    }
        
    if (content.length > 70) content = [[content substringToIndex:70] stringByAppendingString:@" ..."] ;
    
    return content ;
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
