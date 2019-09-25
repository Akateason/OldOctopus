//
//  UnsplashPhoto.h
//  Notebook
//
//  Created by teason23 on 2019/9/24.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface UnsplashPhoto : NSObject

@property (nonatomic) int       photoId ; //id
@property (nonatomic) int       width ;
@property (nonatomic) int       height ;
@property (nonatomic,copy) NSString   *alt_description ;

@property (nonatomic,copy) NSString   *url_reqular ; // change
@property (nonatomic,copy) NSString   *userName ; // change



@end


