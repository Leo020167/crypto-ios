//
//  UIViewController+PublicMethods.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/3/20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "UIViewController+PublicMethods.h"
#import "TTGlobalCore.h"
#import  <QuartzCore/CoreAnimation.h>
#import "TJRCache.h"
#import "TJRBaseTitleView.h"

#import "TJRBaseTabBarController.h"
#import "TJRBaseViewController.h"
#import <objc/runtime.h>

NSString *const LoginDict = @"LoginDict";
NSString *const RegisterAccountDict = @"RegisterAccount";
NSString *const SettingDict = @"SettingDict";
NSString *const MyHomeDict = @"MyHome";
NSString *const ChatDict = @"ChatDict";
NSString *const FeedbackDict = @"FeedbackDict";
NSString *const FriendHomeDict = @"FriendHomeDict";
NSString *const SearchDict = @"SearchDict";
NSString *const TJRWebViewDict = @"TJRWebViewDict";
NSString *const PushDict = @"PushDict";
NSString *const ShareDict = @"ShareDict";
NSString *const AppPayDict = @"AppPayDict";
NSString *const WebTencentOauthDict = @"WebTencentOauth";
NSString *const ArticleDict = @"ArticleDict";
NSString *const PersonalDict = @"PersonalDict";
NSString *const CircleDict = @"CircleDict";
NSString *const WalletDict = @"WalletDict";
NSString *const FundExchangeDic = @"FundExchangeDic";
NSString *const CoinTradeDic = @"CoinTradeDic";
NSString *const P2PDict = @"P2PDict";
NSString *const FollowOrderDict = @"FollowOrderDict";
NSString *const ProCoinBaseDict = @"ProCoinBaseDict";
NSString *const PCDigitalRecordDict = @"PCDigitalRecordDict";


@implementation UIViewController (PublicMethods)

/**
	设置关联,将viewcontroller与tjr_getViewController关联起来
	@param viewController
 */
- (void)tjr_setViewController:(UIViewController *)viewController {
    objc_setAssociatedObject(self, @selector(tjr_getViewController), viewController, OBJC_ASSOCIATION_ASSIGN);
}

/**
	通过关联获取到viewcontroller
	@returns
 */
- (UIViewController *)tjr_getViewController {
    UIViewController *viewController = objc_getAssociatedObject(self, @selector(tjr_getViewController));
    
    if (!viewController && self.parentViewController) {
        viewController = [self.parentViewController tjr_getViewController];
    }
    
    return viewController;
}

- (void)getTJRViewController:(TJRBaseViewController **)viewController tabBarController:(TJRBaseTabBarController **)tabBarController {
    UIViewController *vController = [self tjr_getViewController];
    if (vController && [vController isKindOfClass:[TJRBaseViewController class]]) {
        *viewController = (TJRBaseViewController *)vController;
    } else if (vController && [vController isKindOfClass:[TJRBaseTabBarController class]]) {
        *tabBarController = (TJRBaseTabBarController *)vController;
    }
}

- (TJRBaseViewController *)getTJRBaseViewController {
    UIViewController *viewController = [self tjr_getViewController];
    if (viewController && [viewController isKindOfClass:[TJRBaseViewController class]]) {
        return (TJRBaseViewController *)viewController;
    }
    return nil;
}

- (TJRBaseTabBarController *)getTJRBaseTabBarController {
    UIViewController *viewController = [self tjr_getViewController];
    if (viewController && [viewController isKindOfClass:[TJRBaseTabBarController class]]) {
        return (TJRBaseTabBarController *)viewController;
    }
    return nil;
}

#pragma mark - 网络失败默认失败方法
- (void)httpBaseFalid:(NSError *)error {
    [self dismissProgress];
    [self showToast:@"获取数据失败，网络不给力!" inView:self.view];
}

- (void)httpBaseFalidWithLog:(NSError *)error {
    [self dismissProgress];
}

#pragma mark - 页面参数字典的所有方法

/**
 *	@brief	获取模块参数字典
 *
 *	@param  model   模块名
 *
 *	@return
 */
- (NSMutableDictionary *)getModelDictionary:(NSString *)model {
    return [[TJRCache shareTJRCache] getCacheValueForKey:model];
}

/**
 *	@brief	从模块参数字典里取出一个值
 *
 *	@param  model   模块名
 *	@param  key     所取值的Key
 *
 *	@return
 */
- (id)getValueFromModelDictionary:(NSString *)model forKey:(id)key {
    return [[TJRCache shareTJRCache] getValueFromModelDictionary:model forKey:key];
}

/**
 *	@brief	往一个模块参数字典里添加一个参数
 *
 *	@param  model   模块名
 *	@param  value   参数值
 *	@param  key     参数key
 */
- (void)putValueToParamDictionary:(NSString *)model value:(id)value forKey:(id)key {
    [[TJRCache shareTJRCache] putValueToParamDictionary:model value:value forKey:key];
}

/**
 *	@brief	为一个模块添加一个参数字典(省去设值的过程)
 *
 *	@param  model
 *	@param  dic
 */
- (void)putValueToParamDictionaryModel:(NSString *)model withDictionary:(NSDictionary *)dic {
    [[TJRCache shareTJRCache] putValueToParamDictionaryModel:model withDictionary:dic];
}

/**
 *	@brief	从一个模块参数字典里移除一个值
 *
 *	@param  model   模块名
 *	@param  key{    要移除的值的Key
 */
- (void)removeParamFromModelDictionary:(NSString *)model forKey:(id)key {
    [[TJRCache shareTJRCache] removeParamFromModelDictionary:model forKey:key];
}

/**
 *	@brief	移除一个模块字典
 *
 *	@param  model   模块名
 */
- (void)removeModelDictionaryFromParamDictionary:(NSString *)model {
    [[TJRCache shareTJRCache] removeCacheValueForKey:model];
}

#pragma mark - Toast

/**
 *	@brief	显示Toast
 *
 *	@param  text    显示文字
 *	@param  gravity     显示位置
 *	@param  duration    显示时间 (iToastDurationShort,iToastDurationLong,iToastDurationNormal)
 */
- (void)showToast:(NSString *)text gravity:(iToastGravity)gravity duration:(NSInteger)duration {
    if (!TTIsStringWithAnyText(text)) return;
    [[[[iToast makeText:text] setGravity:gravity] setDuration:duration] show:[self getRootController].isRotation ?[self getTJRAppDelegate].navLandscape.view:[self getRootController].navigationController.view];
}

/**
 *	@brief	显示Toast
 *	@param  text    显示文字
 */
- (void)showToast:(NSString *)text {
    if (!TTIsStringWithAnyText(text)) return;
    [[[[iToast makeText:text] setGravity:iToastGravityBottom] setDuration:1500] show:[self getRootController].isRotation ? self.view:[self getRootController].navigationController.view];
}

- (void)showToast:(NSString *)text inView:(UIView *)inView {
    if (!TTIsStringWithAnyText(text)) return;
    [[[[iToast makeText:text] setGravity:iToastGravityBottom] setDuration:1500] show:inView];
}

/**
 *	@brief	显示Toast
 *	@param  text    显示文字
 */
- (void)showToastCenter:(NSString *)text {
    if (!TTIsStringWithAnyText(text)) return;
    [[[[iToast makeText:text] setGravity:iToastGravityCenter] setDuration:1500] show:[self getRootController].isRotation ? self.view:[self getRootController].navigationController.view];
}

- (void)showToastCenter:(NSString *)text inView:(UIView *)inView {
    if (!TTIsStringWithAnyText(text)) return;
    [[[[iToast makeText:text] setGravity:iToastGravityCenter] setDuration:1500] show:inView];
}

/**
 *	@brief	显示Toast
 *	@param  text    显示文字
 */
- (void)showToastOnTop:(NSString *)text {
    if (!TTIsStringWithAnyText(text)) return;
    [[[[iToast makeText:text] setGravity:iToastGravityTop] setDuration:1500] show:[self getRootController].isRotation ? self.view:[self getRootController].navigationController.view];
}

- (void)showToastOnTop:(NSString *)text inView:(UIView *)inView {
    if (!TTIsStringWithAnyText(text)) return;
    [[[[iToast makeText:text] setGravity:iToastGravityTop] setDuration:1500] show:inView];
}

- (void)showLastRecordTextToast {
    [[[[iToast makeText:@"已经是最后一条记录了哦！"] setGravity:iToastGravityBottom] setDuration:1500] show:[self getRootController].isRotation ? self.view:[self getRootController].navigationController.view];
}

/**
 * *直接将后台信息传入，如果text存在，则输出后台的提示信息，如果不存在，则提示默认的数据错误
 */
- (void)showConnectionMsgToastCenter:(NSString *)text {
    if ((text != nil) && (text.length > 0) && ![text isEqualToString:@"null"] && ![text isEqualToString:@"(null)"]) {
        [self showToastCenter:text];
    } else {
        [self showToastCenter:@"数据错误"];
    }
}

- (void)showProgressHUDCompleteMessage:(NSString *)titleMessage detailsMessage:(NSString *)detailsMessage imageName:(NSString *)imageName {
    float statusBarHeight = CURRENT_DEVICE_VERSION >= 7.0 ? 20 : 0;
    MBProgressHUD *pHUD = [[[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight)] autorelease];
    
    pHUD.center = self.view.center;
    pHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
    [self.view addSubview:pHUD];
    pHUD.frame = CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight);
    pHUD.bounds = CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight);
    pHUD.backgroundRect = CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight);
    
    if ((detailsMessage.length > 0) || (titleMessage.length > 0)) {
        [pHUD show:YES];
        pHUD.labelText = titleMessage.length > 0 ? titleMessage : NULL;
        pHUD.detailsLabelText = detailsMessage.length > 0 ? detailsMessage : NULL;
        pHUD.mode = MBProgressHUDModeCustomView;
        [pHUD hide:YES afterDelay:2.0];
    } else {
        [pHUD hide:YES];
    }
}

#pragma mark - 等待圈圈

/**
 *	@brief	显示等待圈圈
 *
 *	@param  text    显示文字
 *  @param details
 */
- (void)showProgress:(NSString *)text detailsText:(NSString *)details {
    BOOL progressLoging = NO;
    MBProgressHUD *progressHUD = nil;
    UIView *view;
    TJRBaseViewController *viewController = nil;
    TJRBaseTabBarController *tabBarController = nil;
    [self getTJRViewController:&viewController tabBarController:&tabBarController];
    if (viewController) {
        progressLoging = viewController.progressLoging;
        progressHUD = viewController.progressHUD;
        view = viewController.view;
    } else if (tabBarController) {
        progressLoging = tabBarController.progressLoging;
        progressHUD = tabBarController.progressHUD;
        view = tabBarController.view;
    } else {
        return;
    }
    if (progressLoging) return;
    BOOL isRelease = NO;
    
    float statusBarHeight = 0;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        statusBarHeight = 20;
    }
    
    if (!progressHUD) {
        progressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight)];
        if (viewController) {
            viewController.progressHUD = progressHUD;
        } else {
            tabBarController.progressHUD = progressHUD;
        }
        progressHUD.center = view.center;
        [view addSubview:progressHUD];
        isRelease = YES;
    }
    progressHUD.frame = CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight);
    progressHUD.bounds = CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight);
    progressHUD.backgroundRect = CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight);

    progressHUD.mode = MBProgressHUDModeTJRView;

    progressHUD.labelText = text;
    progressHUD.detailsLabelText = details;
    [progressHUD show:YES];
    if (viewController) {
        viewController.progressLoging = YES;
    } else {
        tabBarController.progressLoging = YES;
    }
    
    if (viewController && viewController.welcomeView) {
        [view bringSubviewToFront:viewController.welcomeView];
    } else {
        [view bringSubviewToFront:progressHUD];
    }
    if (isRelease) {
        RELEASE(progressHUD);
    }
}

#pragma mark - 等待圈圈

/**
 *    @brief    显示等待圈圈
 *
 *    @param  text    显示文字
 *    @param  offsetY 默认是居中显示，offsetY为相对中间位置的偏移量
 *  @param details
 */
- (void) showProgress:(NSString *)text detailsText:(NSString *)details offsetY:(CGFloat)offsetY{
    BOOL progressLoging = NO;
    MBProgressHUD *progressHUD = nil;
    UIView *view;
    TJRBaseViewController *viewController = nil;
    TJRBaseTabBarController *tabBarController = nil;
    [self getTJRViewController:&viewController tabBarController:&tabBarController];
    if (viewController) {
        progressLoging = viewController.progressLoging;
        progressHUD = viewController.progressHUD;
        view = viewController.view;
    } else if (tabBarController) {
        progressLoging = tabBarController.progressLoging;
        progressHUD = tabBarController.progressHUD;
        view = tabBarController.view;
    } else {
        return;
    }
    if (progressLoging) return;
    BOOL isRelease = NO;
    
    float statusBarHeight = 0;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        statusBarHeight = 20;
    }
    
    if (!progressHUD) {
        progressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight)];
        if (viewController) {
            viewController.progressHUD = progressHUD;
        } else {
            tabBarController.progressHUD = progressHUD;
        }
        progressHUD.center = view.center;
        [view addSubview:progressHUD];
        isRelease = YES;
    }
    progressHUD.frame = CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight + 2 * offsetY);
    progressHUD.bounds = CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight + 2 * offsetY);
    progressHUD.backgroundRect = CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight + 2 * offsetY);
    
    progressHUD.mode = MBProgressHUDModeTJRView;
    
    progressHUD.labelText = text;
    progressHUD.detailsLabelText = details;
    [progressHUD show:YES];
    if (viewController) {
        viewController.progressLoging = YES;
    } else {
        tabBarController.progressLoging = YES;
    }
    
    if (viewController && viewController.welcomeView) {
        [view bringSubviewToFront:viewController.welcomeView];
    } else {
        [view bringSubviewToFront:progressHUD];
    }
    if (isRelease) {
        RELEASE(progressHUD);
    }
}


/**
 *	@brief	等待圈圈显示默认文字说明
 *	@return
 */
- (void)showProgressDefaultText {
    [self showProgress:TITLETEXT detailsText:DETAILSTEXT];
}

/**
 *    @brief    等待圈圈显示默认文字说明
 *    @param  offsetY 默认是居中显示，offsetY为相对中间位置的偏移量
 *    @return
 */
- (void)showProgressDefaultText:(CGFloat)offsetY{
    [self showProgress:TITLETEXT detailsText:DETAILSTEXT offsetY:offsetY];
}

#pragma mark - 显示菊花，覆盖范围
- (void)showProgressDefaultTextSetProgressRange:(ProgressRange)_pRange {
    BOOL progressLoging = NO;
    MBProgressHUD *progressHUD;
    UIView *view;
    TJRBaseViewController *baseViewController = [self getTJRBaseViewController];
    TJRBaseTabBarController *baseTabBarController = [self getTJRBaseTabBarController];
    if (baseViewController) {
        progressLoging = baseViewController.progressLoging;
        view = baseViewController.view;
        progressHUD = baseViewController.progressHUD;
    } else if (baseTabBarController) {
        progressLoging = baseTabBarController.progressLoging;
        view = baseTabBarController.view;
        progressHUD = baseTabBarController.progressHUD;
    } else {
        return;
    }
    if (progressLoging) return;
    
    float statusBarHeight = 0;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        statusBarHeight = 20;
    }
    BOOL isRelease = NO;
    if (!progressHUD) {
        progressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 2 * 44 - statusBarHeight)];
        if (baseViewController) {
            baseViewController.progressHUD = progressHUD;
        } else {
            baseTabBarController.progressHUD = progressHUD;
        }
        progressHUD.center = view.center;
        [view addSubview:progressHUD];
        isRelease = YES;
    }
    
    // 设置范围
    switch (_pRange) {
        case ProgressRangeFullScreen :
            progressHUD.frame = self.view.bounds;
            progressHUD.backgroundRect = self.view.bounds;
            break;
            
        case ProgressRangeMiddleAndBottom :
            progressHUD.frame = CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 44 - statusBarHeight);
            progressHUD.backgroundRect = CGRectMake(0, 44 + statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 44 - statusBarHeight);
            break;
            
        case ProgressRangeOnlyMiddle :
            break;
            
        case ProgressRangeTopAndMiddle :
            progressHUD.frame = CGRectMake(0, statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 44 - statusBarHeight);
            progressHUD.backgroundRect = CGRectMake(0, statusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - 44 - statusBarHeight);
            break;
            
        default :
            break;
    }

    progressHUD.mode = MBProgressHUDModeTJRView;

    progressHUD.labelText = TITLETEXT;
    progressHUD.detailsLabelText = DETAILSTEXT;
    [progressHUD show:YES];
    if (baseViewController) {
        baseViewController.progressLoging = YES;
    } else {
        baseTabBarController.progressLoging = YES;
    }
    if (baseViewController && baseViewController.welcomeView) {
        [view bringSubviewToFront:baseViewController.welcomeView];
    } else {
        [view bringSubviewToFront:progressHUD];
    }
    if (isRelease) {
        RELEASE(progressHUD);
    }
}

/**
 *	@brief	取消等待圈圈
 */
- (void)dismissProgress {
    BOOL progressLoging = NO;
    MBProgressHUD *progressHUD;
    TJRBaseViewController *baseViewController = [self getTJRBaseViewController];
    TJRBaseTabBarController *baseTabBarController = [self getTJRBaseTabBarController];
    if (baseViewController) {
        progressLoging = baseViewController.progressLoging;
        progressHUD = baseViewController.progressHUD;
        baseViewController.progressLoging = NO;
    } else if (baseTabBarController) {
        progressLoging = baseTabBarController.progressLoging;
        progressHUD = baseTabBarController.progressHUD;
        baseTabBarController.progressLoging = NO;
    } else {
        return;
    }
    if (progressLoging && progressHUD) {
        [progressHUD hide:YES];
        [((UIImageView*)progressHUD.customView) stopAnimating];
    }
}

- (MBProgressHUD *)getProgressHUD {
    TJRBaseViewController *baseViewController = [self getTJRBaseViewController];
    TJRBaseTabBarController *baseTabBarController = [self getTJRBaseTabBarController];
    if (baseViewController) {
        return baseViewController.progressHUD;
    } else if (baseTabBarController) {
        return baseTabBarController.progressHUD;
    } else {
        return nil;
    }
}

#pragma mark - 页面跳转和返回方法

/**
 *	@brief	页面跳转(前进)
 *
 *	@param  toViewController    目标页面名称字符串
 */
- (void)pageToViewControllerForName:(NSString *)toViewController {
    Class class = NSClassFromString(toViewController);
    
    if (class) {
        UIViewController *newPageController = [[[class alloc] initWithNibName:toViewController bundle:nil] autorelease];
        
        if ([newPageController isKindOfClass:[UIViewController class]] == YES) {
            [[self getTJRAppDelegate].navigation pushViewController:newPageController animated:YES];
        }
    }
}

- (void)pageToViewControllerForName:(NSString *)toViewController animated:(BOOL)animated {
    Class class = NSClassFromString(toViewController);
    
    if (class) {
        UIViewController *newPageController = [[[class alloc] initWithNibName:toViewController bundle:nil] autorelease];
        
        if ([newPageController isKindOfClass:[UIViewController class]] == YES) {
            [[self getTJRAppDelegate].navigation pushViewController:newPageController animated:animated];
        }
    }
}

- (void)pageToViewControllerForNameAndPopCurrentController:(NSString *)toViewController;
{
    Class class = NSClassFromString(toViewController);
    if (class) {
        [self clearTTHttpDelegate];
        NSArray *viewControlles = self.navigationController.viewControllers;
        NSMutableArray *newViewControlles = [NSMutableArray array];
        if([viewControlles count] > 0) {
            for (int i=0; i < [viewControlles count] - 1; i++) {
                [newViewControlles addObject:[viewControlles objectAtIndex:i]];
                
            }
        }
        UIViewController *newPageController = [[[class alloc] initWithNibName:toViewController bundle:nil] autorelease];
        [newViewControlles addObject:newPageController];
        [self.navigationController setViewControllers:newViewControlles animated:YES];
    }

}


/**
 *    @brief    返回上一个页面
 */
- (void)goBack {
    [self goBackWithAnimated:YES];
}

/**
 *    @brief    返回上一个页面
 */
- (void)goBackWithAnimated:(BOOL)animated {
    [self clearTTHttpDelegate];
    TJRAppDelegate *application = [self getTJRAppDelegate];
    UIViewController *top = [self getTJRAppDelegate].navigation.topViewController;
    if (top && top != self) return;
    [application.navigation popViewControllerAnimated:animated];
}

/**
 *    @brief    返回到栈里的某个页面
 *
 *    @param  viewController  目标页面名称
 *    @param  animated    是否要动画
 */
- (void)goBackToViewControllerForName:(NSString *)viewController animated:(BOOL)animated {
    if (!TTIsStringWithAnyText(viewController)) return;
    
    int index = [self viewControllerExistIndex:viewController];
    
    if (index < 0) return;
    
    [self clearTTHttpDelegate];
    TJRAppDelegate *application = [self getTJRAppDelegate];
    UIViewController *backViewController = [application.navigation.viewControllers objectAtIndex:index];
    [application.navigation popToViewController:backViewController animated:animated];
}

/**
 *    @brief    页面跳转,不区分push或pop,由系统区分
 *
 *    @param  toViewController    页面名
 */
- (void)pageToOrBackWithName:(NSString *)toViewController {
    if (!TTIsStringWithAnyText(toViewController)) return;
    
    if ([self viewControllerExistIndex:toViewController] >= 0) {
        [self goBackToViewControllerForName:toViewController animated:YES];
    } else {
        [self pageToViewControllerForName:toViewController];
    }
}

- (void)pageToOrBackWithName:(NSString *)toViewController animated:(BOOL)animated {
    if (!toViewController) return;
    
    if ([self viewControllerExistIndex:toViewController] >= 0) {
        [self goBackToViewControllerForName:toViewController animated:animated];
    } else {
        [self pageToViewControllerForName:toViewController animated:animated];
    }
}

/**
 *    @brief    返回前前个页面
 */
- (void)goBackToPriorPriorView {
    [self goBackToPriorPriorViewWithAnimated:YES];
}

/**
 *    @brief    返回前前个页面
 */
- (void)goBackToPriorPriorViewWithAnimated:(BOOL)animated {
    TJRAppDelegate *application = [self getTJRAppDelegate];
    NSArray *array = application.navigation.viewControllers;
    
    // 存在前前个页面
    if ([array count] > 2) {
        [self clearTTHttpDelegate];
        UIViewController *backViewController = [array objectAtIndex:[array count] - 3];
        [application.navigation popToViewController:backViewController animated:animated];
    }
}

- (void)goBackToPriorPriorViewWithAnimated:(BOOL)animated navigation:(UINavigationController *)navigation {
    NSArray *array = navigation.viewControllers;
    
    // 存在前前个页面
    if ([array count] > 2) {
        [self clearTTHttpDelegate];
        UIViewController *backViewController = [array objectAtIndex:[array count] - 3];
        [navigation popToViewController:backViewController animated:animated];
    }
}

/**
 *    @brief    返回前N个页面
 */
- (void)goBackToViewNumView:(NSInteger)viewNum {
    [self goBackToViewNumViewWithAnimated:viewNum animated:YES];
}

- (void)goBackToViewNumViewWithAnimated:(NSInteger)viewNum animated:(BOOL)animated {
    TJRAppDelegate *application = [self getTJRAppDelegate];
    NSArray *array = application.navigation.viewControllers;
    
    // 存在前前个页面
    if ([array count] > viewNum) {
        [self clearTTHttpDelegate];
        UIViewController *backViewController = [array objectAtIndex:[array count] - (viewNum + 1)];
        [application.navigation popToViewController:backViewController animated:animated];
    }
}

#pragma mark - Present模式，生成新的Navigation

/**
 *    @brief    页面跳转(自下而上出现)
 *    @param  toViewController    目标页面名称字符串
 */
- (void)pagePresentModalViewControllerForName:(NSString *)toViewController{
    
    Class class = NSClassFromString(toViewController);
    
    if (class) {
        BOOL init = NO;
        
        if ([self getTJRAppDelegate].navPresent == nil) {
            [self getTJRAppDelegate].navPresent = [[YLNavigationController alloc] initWithRootViewController:[[[UIViewController alloc] init] autorelease]];
            [self getTJRAppDelegate].navPresent.navigationBarHidden = YES;
            [self getTJRAppDelegate].navPresent.interactivePopGestureRecognizer.enabled = YES;
        }
        
        if ([self getTJRAppDelegate].navPresent.viewControllers.count == 1) {
            //只包含一个底层Controller
            [[self getTJRAppDelegate].navigation presentViewController:[self getTJRAppDelegate].navPresent animated:YES completion:nil];
            init = YES;
        }
        
        UIViewController *newPageController = [[[class alloc] initWithNibName:toViewController bundle:nil] autorelease];
        
        [[self getTJRAppDelegate].navPresent pushViewController:newPageController animated:!init];
    }
}

/**
 *    @brief    返回上一个页面(自上而下消失)
 */
- (void)dismissModalFromParentViewController {
    [self clearTTHttpDelegate];

    if ([self getTJRAppDelegate].navPresent.viewControllers.count <= 2) {
        [[self getTJRAppDelegate].navigation dismissViewControllerAnimated:YES completion:nil];
        [[self getTJRAppDelegate].navPresent performSelector:@selector(popToRootViewControllerAnimated:) withObject:nil afterDelay:0.5];
    } else {
        UIViewController *top = [self getTJRAppDelegate].navPresent.topViewController;
        if (top && top != self) return;
        [[self getTJRAppDelegate].navPresent popViewControllerAnimated:YES];
    }
}


#pragma mark - 横屏模式，生成新的Navigation
/**
 *    @brief   横屏页面跳转
 *
 *    @param  toViewController    目标页面名称字符串
 */
- (void)pagePresentModalLandscapeViewControllerForName:(NSString *)toViewController {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        Class class = NSClassFromString(toViewController);
        
        if (class) {
            BOOL init = NO;

            if ([self getRootController].isRotation == NO) {
                if ([self getTJRAppDelegate].navLandscape == nil) {
                    [self getTJRAppDelegate].navLandscape = [[TJRNavigationController alloc] initWithRootViewController:[[[UIViewController alloc] init] autorelease]];//指定TJRNavigationController为横屏方式
                }
                init = YES;
                [self getTJRAppDelegate].navLandscape.modalPresentationStyle = UIModalPresentationFullScreen;
                [[self getTJRAppDelegate].navigation presentViewController:[self getTJRAppDelegate].navLandscape animated:YES completion:nil];
                
            }
            
            UIViewController *newPageController = [[[class alloc] initWithNibName:toViewController bundle:nil] autorelease];
            
            int index = -1;
            
            for (int i = 0; i < [self getTJRAppDelegate].navLandscape.viewControllers.count; i++) {
                TJRBaseViewController *vc = [[self getTJRAppDelegate].navLandscape.viewControllers objectAtIndex:i];
                
                if (vc && [NSStringFromClass ([vc class]) isEqualToString:toViewController]) index = i;
            }
            
            if (index > 0) {
                [self clearTTHttpDelegate];
                UIViewController *backViewController = [[self getTJRAppDelegate].navLandscape.viewControllers objectAtIndex:index];
                [[self getTJRAppDelegate].navLandscape popToViewController:backViewController animated:YES];
            } else {
                [[self getTJRAppDelegate].navLandscape pushViewController:newPageController animated:!init];
            }
        }
    } else {
        [self pageToOrBackWithName:toViewController];
    }
}


- (void)dismissModalLandscapeViewController {
    [self clearTTHttpDelegate];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        if ([self getTJRAppDelegate].navLandscape.viewControllers.count <= 2) {
            [[self getTJRAppDelegate].navigation dismissViewControllerAnimated:YES completion:nil];
            [[self getTJRAppDelegate].navLandscape performSelector:@selector(popToRootViewControllerAnimated:) withObject:nil afterDelay:0.5];
        } else {
            UIViewController *top = [self getTJRAppDelegate].navLandscape.topViewController;
            if (top && top != self) return;
            [[self getTJRAppDelegate].navLandscape popViewControllerAnimated:YES];
        }
    } else {
        [self goBack];
    }
}

- (void)dismissModalLandscapeViewControllerToRootViewController {
    [self clearTTHttpDelegate];
    [self rotationNavigationControllerToNormal];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        [[self getTJRAppDelegate].navLandscape popToRootViewControllerAnimated:false];
        [[self getTJRAppDelegate].navigation dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - 获取清空请求回调
- (void)clearTTHttpDelegate {
    TJRBaseViewController *viewController = [self getTJRBaseViewController];
    TJRBaseTabBarController *tabBarController = [self getTJRBaseTabBarController];
    if (viewController) {
        [viewController clearTTHttpDelegate];
    } else if (tabBarController) {
        [tabBarController clearTTHttpDelegate];
    }
}


#pragma mark - 获取TJRAppDelegate

/**
 *	@brief	获取TJRAppDelegate
 *
 *	@return
 */
- (TJRAppDelegate *)getTJRAppDelegate {
    return (TJRAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - 获取RootController

/**
 *	@brief	获取RootController
 *
 *	@return
 */
- (RootController *)getRootController {
    return [self getTJRAppDelegate].rootController;
}

#pragma mark - ViewController在navigation里所处位置

/**
 *	@brief	ViewController在navigation里所处位置
 *
 *	@param  viewController  要查询的ViewController
 *
 *	@return	位置(-1表示不存在)
 */
- (int)viewControllerExistIndex:(NSString *)viewController {
    int index = -1;
    
    for (TJRBaseViewController *vc in [self getTJRAppDelegate].navigation.viewControllers) {
        index++;
        
        if (vc && [NSStringFromClass ([vc class]) isEqualToString:viewController]) return index;
    }
    
    return -1;
}

/**
 *	@brief	从栈里面移除掉一个ViewController(暂时没用)
 *
 *	@param  viewController  要移除的ViewController
 */
- (void)removeViewControllerFromNavigation:(TJRBaseViewController *)viewController {
    NSString *removeViewName = NSStringFromClass([viewController class]);
    int index = [self viewControllerExistIndex:removeViewName];
    
    if (index > -1) {
        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray:[self getTJRAppDelegate].navigation.viewControllers];
        [navigationArray removeObjectAtIndex:index];
        [self getTJRAppDelegate].navigation.viewControllers = navigationArray;
        [navigationArray release];
    }
}

#pragma mark - 通过名称获取那个ViewController

- (UIViewController *)getViewControllerWithName:(NSString *)name {
    if (!TTIsStringWithAnyText(name)) return nil;
    
    int index = [self viewControllerExistIndex:name];
    TJRAppDelegate *application = [self getTJRAppDelegate];
    
    if ((index >= 0) && (index < application.navigation.viewControllers.count)) {
        return [application.navigation.viewControllers objectAtIndex:index];
    }
    return nil;
}


#pragma mark - 屏幕是否有强制旋转
- (BOOL)isRotation {
    return [self getRootController].isRotation;
}

#pragma mark - 旋转NavigationController90度

- (CGRect)phoneRectScreen {
    return [[UIScreen mainScreen] bounds];
}

/**
 *   note:强制旋转navigationController，不符合苹果交互设计的要求。
 *      (必须是modal出来的view才可以变换设备方向。navigation controller Pop Push的view是苹果设计HIG的原则.)
 *      一直是在push和pop，rootViewController始终NavigationController。
 *      不旋转设备，不会引起auto rotate动作，
 *      ios7采用取巧的方式.
 **/
- (void)rotationNavigationControllerForNinety {
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        //ios7下进行操作
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
        [self getTJRAppDelegate].navigation.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        [self getTJRAppDelegate].navigation.view.bounds = CGRectMake(0, 0, [self phoneRectScreen].size.height, [self phoneRectScreen].size.width);
        [self getTJRAppDelegate].navigation.view.frame = CGRectMake(0, 0, [self phoneRectScreen].size.width, [self phoneRectScreen].size.height);
    }
    [self getRootController].isRotation = YES;
}

#pragma mark - 旋转NavigationController回到正常
- (void)rotationNavigationControllerToNormal {
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        //ios7下进行操作
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        [self getTJRAppDelegate].navigation.view.transform = CGAffineTransformIdentity;
        [self getTJRAppDelegate].navigation.view.bounds = CGRectMake(0, 0, [self phoneRectScreen].size.width, [self phoneRectScreen].size.height);
        [self getTJRAppDelegate].navigation.view.frame = CGRectMake(0, 0, [self phoneRectScreen].size.width, [self phoneRectScreen].size.height);
    }
    [self getRootController].isRotation = NO;
}


#pragma mark - sleep Application
- (void)sleepApplication {
    NSDate *OneHourAway = [NSDate dateWithTimeIntervalSinceNow:3];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    [self getRootController].sleepTime = [[dateFormatter stringFromDate:OneHourAway] longLongValue];
    [dateFormatter release];
}

#pragma mark - wakeUp Application
- (void)wakeUpToHomePage {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    long long nowTime = [[dateFormatter stringFromDate:date] longLongValue];
    [dateFormatter release];
    
    if (([self getRootController].sleepTime != 0) && ((nowTime - [self getRootController].sleepTime) >= 0)) {
        [self getRootController].sleepTime = 0;
        [self goBackToViewControllerForName:@"HomeViewController" animated:NO];
    } else {
        [self getRootController].sleepTime = 0;
    }
}

@end
