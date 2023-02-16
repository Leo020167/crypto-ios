//
//  TJRBaseViewController.m
//  tjr-taojinroad
//
//  Created by taojinroad on 12-8-24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "TJRBaseTitleView.h"

#import "TJRCache.h"
#import <objc/runtime.h>


#import "TJRIntroductionController.h"

NSString *HomeSubscribeSucessfulKey = @"HomeSubscribeSucessfulKey";
NSString *const ISKEYBOARDJUMP = @"isKeyboardJump";


#define gesturePopupViewPopedBlock @"gesturePopupViewPopedBlock"

@interface TJRBaseViewController(){

}
@end

@implementation TJRBaseViewController

- (id)init {
    self  = [super init];
    if (self) {
        [self tjr_setViewController:nil];
        [self tjr_setViewController:self];
        CGSize size =  [[UIApplication sharedApplication] statusBarFrame].size;
        CGRect rect = self.view.frame;
        rect.origin.y += size.height;
        rect.size.height -= size.height;
        self.view.frame = rect;
        NSLog(@"\n---------------  %@", NSStringFromClass(self.class));
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self tjr_setViewController:nil];
        [self tjr_setViewController:self];
        CGSize size =  [[UIApplication sharedApplication] statusBarFrame].size;
        CGRect rect = self.view.frame;
        rect.origin.y += size.height;
        rect.size.height -= size.height;
        self.view.frame = rect;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self tjr_setViewController:nil];
        [self tjr_setViewController:self];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.canDragBack = YES;

    if (!ttDelegateDictionary) ttDelegateDictionary = [[NSMutableDictionary alloc] init];
    
	phoneRectScreen = [[UIScreen mainScreen] bounds];

	if (CURRENT_DEVICE_VERSION >= 7.0) [self setNeedsStatusBarAppearanceUpdate];

	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) self.edgesForExtendedLayout = UIRectEdgeNone;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //设置重启UIView动画
        dispatch_async(dispatch_get_main_queue(),^{[UIView setAnimationsEnabled:YES];});
    });
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	// 腾讯mta页面统计
    
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	// 腾讯mta页面统计
    
    [self resignFirstResponder];
}

/**
 *  当要重新刷新当前页面的数据时,重写这个方法
 */
- (void)refreshSelfData {}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if (self.navigationController.viewControllers.count == 1) {		// 关闭主界面的右滑返回
		return NO;
	} else {
		return YES;
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

/**
 *  @brief  判断用户是否登陆
 *
 *  @return return description
 */ 
- (BOOL)userIsLogin {
    TJRUser *user = [self getRootController].user;
    return (user && TTIsStringWithAnyText(user.userId) && [user.userId integerValue] > 0);
}

#pragma mark - 网络记录

/**
 *	@brief	保存网络里的TTBaseHttpDelegate
 *
 *	@param  cacheKey
 *	@param  tjrDelegate
 */
- (void)recordHttpRequest:(NSString *)cacheKey httpRequest:(id)httpRequest {
	if (!TTIsStringWithAnyText(cacheKey)) return;

	[ttDelegateDictionary setObject:httpRequest forKey:cacheKey];
}

/**
 *	@brief	移除一个TTBaseHttpDelegate
 *
 *	@param  cacheKey
 */
- (void)removeHttpRequestFromDictionary:(NSString *)cacheKey {
	if (!TTIsStringWithAnyText(cacheKey)) return;

	[ttDelegateDictionary removeObjectForKey:cacheKey];
}

#pragma mark - dealloc
- (void)dealloc {
    objc_removeAssociatedObjects(self);
    
	RELEASE(_titleViewBackgroundImageName);
	RELEASE(_welcomeView);
    [self clearTTHttpDelegate];
    [ttDelegateDictionary removeAllObjects];
	TT_RELEASE_SAFELY(ttDelegateDictionary);
    RELEASE(_progressHUD);
    [self tjr_setViewController:nil];
	[super dealloc];
}

/**
 *	@brief	清除当前页面Http里的delegate
 */
- (void)clearTTHttpDelegate {

	for (TTBaseHttpDelegate *tt in [ttDelegateDictionary objectEnumerator]) {
        [tt clean];
	}
}


#pragma mark - 父类控制转动
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
	return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - 显示welcome页面
- (void)showWelcomeImageWithType:(welcomeImageType)imageType {
	NSString *imageName;

	switch (imageType) {
    
		case WelcomeImageType_Grapevine:
			imageName = @"Grapevine_welcome";
			break;

		case WelcomeImageType_Helppick:
			imageName = @"Helppick_welcome";
			break;

		case WelcomeImageType_Kandapan:
			imageName = @"Kandapan_welcome";
			break;

		case WelcomeImageType_Stockpk:
			imageName = @"Stockpk_welcome";
			break;

		case WelcomeImageType_StockTeamPK:
			imageName = @"StockTeamPK_welcome";
			break;

		case WelcomeImageType_StockTalk:
			imageName = @"StockTalk_welcome";
			break;
	}

	[self createWelcomeViewWithImageName:imageName withType:imageType];
}

#pragma mark - 生成welcome页面
- (void)createWelcomeViewWithImageName:(NSString *)imageName withType:(welcomeImageType)imageType {

    _welcomeView = [[UIView alloc] init];
    [self.view addSubview:_welcomeView];
    _welcomeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view bringSubviewToFront:_welcomeView];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_welcomeView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual toItem:self.view
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_welcomeView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual toItem:self.view
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_welcomeView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual toItem:self.view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_welcomeView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:self.view
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
//    [lineView setNeedsUpdateConstraints];
	_welcomeView.alpha = 1;
//	frame.origin = CGPointZero;
    NSString *welecomeName = [NSString stringWithFormat:@"%@%@", imageName, (ISHD ? @"@2x":@"")];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:welecomeName ofType:@"jpg"]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_welcomeView addSubview:imageView];
    [_welcomeView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual toItem:_welcomeView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1 constant:0]];
    [_welcomeView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual toItem:_welcomeView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1 constant:0]];
    [_welcomeView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:_welcomeView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1 constant:0]];
    [_welcomeView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual toItem:_welcomeView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:0]];
    
    
//    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
//	imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:welecomeName ofType:@"jpg"]];
	RELEASE(imageView);
    
	UIImageView *indicatorImageView = [[UIImageView alloc] init];
    indicatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_welcomeView addSubview:indicatorImageView];
    [_welcomeView bringSubviewToFront:indicatorImageView];
    [_welcomeView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorImageView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual toItem:_welcomeView
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1 constant:0]];
    [_welcomeView addConstraint:[NSLayoutConstraint constraintWithItem:_welcomeView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual toItem:indicatorImageView
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1 constant:50]];
    [indicatorImageView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorImageView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1 constant:42]];
    [indicatorImageView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorImageView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1 constant:14]];
    UIImage *first = [UIImage imageNamed:@"welcome_animation_first_frame"];
    UIImage *second = [UIImage imageNamed:@"welcome_animation_second_frame"];
    UIImage *third = [UIImage imageNamed:@"welcome_animation_third_frame"];
    indicatorImageView.animationImages = @[first, second, third];
    indicatorImageView.animationDuration = 3.0;
    indicatorImageView.animationRepeatCount = 0;
	[indicatorImageView startAnimating];
	RELEASE(indicatorImageView);
	[self performSelector:@selector(removeWelcomeViewAnimations) withObject:nil afterDelay:2];
}

#pragma mark - 移除welcome页面
- (void)removeWelcomeViewAnimations {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	_welcomeView.alpha = 0;
	[UIView commitAnimations];
	[self performSelector:@selector(removeWelcomeViewn) withObject:nil afterDelay:1.1];
}

- (void)removeWelcomeViewn {
	[_welcomeView removeFromSuperview];
	RELEASE(_welcomeView);
}

#pragma mark - 键盘跳转
/**
 *	@brief	进入到当前页面的过程中是否有使用键盘跳转
 *
 *	@return
 */
- (int)keyboardJumpValue {
    return [[[TJRCache shareTJRCache] getCacheValueForKey:ISKEYBOARDJUMP] intValue];
}

/**
 *	@brief	设置跳转过程中是否有用键盘跳转
 *
 *	@param  jumpIndex 跳转类型 (0代表没用键盘跳转, 1代表用键盘跳转,2代表用键盘到板块排名,
 *                              3代表跳转到个股,4代表除板块排名之外的其他快捷方式跳转,5代表用排行榜里下面的按钮快捷跳)
 */
- (void)putKeyboardJumpValue:(int)jumpIndex {
    [[TJRCache shareTJRCache] putCacheValue:[NSString stringWithFormat:@"%d", jumpIndex] forKey:ISKEYBOARDJUMP];
}

#pragma mark - 设置返回指定的页面
/**
 *  当返回页面大于1时，设置返回指定的页面
 *
 *  @param viewController 指定的页面, didPop
 *  @param didPop 当返回完成后的代码块
 *
 *  @return
 */
- (void)gestureWillPopToViewControllerForName:(NSString *)viewController didPop:(void (^)(void))didPop {
    if (!viewController) return;
    
    int index = [self viewControllerExistIndex:viewController];
    
    if (index < 0) return;
    
    TJRAppDelegate *application = [self getTJRAppDelegate];
    if ([application.navigation isKindOfClass:[TJRRootNavigationController class]]) {
        ((TJRRootNavigationController*)application.navigation).dragBackIndex = index;
    }
    
    [self setGesturePopCallback:didPop];
}


/**
 *  当返回页面大于1时，设置返回的页面
 *
 *  @param index 0为不操作, 1为返回上一页，2为返回上两页，等等
 *
 *  @return
 */
- (void)gestureWillPopToViewControllerForIndex:(int)index{
    
    TJRAppDelegate *application = [self getTJRAppDelegate];
    
    int i = (int)application.navigation.viewControllers.count - 1 - index;
    
    if ([application.navigation isKindOfClass:[TJRRootNavigationController class]]) {
        ((TJRRootNavigationController*)application.navigation).dragBackIndex = i;
    }
}

- (void)gestureWillPopToViewControllerForIndex:(int)index didPop:(void (^)(void))didPop {
    
    TJRAppDelegate *application = [self getTJRAppDelegate];
    
    int i = (int)application.navigation.viewControllers.count - 1 - index;
    
    if ([application.navigation isKindOfClass:[TJRRootNavigationController class]]) {
        ((TJRRootNavigationController*)application.navigation).dragBackIndex = i;
    }
    
    [self setGesturePopCallback:didPop];
}

- (void (^)(void))gesturePopCallback {
    return objc_getAssociatedObject(self, gesturePopupViewPopedBlock);
}

- (void)setGesturePopCallback:(void (^)(void))gesturePopCallback {
    objc_setAssociatedObject(self, gesturePopupViewPopedBlock, gesturePopCallback, OBJC_ASSOCIATION_COPY);
}

- (void)removeGesturePopCallback{
    objc_setAssociatedObject(self, gesturePopupViewPopedBlock, nil, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - 公用提示后台错误信息
/**
 *  @brief  以showProgressHUD显示Json里的msg
 *
 *  @param json
 *
 *  @return true代表正常,false代表有要显示提示
 */ 
- (BOOL)showProgressHUDWithMsg:(NSDictionary *)json {
    if (json) {
        BOOL success = [json[@"success"] boolValue];
        NSString *msg = json[@"msg"];
        if (TTIsStringWithAnyText(msg) && !success) {
            [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:msg imageName:HUD_ERROR];
        }
        return success;
    }
    return false;
}

/**
 *  检查网络数据提示资金是否足够
 *
 *  @param json json description
 *
 *  @return 返回true为可用资金足够,false为资金不足,请充值
 */
- (BOOL)checkCashEnough:(NSDictionary *)json {
    if (json) {
        BOOL success = [json[@"success"] boolValue];
        if (!success && [json[@"code"] integerValue] == 40010) {
            return false;
        }
        return true;
    }
    return true;
}


/**
 @param json 传入后端返回的json
 @param defaultErrorMsg 后端不返回错误信息时使用的默认显示信息(根据具体情况提示充值)
*/
- (void)showErrorToastCenter:(NSDictionary *)json defaultErrorMsg:(NSString *)defaultErrorMsg {
    NSString *errMsg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
    if(errMsg.length == 0 || errMsg == nil || [errMsg isEqualToString:@"null"] || [errMsg isEqualToString:@"(null)"]){
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:defaultErrorMsg imageName:HUD_ERROR];
    } else{
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:errMsg imageName:HUD_ERROR];
    }
}

/** 默认请求网络失败回调*/
- (void)reqHttpRequestFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
}

/**
 * @brief 判断后端返回的json是否成功
 */
- (BOOL)checkJsonIsSuccess:(NSDictionary *)json
{
    BOOL success = [[json objectForKey:@"success"] boolValue];
    return success;
}


/**
 * @brief 判断是否需要设置交易密码,并作出处理逻辑
 */
- (BOOL)checkIsNeedSetTradePassword:(NSDictionary *)json
{
    NSString* code = [NSString stringWithFormat:@"%@",[json objectForKey:@"code"]];
    if([code isEqualToString:@"40031"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:@"该操作需要验证交易密码，你还没设置交易密码，是否现在设置交易密码？" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"设置") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self pageToViewControllerForName:@"PayPasswordController"];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        return YES;
    }
    return NO;
}

/**
 * @brief 判断是否需要输入交易密码,不进行逻辑处理
 */
- (BOOL)checkIsNeedTradePassword:(NSDictionary *)json
{
    NSString* code = [NSString stringWithFormat:@"%@",[json objectForKey:@"code"]];
    if ([code isEqualToString:@"40030"]) {
        return YES;
    }
    return NO;
}



/**
 * @brief 是否资金不足
 * @param json:传入的json
 */

- (BOOL)checkIsNotEnoughCash:(NSDictionary *)json
{
    NSString *errorCode = [NSString stringWithFormat:@"%@",[json objectForKey:@"code"]];
    if([errorCode isEqualToString:@"40080"]){           //现金不足，弹出提示框
        return YES;
    }
    return NO;
}

/**
 * @brief 是否资金不足
 * @param json:传入的json
 * @param pageName:当资金不足需要跳去的页面
 * @param pageParams:跳去某个页面所需要的字典参数,key值为传过去的key值(仅限字符串)，value为带过去的值,
 */
- (void)notEnoughMoneyJson:(NSDictionary *)json toPageName:(NSString *)pageName pageParams:(NSDictionary *)pageParams
{
    NSString *message = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if(pageParams != nil){
            NSArray *array = [pageParams allKeys];
            for(NSString *key in array){
                [self putValueToParamDictionary:FundExchangeDic value:[pageParams objectForKey:key] forKey:key];
            }
        }
        [self pageToViewControllerForName:pageName];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


/**
 *  @brief  判断当前ViewController是否是最顶显示
 *
 *  @return return description
 */ 
- (BOOL)isvisible {
    return [self getRootController].navigationController.topViewController == self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

