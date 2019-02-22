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
@property (strong, nonatomic) NBRTEToolbar *toolBar;
@end


@implementation NBRTEColorPickerView

- (instancetype)initWithHeight:(float)height
                toolBarHandler:(id)handler {
    self = [super init];
    if (self) {
        NBRTEToolbar *toolbar = [[NBRTEToolbar alloc] initWithFrame:CGRectMake(0, 0, [(UITextView *)handler currentScreenBoundsDependOnOrientation].size.width, 40) delegate:handler dataSource:handler];
        self.backgroundColor  = [UIColor yellowColor];
        [self addSubview:toolbar];
        [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(@40);
        }];
        self.toolBar = toolbar;
    }
    return self;
}


- (void)dealloc {
    NSLog(@"color picker dealloc !!!");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
