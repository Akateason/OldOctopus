//
//  NBRTEToolbar.h
//  Notebook
//
//  Created by teason23 on 2019/2/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum {
    ParagraphIndentationIncrease,
    ParagraphIndentationDecrease
} ParagraphIndentation;

typedef enum {
    RichTextEditorFeatureNone                          = 0,
    RichTextEditorFeatureFont                          = 1 << 0,
    RichTextEditorFeatureFontSize                      = 1 << 1,
    RichTextEditorFeatureBold                          = 1 << 2,
    RichTextEditorFeatureItalic                        = 1 << 3,
    RichTextEditorFeatureUnderline                     = 1 << 4,
    RichTextEditorFeatureStrikeThrough                 = 1 << 5,
    RichTextEditorFeatureTextAlignmentLeft             = 1 << 6,
    RichTextEditorFeatureTextAlignmentCenter           = 1 << 7,
    RichTextEditorFeatureTextAlignmentRight            = 1 << 8,
    RichTextEditorFeatureTextAlignmentJustified        = 1 << 9,
    RichTextEditorFeatureTextBackgroundColor           = 1 << 10,
    RichTextEditorFeatureTextForegroundColor           = 1 << 11,
    RichTextEditorFeatureParagraphIndentation          = 1 << 12,
    RichTextEditorFeatureParagraphFirstLineIndentation = 1 << 13,
    RichTextEditorFeaturePhotoInsert                   = 1 << 14,
    RichTextEditorFeatureLinkInsert                    = 1 << 15,

    RichTextEditorFeatureAll = 1 << 50
} RichTextEditorFeature;


@protocol NBRTEToolbarDelegate <NSObject>
@required
- (void)toolbarButtonDidSelectCommonFeature:(RichTextEditorFeature)feature;
- (void)toolbarButtonDidSelectParagraphIndent:(ParagraphIndentation)ParagraphIndentation;
- (void)toolbarButtonDidSelectTextAlignment:(NSTextAlignment)textAlignment;
- (void)toolbarDidSelectShutDownKeyboard;
- (void)toolbarDidSelectPhotoInsert;
- (void)toolbarDidSelectLinkInsert;
@end

@protocol NBRTEToolbarDatasource <NSObject>
@required
- (RichTextEditorFeature)featuresEnabledForRichTextEditorToolbar;
@end


@interface NBRTEToolbar : UIView
@property (weak, nonatomic) id<NBRTEToolbarDelegate> tb_Delegate;
@property (weak, nonatomic) id<NBRTEToolbarDatasource> tb_Datasource;

- (id)initWithFrame:(CGRect)frame delegate:(id<NBRTEToolbarDelegate>)delegate dataSource:(id<NBRTEToolbarDatasource>)dataSource;
- (void)updateStateWithAttributes:(NSDictionary *)attributes;
- (void)redraw;

@end

NS_ASSUME_NONNULL_END
