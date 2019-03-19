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
@property (strong, nonatomic) MarkdownEditor *textView;

@end

@implementation MarkdownVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"zample" ofType:@"md"] ;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"zample2" ofType:@"md"] ;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [fileHandle readDataToEndOfFile] ;
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self textView] ;
    self.textView.text = str ;
}

- (IBAction)undo:(id)sender {
    [[self.textView undoManager] undo];
}

- (IBAction)redo:(id)sender {
    [[self.textView undoManager] redo];
}





- (MarkdownEditor *)textView{
    if(!_textView){
        _textView = ({
            MarkdownEditor * editor = [[MarkdownEditor alloc]init];
            [self.view addSubview:editor] ;
            [editor mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.view) ;
                make.top.equalTo(self.mas_topLayoutGuideBottom) ;
                make.height.equalTo(@300) ;
            }] ;
            editor;
       });
    }
    return _textView;
}
@end
