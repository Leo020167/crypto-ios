//
//  TJRBaseViewController.h
//  tjr-taojinroad
//
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRAppDelegate.h"
#import "NetWorkManage.h"
#import "UIViewController+PublicMethods.h"

extern NSString *HomeSubscribeSucessfulKey;//用来通知首页是否订阅成功

@interface TJRBaseViewController : QMUICommonViewController <UIGestureRecognizerDelegate>{
	NSMutableDictionary *ttDelegateDictionary;
	CGRect phoneRectScreen;
	BOOL isSecondNetRequest;// 是否是第二次发送网络
    BOOL isBacking;
}
@property (nonatomic, assign) BOOL canDragBack;						// 是否可能使用手势返回
@property (nonatomic, copy) NSString *titleViewBackgroundImageName;	// title如果背景是图片
@property (nonatomic, assign) BOOL progressLoging;
@property (nonatomic, retain) MBProgressHUD *progressHUD;
@property (nonatomic, retain) UIView *welcomeView;

- (int)keyboardJumpValue;
- (void)putKeyboardJumpValue:(int)isJump;

- (void)refreshSelfData;

- (void)clearTTHttpDelegate;

/**
 *  @brief  判断用户是否登陆
 *
 *  @return return description
 */
- (BOOL)userIsLogin;

#pragma mark - tjrDelegate
- (void)recordHttpRequest:(NSString *)cacheKey httpRequest:(id)httpRequest;
- (void)removeHttpRequestFromDictionary:(NSString *)cacheKey;

/**
 *	@brief	显示welcome页面
 */
- (void)showWelcomeImageWithType:(welcomeImageType)imageType;
- (void)removeWelcomeViewn;


#pragma mark - 公用提示后台错误信息
/**
	以showProgressHUD显示Json里的msg
	@param json
 */
- (BOOL)showProgressHUDWithMsg:(NSDictionary *)json;

/**
 *  检查网络数据提示资金是否足够
 *
 *  @param json json description
 *
 *  @return 返回true为可用资金足够,false为资金不足,请充值
 */
- (BOOL)checkCashEnough:(NSDictionary *)json;


/**
 @param json 传入后端返回的json
 @param defaultErrorMsg 后端不返回错误信息时使用的默认显示信息(根据具体情况提示充值)
 */
- (void)showErrorToastCenter:(NSDictionary *)json defaultErrorMsg:(NSString *)defaultErrorMsg;

- (void)gestureWillPopToViewControllerForName:(NSString *)viewController didPop:(void (^)(void))didPop;
- (void)gestureWillPopToViewControllerForIndex:(int)index didPop:(void (^)(void))didPop;
- (void)gestureWillPopToViewControllerForIndex:(int)index;
- (void (^)(void))gesturePopCallback;
- (void)removeGesturePopCallback;

/** 默认请求网络失败回调*/
- (void)reqHttpRequestFailed:(NSDictionary *)json;

/**
 *  @brief  判断当前ViewController是否是最顶显示
 *
 *  @return return description
 */
- (BOOL)isvisible;

/**
 * @brief 判断后端返回的json是否成功
 */
- (BOOL)checkJsonIsSuccess:(NSDictionary *)json;


/**
 * @brief 判断是否需要设置交易密码,并作出处理逻辑
 */
- (BOOL)checkIsNeedSetTradePassword:(NSDictionary *)json;

/**
 * @brief 判断是否需要输入交易密码,不进行逻辑处理
 */
- (BOOL)checkIsNeedTradePassword:(NSDictionary *)json;


/**
 * @brief 是否资金不足
 * @param json:传入的json
 */

- (BOOL)checkIsNotEnoughCash:(NSDictionary *)json;

/**
 * @brief 资金不足时带参数跳转页面
 * @param json:传入的json
 * @param pageName:当资金不足需要跳去的页面
 * @param pageParams:跳去某个页面所需要的字典参数,key值为传过去的key值(仅限字符串)，value为带过去的值,
 */
- (void)notEnoughMoneyJson:(NSDictionary *)json toPageName:(NSString *)pageName pageParams:(NSDictionary *)pageParams;

@end

