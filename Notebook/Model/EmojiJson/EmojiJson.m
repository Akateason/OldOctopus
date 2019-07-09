//
//  EmojiJson.m
//  Notebook
//
//  Created by teason23 on 2019/4/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "EmojiJson.h"
#import "NoteBooks.h"

@implementation EmojiJson

//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{@"description" : @"descriptionEm",
//             };
//}

+ (NSArray *)allList {
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"emojisJson" ofType:@"json"] ;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    NSArray *list = [NSArray yy_modelArrayWithClass:EmojiJson.class json:jsonString] ;
    return list ;
}

+ (NSString *)randomADistinctEmojiWithBooklist:(NSArray *)booklist {
    NSArray *list = [self allList] ;
    return [self getResultEmojiWithEmojiList:list booklist:booklist] ;
}

+ (NSString *)getResultEmojiWithEmojiList:(NSArray *)list booklist:(NSArray *)booklist {
    NSString *resultEmoji ;
    int random = arc4random() % list.count ;

    EmojiJson *eJson = [self list:list random:random] ;
    resultEmoji = eJson.emoji ;
    
    if ([self distinctWithBooklist:booklist emoji:resultEmoji]) {
        return [self getResultEmojiWithEmojiList:list booklist:booklist] ;
    }
    return resultEmoji ;
}

+ (EmojiJson *)list:(NSArray *)list random:(int)random {
    return list[random] ;
}

+ (BOOL)distinctWithBooklist:(NSArray *)booklist emoji:(NSString *)emoji {
    for (int i = 0; i < booklist.count; i++) {
        NoteBooks *book = booklist[i] ;
        if ([book.displayEmoji isEqualToString:emoji]) {
            return YES ;
        }
    }
    return NO ;
}
@end








@implementation EmojiJsonManager
XT_SINGLETON_M(EmojiJsonManager)

- (NSArray *)allList {
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"emojisJson" ofType:@"json"] ;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path] ;
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    NSArray *list = [NSArray yy_modelArrayWithClass:EmojiJson.class json:jsonString] ;
    return list ;
}

- (NSArray *)arrayCategory {
    return @[
             @"People",
             @"Nature",
             @"Foods",
             @"Activity",
             @"Places",
             @"Objects",
             @"Symbols",
             @"Flags"
             ] ;
}

- (NSArray *)chineseCategory {
    return @[
             @"笑脸 & 人物",
             @"动物 & 自然",
             @"食物 & 饮料",
             @"活动",
             @"旅游 & 地方",
             @"对象",
             @"符号",
             @"旗帜"
             ] ;
}

- (NSDictionary *)getWholeDatasource {
    NSArray *list = [self allList] ;
    NSMutableDictionary *data = [@{} mutableCopy] ;
    NSArray *cates = [self arrayCategory] ;
    for (NSString *cate in cates) {
        NSArray *tmplist = [self listWithACategory:cate list:list] ;
        [data setObject:tmplist forKey:cate] ;
    }
//    NSLog(@"%@",data) ;
    return data ;
}

- (NSArray *)listWithACategory:(NSString *)cate list:(NSArray *)orgList {
    NSMutableArray *tmpList = [@[] mutableCopy] ;
    [orgList enumerateObjectsUsingBlock:^(EmojiJson *emoji, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([emoji.category isEqualToString:cate]) [tmpList addObject:emoji] ;
    }] ;
    return tmpList ;
}


- (NSArray *)defaultHistory {
    NSArray *list = [self allList] ;
    list = [list subarrayWithRange:NSMakeRange(0, 8)] ;
    return list ;
}

static NSString *const k_UD_Emoji_History = @"k_UD_Emoji_History" ;
- (NSArray *)history {
    NSString *history = XT_USERDEFAULT_GET_VAL(k_UD_Emoji_History) ;
    if (!history) {
        return [self defaultHistory] ;
    }
    return [NSArray yy_modelArrayWithClass:EmojiJson.class json:history] ;
}

- (void)iUseEmoji:(EmojiJson *)emoji {
    NSString *history = XT_USERDEFAULT_GET_VAL(k_UD_Emoji_History) ;
    if (!history) {
        NSString *json = [@[emoji] yy_modelToJSONString] ;
        XT_USERDEFAULT_SET_VAL(json, k_UD_Emoji_History) ;
    }
    else {
        NSArray *hisList = [NSArray yy_modelArrayWithClass:EmojiJson.class json:history] ;
        NSMutableArray *tmpHistory = [hisList mutableCopy] ;
        [hisList enumerateObjectsUsingBlock:^(EmojiJson *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.emoji isEqualToString:emoji.emoji]) {
                [tmpHistory removeObjectAtIndex:idx] ;
            }
        }] ;
        [tmpHistory insertObject:emoji atIndex:0] ;
        if (tmpHistory.count > 8) {
            tmpHistory = [tmpHistory subarrayWithRange:NSMakeRange(0, 8)].mutableCopy ;
        }
        XT_USERDEFAULT_SET_VAL([tmpHistory yy_modelToJSONString], k_UD_Emoji_History) ;
    }
}

@end
