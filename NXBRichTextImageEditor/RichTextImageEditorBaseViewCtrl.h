//
//  RichTextImageEditorBaseViewCtrl.h
//  NXBRichTextImageEditor
//
//  Created by beyondsoft-聂小波 on 16/8/12.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXBRichTextView.h"


@interface RichTextImageEditorBaseViewCtrl : UIViewController
//本地存储数据
@property (nonatomic, strong) NSArray *infoArray;
@property (nonatomic, strong) NXBRichTextView *textView;

- (void)back_btn_click;
@end
