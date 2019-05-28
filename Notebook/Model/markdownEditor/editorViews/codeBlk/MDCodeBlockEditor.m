//
//  MDCodeBlockEditor.m
//  Notebook
//
//  Created by teason23 on 2019/4/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDCodeBlockEditor.h"
#import "MDThemeConfiguration.h"
#import "RegexHighlightView.h"

@interface MDCodeBlockEditor ()
@property (strong, nonatomic) RegexHighlightView *highlightView ;
@end

@implementation MDCodeBlockEditor

- (instancetype)initWithFrame:(CGRect)frame
                        model:(MdBlockModel *)model {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor] ;
        
        NSString *firstPrefix = [[model.str componentsSeparatedByString:@"\n"] firstObject] ;
        NSRange range = NSMakeRange(firstPrefix.length + 1, model.length - 4 - firstPrefix.length - 1) ;
        NSString *textStr = [model.str substringWithRange:range] ;
        
        RegexHighlightView *highlightView = [[RegexHighlightView alloc] init] ;
        highlightView.text = textStr ;
        [highlightView setHighlightTheme:kRegexHighlightViewThemeDefault] ;
        highlightView.font = [MDThemeConfiguration sharedInstance].editorThemeObj.font ;
        
        [highlightView setHighlightDefinitionWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"java" ofType:@"plist"]] ;

//        highlightView.userInteractionEnabled = NO ;
        [self addSubview:highlightView] ;
        [highlightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self) ;
            make.top.equalTo(self.mas_top).offset(30) ;
            make.left.equalTo(self.mas_left).offset(30) ;
            make.right.equalTo(self.mas_right).offset(-30) ;
        }] ;
        self.highlightView = highlightView ;
        
        
    }
    return self ;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
