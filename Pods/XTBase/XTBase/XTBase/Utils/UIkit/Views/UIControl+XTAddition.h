//
//  UIControl+XTAddition.h
//  XTBase
//
//  Created by teason23 on 2020/4/10.
//  Copyright © 2020 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (XTAddition)

/** Adds a block for a particular event to an internal dispatch table.

 @param handler A block representing an action message, with an argument for the sender.
 @param controlEvents A bitmask specifying the control events for which the action message is sent.
 @see removeEventHandlersForControlEvents:
 */
- (void)xt_addEventHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents;

/** Removes all control event blocks associated with the given mask of control
 * events.
 *
 * Do note that, like @c UIControl, this method will not decompose control
 * events; thus, only a handler matching an exact given bitmask will be removed.
 *
 * @param controlEvents A bitmask specifying the control events for which the block will be removed.
 * @see addEventHandler:forControlEvents:
 */
- (void)xt_removeEventHandlersForControlEvents:(UIControlEvents)controlEvents;

/** Checks to see if the control has any blocks for a particular event combination.
 @param controlEvents A bitmask specifying the control events for which to check for blocks.
 @see addEventHandler:forControlEvents:
 @return Returns YES if there are blocks for these control events, NO otherwise.
 */
- (BOOL)xt_hasEventHandlersForControlEvents:(UIControlEvents)controlEvents;
@end

NS_ASSUME_NONNULL_END
