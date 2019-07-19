//
//  WebModel.h
//  Notebook
//
//  Created by teason23 on 2019/6/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class WordCount ;

@interface WebModel : NSObject
@property (copy, nonatomic)     NSString    *markdown ;
@property (strong, nonatomic)   WordCount   *wordCount ;
+ (id)convertjsonStringToJsonObj:(NSString *)jsonString ;

+ (NSArray *)currentTypeWithList:(NSString *)jsonlist  ;

@end

@interface WordCount : NSObject
@property (nonatomic) int word ;
@property (nonatomic) int paragraph ;
@property (nonatomic) int character ;
@property (nonatomic) int all ;
@end



@interface TypeSelectedItem : NSObject
@property (nonatomic, strong) NSArray *affiliation ;
@end

@interface Affiliation : NSObject
@property (nonatomic, copy) NSString *type ;
@property (nonatomic, copy) NSString *listType ;
@property (nonatomic, copy) NSString *listItemType ;
@end




NS_ASSUME_NONNULL_END
