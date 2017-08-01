//
//  UIView+DDAddition.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/19.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DDAddition)


/**
 增加了一些好用的基本属性
 */

/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat height;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize size;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;


///**
// * Finds the first descendant view (including this view) that is a member of a particular class.
// */
//- (UIView*)descendantOrSelfWithClass:(Class)cls;
//
///**
// * Finds the first ancestor view (including this view) that is a member of a particular class.
// */
//- (UIView*)ancestorOrSelfWithClass:(Class)cls;
//

/**
 * Removes all subviews.
 */
- (void)removeAllSubviews;
//
///**
// * The view controller whose view contains this view.
// */
//- (UIViewController*)viewController;

- (id)subviewWithTag:(NSInteger)tag;


@end
