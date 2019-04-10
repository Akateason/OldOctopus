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


@interface MarkdownVC ()
@property (strong, nonatomic) MarkdownEditor *textView ;
@property (strong, nonatomic) XTCameraHandler *handler;

@property (strong, nonatomic) Note *aNote ;
@property (copy, nonatomic) NSString *myBookID ;

@property (nonatomic) BOOL thisArticleHasChanged ;
@end

@implementation MarkdownVC

#pragma mark - Life

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
        self.textView.text = self.aNote.content ;
    }
    
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] takeUntil:self.rac_willDeallocSignal] throttle:3.] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        // Update Your Note
        [self updateMyNote] ;
        if (!self.thisArticleHasChanged) self.thisArticleHasChanged = YES ;
    }] ;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
    
    if (self.aNote) {
        // Update Your Note
        if (self.thisArticleHasChanged) [self updateMyNote] ;
    }
    else {
        // Create New Note
        [self createNewNote] ;
    }
}

#pragma mark - Func

- (void)createNewNote {
    NSString *articleContent = self.textView.text ;
    NSString *title = [[self.textView.text componentsSeparatedByString:@"\n"] firstObject] ?: self.textView.text ;
    if (articleContent && articleContent.length) {
        Note *newNote = [[Note alloc] initWithBookID:self.myBookID content:articleContent title:title] ;
        self.aNote = newNote ;
        self.textView.text = self.aNote.content ;
        [Note createNewNote:self.aNote] ;
        [self.delegate addNoteComplete:self.aNote] ;
    }
}

- (void)updateMyNote {
    if (!self.aNote) return ;
    
    self.aNote.content = self.textView.text ;
    self.aNote.title = [[self.textView.text componentsSeparatedByString:@"\n"] firstObject] ?: self.textView.text ;
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
