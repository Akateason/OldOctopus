//
//  MarkdownVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownVC.h"
#import "MarkdownEditor.h"

@interface MarkdownVC ()
@property (weak, nonatomic) IBOutlet MarkdownEditor *textView;

@end

@implementation MarkdownVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (IBAction)undo:(id)sender {
    [[self.textView undoManager] undo];
}

- (IBAction)redo:(id)sender {
    [[self.textView undoManager] redo];
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
