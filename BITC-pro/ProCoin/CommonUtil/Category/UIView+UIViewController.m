//
//  UIView+Layout.m
//  TJRtaojinroad
//
//  Created by taojinroad on 22/02/2017.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "UIView+UIViewController.h"

@implementation UIView (TJRBaseViewController)

/**
 *  @brief  通过View获取TJRBaseViewController,可能为nil
 *
 *  @param TJRBaseViewController  (TJRBaseViewController description
 *
 */ 
- (void)viewControllerOrNilTodo:(void (^)(TJRBaseViewController *vc))toDo {
    TJRBaseViewController *ctr= nil;
    UIResponder *responder = self.nextResponder;
    
    while (![responder isKindOfClass:[TJRBaseViewController class]]) {
        responder = responder.nextResponder;
        if([responder isKindOfClass:[UIWindow class]]){
            responder = nil;
            break;
        }
    }
    if (responder) {
        ctr = (TJRBaseViewController *)responder;
    }
    if (toDo) toDo(ctr);
}

/**
 *  @brief  通过View获取UIViewController,如果当前View没有的话,则取最顶上的UIViewController
 *
 *  @param UIViewController  UIViewController description
 *
 */ 
-(void)viewControllerTodo:(void (^)(UIViewController *vc))toDo {
    [self viewControllerOrNilTodo:^(UIViewController *vc) {
        if (!vc) {
            vc = ROOTCONTROLLER.navigationController.topViewController;
        }
        if (toDo) toDo(vc);
    }];
}

// 通过view获取到它所在的viewController
- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}


@end
