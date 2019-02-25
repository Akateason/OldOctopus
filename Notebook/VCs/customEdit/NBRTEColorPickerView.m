//
//  NBRTEColorPickerView.m
//  Notebook
//
//  Created by teason23 on 2019/2/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "NBRTEColorPickerView.h"
#import "NBRTEToolbar.h"
#import <Masonry/Masonry.h>
#import "NBRichTextEditor.h"
#import "UITextView+XTAddition.h"


@interface NBRTEColorPickerView ()
//@property (strong, nonatomic) NBRTEToolbar *toolBar;
@property (nonatomic) NBRTEColorPickerViewType type;
@property (strong, nonatomic) UIButton *btBack;
@end


@implementation NBRTEColorPickerView

- (void)addColorPickerAboveKeyboardViewWithKeyboardHeight:(float)keyboardHeight
                                                     type:(NBRTEColorPickerViewType)type {
    self.type = type;
    for (UIView *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
            [window addSubview:self];
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.left.right.equalTo(window);
                make.height.equalTo(@(keyboardHeight));
            }];
        }
    }
}

- (instancetype)initWithHeight:(float)height
                toolBarHandler:(id)handler {
    self = [super init];
    if (self) {
        //        NBRTEToolbar *toolbar = [[NBRTEToolbar alloc] initWithFrame:CGRectMake(0, 0, [(UITextView *)handler currentScreenBoundsDependOnOrientation].size.width, 40) delegate:handler dataSource:handler];
        self.backgroundColor = [UIColor yellowColor];
        //        [self addSubview:toolbar];
        //        [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.left.right.equalTo(self);
        //            make.height.equalTo(@40);
        //        }];

        self.delegate = handler;
        //        self.toolBar = toolbar;
        [self btBack];

        [self customButtons];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"color picker dealloc !!!");
}


- (void)customButtons {
    UIButton *btRed = [UIButton new];
    [btRed setBackgroundColor:[UIColor redColor]];
    [btRed setTitle:@"" forState:0];
    [btRed addTarget:self action:@selector(colorRedSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btRed];
    [btRed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.center.equalTo(self);
    }];


    UIButton *btBlue = [UIButton new];
    [btBlue setBackgroundColor:[UIColor blueColor]];
    [btBlue setTitle:@"" forState:0];
    [btBlue addTarget:self action:@selector(colorBlueSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btBlue];
    [btBlue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.equalTo(self);
        make.left.equalTo(btRed.mas_right).offset(5);
    }];
}

- (void)colorRedSelected {
    [self.delegate onNBRTEColorPickerView:self didPickColor:[UIColor redColor] type:self.type];
}

- (void)colorBlueSelected {
    [self.delegate onNBRTEColorPickerView:self didPickColor:[UIColor blueColor] type:self.type];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (UIButton *)btBack {
    if (!_btBack) {
        _btBack = ({
            UIButton *object = [[UIButton alloc] init];
            [object setTitle:@"返回" forState:0];
            object.backgroundColor = [UIColor greenColor];
            [object setTitleColor:[UIColor blackColor] forState:0];
            [object addTarget:self action:@selector(returnToKeyboardOnclick) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:object];
            [object mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(50, 30));
                make.top.right.equalTo(self);
            }];

            object;
        });
    }
    return _btBack;
}

- (void)returnToKeyboardOnclick {
    [self.delegate returnToKeyboard];
    [self removeFromSuperview];
    //    self = nil ;
}

@end
