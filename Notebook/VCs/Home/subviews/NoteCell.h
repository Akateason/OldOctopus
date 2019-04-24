//
//  NoteCell.h
//  Notebook
//
//  Created by teason23 on 2019/3/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealTableViewCell.h"
//#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoteCell : SWRevealTableViewCell
@property (weak, nonatomic) IBOutlet UIView *area;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbContent;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;

@property (copy, nonatomic) NSString *textForSearching ;

@end

NS_ASSUME_NONNULL_END
