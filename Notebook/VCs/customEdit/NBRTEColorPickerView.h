//
//  NBRTEColorPickerView.h
//  Notebook
//
//  Created by teason23 on 2019/2/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NBRTEToolbar, NBRTEColorPickerView;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    NBRTEColorPickerView_typeTextColor = 1 ,
    NBRTEColorPickerView_typeTextBackGroundColor,
    
} NBRTEColorPickerViewType ;

@protocol NBRTEColorPickerViewDelegate <NSObject>
@required
- (void)onNBRTEColorPickerView:(NBRTEColorPickerView *)colorPicker didPickColor:(UIColor *)color type:(NBRTEColorPickerViewType)type ;
- (void)returnToKeyboard ;
@end




@interface NBRTEColorPickerView : UIView
@property (weak, nonatomic) id <NBRTEColorPickerViewDelegate> delegate ;

- (instancetype)initWithHeight:(float)height
                toolBarHandler:(id)handler ; // handle delegate .

- (void)addColorPickerAboveKeyboardViewWithKeyboardHeight:(float)keyboardHeight type:(NBRTEColorPickerViewType)type ;
@end

NS_ASSUME_NONNULL_END
