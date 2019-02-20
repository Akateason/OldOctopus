//
//  EditVC.m
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "EditVC.h"
#import "NoteModel.h"

@interface EditVC ()

@end

@implementation EditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)saveAction:(id)sender {
    NSString *html = [NoteModel getHTMLWithAttributedString:self.textView.attributedText] ;
    NSLog(@"html : %@", html) ;
    
    NoteModel *model = [NoteModel new] ;
    model.title = [self.textView.text substringToIndex:1] ;
    
    model.htmlString = html ;
    [model xt_insert] ;
    
    [self.navigationController popViewControllerAnimated:YES] ;
}

- (void)config:(NSString *)htmlstr {
    self.textView.attributedText = [NoteModel getAttributedStringWithHTML:htmlstr] ;
}






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
