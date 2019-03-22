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
@property (strong, nonatomic) NBRichTextEditor *textview;

@end


@implementation SMSHEditorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NBRichTextEditor *tv = [[NBRichTextEditor alloc] init] ;
    [self.view addSubview:tv] ;
    [tv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view) ;
    }] ;
}


@end
