 //
//  MarkdownVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownVC.h"
#import "MarkdownEditor.h"
#import <XTlib/XTCameraHandler.h>
#import <XTlib/XTPACropImageVC.h>
#import <XTlib/XTPhotoAlbumVC.h>

@interface MarkdownVC ()
@property (strong, nonatomic) MarkdownEditor *textView ;
@property (strong, nonatomic) XTCameraHandler *handler;

@end

@implementation MarkdownVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"zample" ofType:@"md"] ;
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"zample2" ofType:@"md"] ;
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

- (IBAction)exit:(id)sender {
    [self.textView resignFirstResponder] ;
}

- (IBAction)photo:(id)sender {
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:nil cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@[ @"album+crop", @"camera+crop" ] callBackBlock:^(NSInteger btnIndex) {
        
        switch (btnIndex) {
            case 1: [self albumAddCrop]; break;
            case 2: [self cameraAddCrop]; break;
            default:
                break;
        }
        
    }];
}

- (void)albumAddCrop {
    XTPAConfig *config           = [[XTPAConfig alloc] init];
    config.albumSelectedMaxCount = 1;
    
    //    @weakify(self)
    [XTPhotoAlbumVC openAlbumWithConfig:config fromCtrller:self willDismiss:NO getResult:^(NSArray<UIImage *> *_Nonnull imageList, NSArray<PHAsset *> *_Nonnull assetList, XTPhotoAlbumVC *vc) {
        
        //        @strongify(self)
        if (!imageList) return;
        
        @weakify(vc)
        [XTPACropImageVC showFromCtrller:vc imageOrigin:imageList.firstObject croppedImageCallback:^(UIImage *_Nonnull image) {
            @strongify(vc)
            [vc dismissViewControllerAnimated:YES completion:nil];
            
            
        }];
    }];
}

- (void)cameraAddCrop {
    @weakify(self)
    XTCameraHandler *handler = [[XTCameraHandler alloc] init];
    [handler openCameraFromController:self takePhoto:^(UIImage *imageResult) {
        if (!imageResult) return;
        
        @strongify(self)
        [XTPACropImageVC showFromCtrller:self imageOrigin:imageResult croppedImageCallback:^(UIImage *_Nonnull image){
            
        }];
    }];
    self.handler = handler;
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
