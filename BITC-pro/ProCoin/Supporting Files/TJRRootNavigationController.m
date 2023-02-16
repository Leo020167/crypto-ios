//
//  TJRRootNavigationController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12-10-9.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRRootNavigationController.h"
#import "TJRBaseViewController.h"
#import "TJRDropdownMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "HomeViewController.h"
#import "UIViewController+PublicMethods.h"

#define TranslationStepMax	6
#define ChangedTranslation	7			// 范围灵敏度，数值越大触摸程度越强烈，数值越小自动翻页越容易

@interface TJRRootNavigationController ()<UINavigationControllerDelegate>{
    NSMutableArray* ctrs;
}

@end

@implementation TJRRootNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	self = [super initWithRootViewController:rootViewController];

	if (self) {
		noGestureArray = [[NSArray alloc] initWithObjects:@"StockTalkPlayImageView", @"KLineView",@"NewKLineView",@"KLineViewAndNetData",@"LXBase", @"TJROptionsBar",@"FinancialJinHuiCursorView",@"CircleChatRecordView",@"CircleChatMsgToolView",nil];
	}

	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    self.interactivePopGestureRecognizer.enabled = YES;
    self.interactivePopGestureRecognizer.delegate = self;
    
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(handleGesture:)];
    
    ctrs = [[NSMutableArray alloc]init];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.topViewController isKindOfClass:[HomeViewController class]] || ![self isCanDragBack]){
        //关闭主界面的右滑返回
        return NO;
    }else{
         [self dragPopViewController];
        return YES;
    }
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
// 根据最顶端viewController决定navgationController的方向
- (BOOL)shouldAutorotate {
	return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return self.topViewController.supportedInterfaceOrientations;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    
    
    BOOL bRespond = [self getRespondsToSelector] && _dragBackIndex>0;
    if (bRespond) {
        int index = _dragBackIndex;
        
        if (index > self.viewControllers.count - 1) {
            return nil;
        }
        
        [ctrs removeAllObjects];
        
        NSArray* ctrArr = [super popToViewController:[self.viewControllers objectAtIndex:index] animated:animated];
        [ctrs addObjectsFromArray:ctrArr];
    
        return [self.viewControllers objectAtIndex:index];
        
    }else{
        UIViewController *viewController = [super popViewControllerAnimated:animated];
        return viewController;
    }
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {

	NSArray *viewControllerArray = [super popToViewController:viewController animated:animated];
	return viewControllerArray;
}


- (void)dragPopViewController{

    if ([self getRespondsToSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.topViewController performSelector:@selector(gestureDragBack)];// 当页面有多个返回页面时.请实现这个方法
#pragma clang diagnostic pop
    }
}

- (BOOL)getRespondsToSelector{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    return [self.topViewController respondsToSelector:@selector(gestureDragBack)];
#pragma clang diagnostic pop
    
}

- (void)clearTJRHttpDelegate {
	if ([self.topViewController respondsToSelector:@selector(clearTJRHttpDelegate)]) {
		[self.topViewController performSelector:@selector(clearTJRHttpDelegate)];
	}
}


- (BOOL)isCanDragBack {

	if ([self.topViewController isKindOfClass:[TJRBaseViewController class]]) {
		return [((TJRBaseViewController *)self.topViewController)canDragBack];
	}

	return NO;
}

static NSTimeInterval lastTime;

- (void)handleGesture:(UIPanGestureRecognizer *)recognizer {
    if ((self.viewControllers.count <= 1)) {
        return;
    }
    CGPoint touchPoint = [recognizer locationInView:KEY_WINDOW];
    float translation = [recognizer translationInView:KEY_WINDOW].x;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            startTouch = touchPoint;
            isMoving = NO;
            lastTime = [NSDate timeIntervalSinceReferenceDate];
            
           [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:DragBackBegan object:nil userInfo:nil]];
            
            if (ctrs.count>1 && _dragBackIndex>1) {
                
                for (TJRBaseViewController* ctr in ctrs) {
                    id block = [ctr gesturePopCallback];
                    if (block) {
                        ((void (^)(void))block)();
                    }
                    [ctr removeGesturePopCallback];
                }
                
                [self clearTJRHttpDelegate];
                recognizer.enabled = NO;
                self.dragBackIndex = 0;
                [ctrs removeAllObjects];
                [super popViewControllerAnimated:YES];
            }
            
            break;
            
        case UIGestureRecognizerStateChanged:
            
            if (!isMoving) {
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:DragBackChange object:nil userInfo:nil]];
                isMoving = YES;
            }
            break;
            
        case UIGestureRecognizerStateEnded:{
            //当速度大与平均值时，视为快速滑动返回。或者滑动返回距离大于半个页面
            
            if ((fabs(translation/(lastTime-[NSDate timeIntervalSinceReferenceDate]))>400.0) || (touchPoint.x - startTouch.x > self.view.bounds.size.width * 0.5f)) {
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:DragBackEnd object:nil userInfo:nil]];
                
                for (TJRBaseViewController* ctr in ctrs) {
                    id block = [ctr gesturePopCallback];
                    if (block) {
                        ((void (^)(void))block)();
                    }
                    [ctr removeGesturePopCallback];
                }
                [ctrs removeAllObjects];
            }
            for (TJRBaseViewController* ctr in ctrs) {
                [ctr removeGesturePopCallback];
            }
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:DragBackUp object:nil userInfo:nil]];
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            self.dragBackIndex = 0;
            recognizer.enabled = YES;
            isMoving = NO;
            [ctrs removeAllObjects];
            break;
        default:
            break;
    }
}


- (void)dealloc {
	RELEASE(noGestureArray);
	[_blackMask release];
	[self.backgroundView removeFromSuperview];
	[_backgroundView release];
	[super dealloc];
}

@end

