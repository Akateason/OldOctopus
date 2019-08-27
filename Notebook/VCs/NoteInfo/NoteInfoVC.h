//
//  NoteInfoVC.h
//  Notebook
//
//  Created by teason23 on 2019/8/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
#import "WebModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface NoteInfoVC : BasicVC
@property (weak, nonatomic) IBOutlet UIView *hud;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btClose;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *seperatelineGroup;
@property (strong, nonatomic) IBOutletCollection(UILabel)NSArray *infoTitlesGroup;

@property (weak, nonatomic) IBOutlet UIButton *btOutput;
@property (weak, nonatomic) IBOutlet UIButton *btRemove;

@property (weak, nonatomic) IBOutlet UILabel *lbNoteBookLocation;
@property (weak, nonatomic) IBOutlet UILabel *lbCreateTime;
@property (weak, nonatomic) IBOutlet UILabel *lbUpdateTime;
@property (weak, nonatomic) IBOutlet UILabel *lbWord;
@property (weak, nonatomic) IBOutlet UILabel *lbCharacter;
@property (weak, nonatomic) IBOutlet UILabel *lbParagraph;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *infoValuesGroup;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width_hud;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height_hud;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_hud;


+ (instancetype)showFromCtrller:(UIViewController *)fromVC
                           note:(Note *)note
                       webModel:(WebModel *)webModel
                 outputCallback:(void(^)(NoteInfoVC *infoVC))outputBlk
                 removeCallBack:(void(^)(NoteInfoVC *infoVC))removeBlk ;



@end

NS_ASSUME_NONNULL_END
