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
#import <MessageUI/MessageUI.h>

@implementation AppstoreCommentUtil

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

+ (void)sendMailForReplyBugsFromCtrller:(UIViewController *)fromCtrller {
    
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    if (!mailCompose) {
        NSLog(@"用户未设置系统邮件客户端") ;
        return ;
    }
    mailCompose.mailComposeDelegate = self.class ;
    //设置主题
    [mailCompose setSubject:@"反馈给小章鱼"];
    
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObjects:@"xietianchen@shimo.im",nil];
    [mailCompose setToRecipients: toRecipients];
    
    //富文本为 isHTML：YES  字符串isHTML：NO
    NSString *emailBody = @"我的邮件";
    [mailCompose setMessageBody:emailBody isHTML:NO];
    [fromCtrller presentViewController:mailCompose animated:NO completion:^{
        
    }];
}

#pragma mark - mail compose delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
 didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result) {
        NSLog(@"Result : %d",result);
    }
    if (error) {
        NSLog(@"Error : %@",error);
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
