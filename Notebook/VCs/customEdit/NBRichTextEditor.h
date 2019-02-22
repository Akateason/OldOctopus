//
//  NBRichTextEditor.h
//  Notebook
//
//  Created by teason23 on 2019/2/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NBRTEToolbar.h"


NS_ASSUME_NONNULL_BEGIN
@class NBRichTextEditor;

@protocol NBRichTextEditorDatasource <NSObject>
@optional
- (RichTextEditorFeature)featuresEnabledForRichTextEditor:(NBRichTextEditor *)richTextEditor;
- (BOOL)shouldDisplayToolbarForRichTextEditor:(NBRichTextEditor *)richTextEditor;
- (BOOL)shouldDisplayRichTextOptionsInMenuControllerForRichTextEditor:(NBRichTextEditor *)richTextEdiotor;

@end


@interface NBRichTextEditor : UITextView
@property (weak, nonatomic) id<NBRichTextEditorDatasource> dataSource;
@property (nonatomic) CGFloat defaultIndentationSize;

- (void)setBold:(BOOL)isBold;


@end

NS_ASSUME_NONNULL_END
