//
//  SMSHEditorVC.m
//  Notebook
//
//  Created by teason23 on 2019/2/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SMSHEditorVC.h"
#import "NBRichTextEditor.h"

@interface SMSHEditorVC ()
@property (weak, nonatomic) IBOutlet NBRichTextEditor *textview;

@end

@implementation SMSHEditorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

- (IBAction)actionBold:(UIButton *)sender {
    sender.selected = !sender.selected ;
    
    [self.textview setBold:sender.selected] ;
}

- (IBAction)actionI:(id)sender {
}

- (IBAction)actionU:(id)sender {
}

- (IBAction)actionPhoto:(id)sender {
}

- (IBAction)actionFontSize:(id)sender {
}








@end
