//
//  YYTextVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/11.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "YYTextVC.h"
#import <YYText.h>

@interface YYTextVC () <YYTextViewDelegate>
@property (strong, nonatomic) YYTextView *textview ;
@end

@implementation YYTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *text = @"#Markdown Editor\nThis is a simple markdown editor based on `YYTextView`.\n\n*********************************************\nIt\'s *italic* style.\n\nIt\'s also _italic_ style.\n\nIt\'s **bold** style.\n\nIt\'s ***italic and bold*** style.\n\nIt\'s __underline__ style.\n\nIt\'s ~~deleteline~~ style.\n\n\nHere is a link: [YYKit](https://github.com/ibireme/YYKit)\n\nHere is some code:\n\n\tif(a){\n\t\tif(b){\n\t\t\tif(c){\n\t\t\t\tprintf(\"haha\");\n\t\t\t}\n\t\t}\n\t}\n";
    
    YYTextSimpleMarkdownParser *parser = [YYTextSimpleMarkdownParser new];
//    [parser setColorWithDarkTheme];
    
    YYTextView *textView = self.textview ;
    textView.text = text;
    textView.font = [UIFont systemFontOfSize:16];
    textView.textParser = parser;
    textView.size = self.view.size;
    textView.textContainerInset = UIEdgeInsetsMake(0, 30, 0, 30);
    textView.delegate = self;
    
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
//    textView.backgroundColor = [UIColor colorWithWhite:0.134 alpha:1.000];
    textView.backgroundColor = [UIColor whiteColor] ;
    textView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    textView.scrollIndicatorInsets = textView.contentInset;
    textView.selectedRange = NSMakeRange(text.length, 0);
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (YYTextView *)textview{
    if(!_textview){
        _textview = ({
            YYTextView * object = [[YYTextView alloc]init];
            if (!object.superview) {
                [self.view addSubview:object] ;
                [object mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.view) ;
                }] ;
            }
            object;
       });
    }
    return _textview;
}
@end
