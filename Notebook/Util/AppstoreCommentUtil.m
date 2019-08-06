//
//  AppstoreCommentUtil.m
//  Notebook
//
//  Created by teason23 on 2019/8/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "AppstoreCommentUtil.h"
#import <StoreKit/StoreKit.h>
#import <XTlib/XTlib.h>

@implementation AppstoreCommentUtil

static NSString *const kUD_Key_AppReview_Date = @"kUD_Key_AppReview_Date" ;

+ (void)setup {
    if ([XT_USERDEFAULT_GET_VAL(kUD_Key_AppReview_Date) longLongValue] == 0) {
        XT_USERDEFAULT_SET_VAL(@([[NSDate date] xt_getTick]), kUD_Key_AppReview_Date) ;
    }
}

+ (void)jumpReviewAfterNoteRead {
    NSDate *now = [NSDate date] ;
    NSDate *cache = [NSDate xt_getDateWithTick:[XT_USERDEFAULT_GET_VAL(kUD_Key_AppReview_Date) longLongValue]] ;
    NSTimeInterval time = [now timeIntervalSinceDate:cache] ;
    int days = abs(((int)time)/(3600*24)) ;
    if (days > 7) {
        XT_USERDEFAULT_SET_VAL(@([[NSDate date] xt_getTick]), kUD_Key_AppReview_Date) ;
        [self goReview] ;
    }
}

/** Request StoreKit to ask the user for an app review. This may or may not show any UI.
 *
 *  Given this may not succussfully present an alert to the user, it is not appropriate for use
 *  from a button or any other user action. For presenting a write review form, a deep link is
 *  available to the App Store by appending the query params "action=write-review" to a product URL.
 */
+ (void)goReview {
    [SKStoreReviewController requestReview] ;
}

+ (void)goReviewToAppstore {
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", @"1455174888"] ;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]] ;
}


@end
