 //
//  MarkdownVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownVC.h"
#import "MarkdownEditor.h"
#import <XTlib/XTPhotoAlbum.h>
#import "Note.h"


@interface MarkdownVC ()
@property (strong, nonatomic) MarkdownEditor *textView ;
@property (strong, nonatomic) XTCameraHandler *handler;

@property (strong, nonatomic) Note *aNote ;

@end

@implementation MarkdownVC

+ (instancetype)newWithNote:(Note *)note
                fromCtrller:(UIViewController *)ctrller {
    
    MarkdownVC *vc = [MarkdownVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"MarddownVC"] ;
    vc.aNote = note ;
    [ctrller.navigationController pushViewController:vc animated:YES] ;
    return vc ;
}

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

- (MarkdownEditor *)textView{
    if(!_textView){
        _textView = ({
            MarkdownEditor * editor = [[MarkdownEditor alloc]init];
            [self.view addSubview:editor] ;
            [editor mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.view) ;
                make.top.equalTo(self.mas_topLayoutGuideBottom) ;
                make.bottom.equalTo(self.view) ;
            }] ;
            editor;
       });
    }
    return _textView;
}

@end
