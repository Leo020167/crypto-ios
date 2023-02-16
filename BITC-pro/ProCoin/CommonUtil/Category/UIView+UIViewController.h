//
//  UIView+Layout.h
//  TJRtaojinroad
//
//  Created by taojinroad on 22/02/2017.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseViewController.h"

@interface UIView (TJRBaseViewController)
/**
 *  @brief  通过View获取TJRBaseViewController,可能为nil
 *
 *  @param TJRBaseViewController  (TJRBaseViewController description
 *
 */
- (void)viewControllerOrNilTodo:(void (^)(TJRBaseViewController *vc))toDo;

/**
 *  @brief  通过View获取UIViewController,如果当前View没有的话,则取最顶上的UIViewController
 *
 *  @param UIViewController  UIViewController description
 *
 */
-(void)viewControllerTodo:(void (^)(UIViewController *vc))toDo;


// 通过view获取到它所在的viewController
- (UIViewController*)viewController;

@end
