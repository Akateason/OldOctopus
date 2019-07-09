//
//  EmojiJson.m
//  Notebook
//
//  Created by teason23 on 2019/4/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "EmojiJson.h"
#import <XTlib/XTlib.h>
#import "NoteBooks.h"

@implementation EmojiJson

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"description" : @"descriptionEm",
             };
}




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

#pragma mark --
//People,
//Nature,
//Foods,
//Activity,
//Places,
//Objects,
//Symbols,
//Flags

+ (NSArray *)arrayCategory {
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




@end
