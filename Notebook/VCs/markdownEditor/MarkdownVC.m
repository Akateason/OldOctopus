 //
//  MarkdownVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownVC.h"
#import "MarkdownEditor.h"
#import "MarkdownEditor+UtilOfToolbar.h"
#import <XTlib/XTPhotoAlbum.h>
#import "Note.h"


@interface MarkdownVC ()
@property (strong, nonatomic) MarkdownEditor *textView ;
@property (strong, nonatomic) XTCameraHandler *handler;

@property (strong, nonatomic) Note *aNote ;
@property (copy, nonatomic) NSString *myBookID ;
@end

@implementation MarkdownVC

#pragma mark - life

- (void)dealloc {}

+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
                fromCtrller:(UIViewController *)ctrller {
    
    MarkdownVC *vc = [MarkdownVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"MarddownVC"] ;
    vc.aNote = note ;
    vc.delegate = ctrller ;
    vc.myBookID = bookID ;
    [ctrller.navigationController pushViewController:vc animated:YES] ;
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.aNote) {
        [self.textView setArticleTitle:self.aNote.title] ;
        self.textView.text =self.aNote.content ;
    }
    else {
        // Create New Note
//        [self createNewNote] ;
    }
    
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] takeUntil:self.rac_willDeallocSignal] throttle:3.] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        // Update Your Note
        [self updateMyNote] ;
    }] ;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
    
    if (self.aNote) {
        // Update Your Note
        [self updateMyNote] ;
    }
    else {
        // Create New Note
        [self createNewNote] ;
    }
}

#pragma mark - Func

- (void)createNewNote {
    NSString *articleTitle = self.textView.titleLabel.text ;
    NSString *articleContent = self.textView.text ;
    
    if ((articleTitle && articleTitle.length) || (articleContent && articleContent.length) ) {
        Note *newNote = [[Note alloc] initWithBookID:self.myBookID content:articleContent?:@"美好的故事，从小章鱼开始..." title:articleTitle?:@"一篇没有名字的笔记"] ;
        self.aNote = newNote ;
        self.textView.text = self.aNote.content ;
        [Note createNewNote:self.aNote] ;
        [self.delegate addNoteComplete:self.aNote] ;
    }
}

- (void)updateMyNote {
    self.aNote.content = self.textView.text ;
    self.aNote.title = self.textView.titleLabel.text ;
    [Note updateMyNote:self.aNote] ;
    [self.delegate editNoteComplete:self.aNote] ;
}

#pragma mark - UI

- (void)prepareUI {
    [self textView] ;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"md_ed_more"] style:UIBarButtonItemStylePlain target:self action:@selector(more)] ;
    self.navigationItem.rightBarButtonItem = item ;
}

- (void)more {
    
}

#pragma mark - prop

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
