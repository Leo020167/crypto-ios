//
//  UIViewController+PublicMethods.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/3/20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJRDefineManage.h"
#import "TJRUser.h"
#import "TJRAppDelegate.h"
#import "RootController.h"
#import "iToast.h"
#import "MBProgressHUD.h"


@class TJRBaseViewController;

extern NSString *const RegisterAccountDict;		    // 注册账号

extern NSString *const SettingDict;		            // 个人设置d字典

extern NSString *const MyHomeDict;					// 我的主页

extern NSString *const ChatDict;					// 私聊

extern NSString *const LoginDict;                   // 登陆

extern NSString *const FriendHomeDict;              // 个人主页

extern NSString *const FeedbackDict;				// 意见反馈

extern NSString *const SearchDict;                  // 搜索字典

extern NSString *const AppPayDict;                  // 支付字典

extern NSString *const TJRWebViewDict;              // 网页跳转字典

extern NSString *const PushDict;                    // 推送字典

extern NSString *const ShareDict;                   // 分享字典

extern NSString *const WebTencentOauthDict;         // 腾讯QQ登录分享字典

extern NSString *const ArticleDict;                 // 文章字典

extern NSString *const PersonalDict;                // 个人信息字典

extern NSString *const CircleDict;                  // 圈子字典

extern NSString *const WalletDict;                  //钱包字典

extern NSString *const FundExchangeDic;             //资金交易字典

extern NSString *const CoinTradeDic;                //币种交易字典

extern NSString *const FollowOrderDict;             //跟单字典

extern NSString *const P2PDict;                     //OTC字典

extern NSString *const ProCoinBaseDict;              //应用基本字典(尽量统一用一个)
extern NSString *const PCDigitalRecordDict;              //交易记录



#define TitleBackgroundColor [UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:1]		// 新的title背景颜色

#define RELOADDATA_DIC_KEY      @"reloadData"

//#define TITLETEXT @"正在获取数据..."
//#define DETAILSTEXT @"请稍等..."
#define TITLETEXT	nil
#define DETAILSTEXT NSLocalizedStringForKey(@"正在获取数据...")

#define HUD_SUCCEED             @"MWPhotoBrowser.bundle/images/tip_succeed.png"
#define HUD_ERROR               @"MWPhotoBrowser.bundle/images/tip_error.png"
#define HUD_SAFE                @"MWPhotoBrowser.bundle/images/tip_safe.png"

#define LogRect(rect, i) NSLog(@"NO:%d,X:%f,Y:%f,Width:%f,Height:%f", i, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)

typedef enum ProgressRange {
    ProgressRangeFullScreen = 1,
    ProgressRangeOnlyMiddle,
    ProgressRangeTopAndMiddle,
    ProgressRangeMiddleAndBottom
} ProgressRange;

typedef enum welcomeImageType {
    WelcomeImageType_Helppick,
    WelcomeImageType_Stockpk,
    WelcomeImageType_StockTeamPK,
    WelcomeImageType_Kandapan,
    WelcomeImageType_StockTalk,
    WelcomeImageType_Grapevine
} welcomeImageType;

@interface UIViewController (PublicMethods)


#pragma mark - 设置关联,将viewcontroller与tjr_getViewController关联起来
- (void)tjr_setViewController:(UIViewController *)viewController;

#pragma mark - showProgress
- (void)showProgress:(NSString *)text detailsText:(NSString *)details;
- (void)showProgress:(NSString *)text detailsText:(NSString *)details offsetY:(CGFloat)offsetY;
- (void)showProgressDefaultText;
- (void)showProgressDefaultText:(CGFloat)offsetY;
- (void)showLastRecordTextToast;
- (void)showProgressHUDCompleteMessage:(NSString *)titleMessage detailsMessage:(NSString *)detailsMessage imageName:(NSString*)imageName;
- (void)dismissProgress;
- (void)showProgressDefaultTextSetProgressRange:(ProgressRange)_pRange;
- (MBProgressHUD *)getProgressHUD;

#pragma mark - 跳转函数
- (void)pageToViewControllerForName:(NSString *)toViewController;
- (void)pageToViewControllerForName:(NSString *)toViewController animated:(BOOL)animated;
- (void)pageToViewControllerForNameAndPopCurrentController:(NSString *)toViewController;
- (void)goBack;
- (void)goBackWithAnimated:(BOOL)animated;
- (void)goBackToViewControllerForName:(NSString *)viewController animated:(BOOL)animated;
- (void)pageToOrBackWithName:(NSString *)toViewController;
- (void)pageToOrBackWithName:(NSString *)toViewController animated:(BOOL)animated;
- (void)goBackToPriorPriorView;
- (void)goBackToPriorPriorViewWithAnimated:(BOOL)animated;
- (void)goBackToPriorPriorViewWithAnimated:(BOOL)animated navigation:(UINavigationController *)navigation;
- (void)goBackToViewNumView:(NSInteger)viewNum;
- (void)goBackToViewNumViewWithAnimated:(NSInteger)viewNum animated:(BOOL)animated;

#pragma mark - Present模式，生成新的Navigation
- (void)pagePresentModalViewControllerForName:(NSString *)toViewController;
- (void)dismissModalFromParentViewController;

#pragma mark - 横屏模式，生成新的Navigation
- (void)pagePresentModalLandscapeViewControllerForName:(NSString *)toViewController;
- (void)dismissModalLandscapeViewController;
- (void)dismissModalLandscapeViewControllerToRootViewController;

- (int)viewControllerExistIndex:(NSString *)viewController;
- (void)removeViewControllerFromNavigation:(TJRBaseViewController *)viewController;

#pragma mark - 强制旋转NavigationController
- (void)rotationNavigationControllerForNinety;
- (void)rotationNavigationControllerToNormal;


#pragma mark - sleep Application
- (void)sleepApplication;
- (void)wakeUpToHomePage;


#pragma mark - toast
- (void)showToast:(NSString *)text;
- (void)showToast:(NSString *)text inView:(UIView *)inView;
- (void)showToast:(NSString *)text gravity:(iToastGravity)gravity duration:(NSInteger)duration;
- (void)showToastCenter:(NSString *)text;
- (void)showToastCenter:(NSString *)text inView:(UIView *)inView;
- (void)showToastOnTop:(NSString *)text;
- (void)showToastOnTop:(NSString *)text inView:(UIView *)inView;
- (void)showConnectionMsgToastCenter:(NSString *)text;


#pragma mark - putValueToParam

- (void)putValueToParamDictionary:(NSString *)model value:(id)value forKey:(id)key;
- (void)putValueToParamDictionaryModel:(NSString *)model withDictionary:(NSDictionary *)dic;
- (void)removeParamFromModelDictionary:(NSString *)model forKey:(id)key;
- (void)removeModelDictionaryFromParamDictionary:(NSString *)model;
- (id)getValueFromModelDictionary:(NSString *)model forKey:(id)key;
- (NSMutableDictionary *)getModelDictionary:(NSString *)model;

#pragma mark - 基类方法
- (void)httpBaseFalid:(NSError *)error;
- (void)httpBaseFalidWithLog:(NSError *)error;
- (RootController *)getRootController;

- (UIViewController *)getViewControllerWithName:(NSString *)name;
- (TJRAppDelegate *)getTJRAppDelegate;
- (BOOL)isRotation;

@end
