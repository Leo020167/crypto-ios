//
//  TJRDefineManage.h
//  TJRtaojinroad
//
//  Created by road taojin on 12-8-29.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//
#import "TJRAppDelegate.h"

/* 上传时间:
 *  2019-09-21 18:00:00  版本1     1.0
 */

#define TJRAppVersion					@"2"//版本信息

#define TJRIsIntroduction               NO// 该版本是否需要功能介绍页


#define UseLAN                          0//1代表内网IP,0代表外网IP
#define DatabaseVersion					@"DatabaseVersion.plist"
#define kDatabaseFileName				@"tjrDb.sqlite3"		// 用户数据库
#define addrbookDatabaseFileName		@"addrbook.sqlite3"		// 通讯录数据库

#define MTAAPPKEY                       @"IMJ465NIG3DM"         // 应用的 MTA key

#define RedzAPIKey					    @"2CE2BA19C7CA4937AD18BC1AFEE034E8"// 签名使用
#define RedzAPISecret                   @"C2AE585AB6814937960DF0E0A22DF3FD"// 签名使用

#define MSG_PARAMS						@"msg_params"
#define MSG_RELOAD                      @"msg_reload"

#define WXAppId                         @""                           // 微信AppId
#define WXAppSecret                     @""             // 微信密钥

#define TencentOAuthAppId               @""                                   // Tencent qq AppId
#define TencentOAuthAppKEY              @""                             // Tencent qq AppKEY

#define SinaWeiboAppKey                 @""                                    // 新浪微博AppId
#define SinaWeiboAppSecret              @""             // 新浪微博Secret
#define SinaWeiboRedirectURI            @""                       // 新浪微博第三方应用授权回调页地址

#define LoginAccountTypePhone			@"mb"										// 登录，绑定: 类型（手机号码）
#define LoginAccountTypeSinaWeibo		@"sinawb"									// 登录，绑定: 类型（新浪微博）
#define LoginAccountTypeTencentQQ		@"qq"										// 登录，绑定: 类型（腾讯QQ）
#define LoginAccountTypeWeiXin			@"weixin"									// 登录，绑定: 类型（微信）

#define ISRUN                            @"isRun"
#define ISHD                            ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] > 1.5)    // 是否是高清屏

#define IS_IPHONE                       (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA                       ([[UIScreen mainScreen] scale] >= 2.0)

//得到屏幕bounds
#define SCREEN_SIZE                     [UIScreen mainScreen].bounds.size
#define SCREEN_WIDTH                    ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT                   ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH               (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH               (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS             (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5                     (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_5_OR_MORE             (IS_IPHONE && SCREEN_MAX_LENGTH > 568.0)
#define IS_IPHONE_6                     (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P                    (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_6P_OR_MORE            (IS_IPHONE && SCREEN_MAX_LENGTH > 736.0)

#define IPHONE_6_FONTSIZEDIFF           0
#define IPHONE_6P_FONTSIZEDIFF          1

// 判断是否是iPhone X
#define iPhoneX (((int)((SCREEN_HEIGHT/SCREEN_WIDTH)*100) == 216)?YES:NO)

#define kUINormalNavBarHeight (QMUIHelper.isNotchedScreen ? 88 : 64)
#define kUINormalTabBarHeight (QMUIHelper.isNotchedScreen ? 83 : 49)
#define kUINormalTopSafeDistance (QMUIHelper.isNotchedScreen ? 24 : 0)
#define kUINormalBottomSafeDistance (QMUIHelper.isNotchedScreen ? 34 : 0)
#define kUIStatusBarHeight (QMUIHelper.isNotchedScreen ? 44 : 20)
#define kUINavigationBarHeight  44
#define kUINormalTopSafeDistance (QMUIHelper.isNotchedScreen ? 24 : 0)

// 状态栏高度
#define STATUS_BAR_HEIGHT   [UIApplication sharedApplication].statusBarFrame.size.height
// 导航栏高度
#define NAVIGATION_BAR_HEIGHT   (44 + STATUS_BAR_HEIGHT)
// tabBar高度
#define TAB_BAR_HEIGHT (iPhoneX ? (49.f+34.f) : 49.f)
// 底部栏高度
#define IPHONEX_BOTTOM_HEIGHT (iPhoneX ? 34.f : 0.f)
// 顶部栏高度
#define IPHONEX_TOP_HEIGHT (iPhoneX ? 24.f : 0.f)


//=============================字符串操作==================
/**判断是否字符串 */
#define checkIsStringWithAnyText(_str)          (([_str isKindOfClass:[NSNull class]] || [_str isEqualToString:@"(null)"] || _str == nil || [_str length] < 1 || [_str isEqualToString:@"<null>"])? NO : YES )
/** 字符串排空 */
#define stringNonnull(_str)                     (([_str isKindOfClass:[NSNull class]] || [_str isEqualToString:@"(null)"] || _str == nil || [_str isEqualToString:@"<null>"]) ? @"" : _str)

/** 安全释放*/
#define RZReleaseSafe(_pointer)                 {!_pointer ? : [_pointer release]; _pointer = nil;}


/** -------------------------------------------- 特定网站地址 ---------------------------------------------------- */

//#define URL_SERVICE_PROTOCOL    @"http://api.bitcglobaltrade.com/procoin/article/#/passgeDetail?article_id=48"                  //服务协议
//#define URL_PRIVACY_POLICY      @"http://api.bitcglobaltrade.com/procoin/article/#/passgeDetail?article_id=54"                  //隐私条款
//#define TradeServiceProtocolWebURL         @"http://api.bitcglobaltrade.com/procoin/article/#/passgeDetail?article_id=49"       //交易服务协议
//#define TradeRulesWebURL                   @"http://api.bitcglobaltrade.com/procoin/article/#/passgeDetail?article_id=51"       //交易规则
//#define AboutUsWebURL                      @"http://api.bitcglobaltrade.com/procoin/article/#/passgeDetail?article_id=60"       //关于我们
//#define RiskWarningURL                      @"http://api.bitcglobaltrade.com/procoin/article/#/passgeDetail?article_id=66"       //风险提示
//#define DelegateRules                      @"http://api.bitcglobaltrade.com/procoin/article/#/passgeDetail?article_id=33"       //代理规则
//#define GetTokenUrl                     @"http://api.bitcglobaltrade.com/procoin/article/#/passgeDetail?article_id=222"       //如何获取token
//#define CouponWebUrl @"http://coupon.bitcglobaltrade.com/index-zh-TW.html" // 优惠券
//#define CommissionWebUrl @"http://commission.bitcglobaltrade.com" // 佣金详情

#define URL_SERVICE_PROTOCOL    [NSString stringWithFormat:@"http://api.%@/procoin/article/#/passgeDetail?article_id=48", [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"]]                  //服务协议
#define URL_PRIVACY_POLICY      [NSString stringWithFormat:@"http://api.%@/procoin/article/#/passgeDetail?article_id=54", [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"]]                  //隐私条款
#define TradeServiceProtocolWebURL         [NSString stringWithFormat:@"http://api.%@/procoin/article/#/passgeDetail?article_id=49", [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"]]       //交易服务协议
#define TradeRulesWebURL                   [NSString stringWithFormat:@"http://api.%@/procoin/article/#/passgeDetail?article_id=51", [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"]]       //交易规则
#define AboutUsWebURL                      [NSString stringWithFormat:@"http://api.%@/procoin/article/#/passgeDetail?article_id=60", [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"]]       //关于我们

#define RiskWarningURL                      [NSString stringWithFormat:@"http://api.%@/procoin/article/#/passgeDetail?article_id=66", [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"]]       //风险提示
#define DelegateRules                      [NSString stringWithFormat:@"http://api.%@/procoin/article/#/passgeDetail?article_id=33", [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"]]      //代理规则
#define GetTokenUrl                     [NSString stringWithFormat:@"http://api.%@/procoin/article/#/passgeDetail?article_id=222", [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"]]      //如何获取token

#define CouponWebUrl @"http://coupon.usefortest0327.com/index-es.html" // 优惠券
#define CommissionWebUrl @"http://commission.usefortest0327.com" // 佣金详情

#define FollowOrderRiskTipsWebURL          @""                     //跟单风险提示网站
#define FollowOrderRulesWebURL             @""                            //跟单规则网站
#define FundUSDTIntroductionWebURL         @""                               //USDT说明网站
#define CropymeServiceProtocol             @""                       //带单功能服务协议

#define DigitalAssetsDebitCreditProtocolWebURL    @""      //数字资产借贷服务协议

#define LeverageHowTradeWebURL                    @""      //杠杆功能如何交易
#define LeverageTradeInfoWebURL                   @""      //杠杆功能说明
#define StoreIntroWebURL                          @""      //存币宝说明

/** --------------------------------------------- 缓存key ------------------------------------------------------- */
#define QuotationDetailButtonOptionsKey    @"QuotationDetailButtonOptionsKey"
#define CoinQuotationDetailButtonOptionsKey    @"CoinQuotationDetailButtonOptionsKey"
#define HomeRiskRateDescLocalKey           @"HomeRiskRateDescLocalKey"
#define QuotationRefreshTimeSettingKey     @"QuotationRefreshTimeSettingKey"


/**
 *  生成在MLEmojiLabel可点击的用户名
 *
 *  @param userName 用户名
 *  @param param   点击返回参数(可以是用户id,也可以是其他字符串)
 */
#define TJRAtString(userName,param)    [NSString stringWithFormat:@"@(%@)「%@」",userName,param]

#define FMDBQuickCheck(SomeBool) {if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort();}}		        // 数据库检查正确函数宏

#define CURRENT_DEVICE_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]								// 判断当前设备ios版本号函数宏,返回如:5.1,5.0,4.3等

#define RGBA(r, g, b, a) [UIColor colorWithRed : r / 255.0f green : g / 255.0f blue : b / 255.0f alpha : a]			// RGB颜色函数宏
#define HexColorA(rgbValue, a) RGBA((float)((rgbValue & 0xFF0000) >> 16),(float)((rgbValue & 0xFF00) >> 8),(float)(rgbValue & 0xFF),a)

#define ROOTCONTROLLER_USER [[((TJRAppDelegate *)[[UIApplication sharedApplication] delegate])rootController] user]	// 返回rootController.user函数宏

#define ROOTCONTROLLER		[((TJRAppDelegate *)[[UIApplication sharedApplication] delegate])rootController]		// 返回rootController函数宏

#define Int2NSNumber(X) [NSNumber numberWithInt : X]

// stringConcat(...)
//     A shortcut for concatenating strings (or objects' string representations).
//     Input: Two or more non-nil NSObjects.
//     Output: All arguments concatenated together into a single NSString.
#define stringConcat(str1, str2, ...) \
    [@[ str1, str2, ##__VA_ARGS__] componentsJoinedByString:@""];


typedef NS_ENUM (NSInteger, KLineDataType) {/* K线数据类型 */
    KLineDataError    = 0,
    KLineData1Minute  = 1,
    KLineData5Minute  = 5,
    KLineData10Minute = 10,
    KLineData15Minute = 15,
    KLineData30Minute = 30,
    KLineData60Minute = 60,
    KLineData240Minute = 70,
    KLineDataDay      = 100,
    KLineDataWeek     = 200,
    KLineDataMonth    = 300
};


extern NSString *const DragBackBegan;
extern NSString *const DragBackChange;
extern NSString *const DragBackUp;
extern NSString *const DragBackEnd;

/* 主接口 */
extern NSString *const ApiBaseUrl;                        /* 主要url */
extern NSString *const PushSocket;
extern NSString *const ApiQuoteUrl;
extern NSString *const QuoteSocket;

/* 上传文件接口 */
extern NSString *const ApiFilesys;                      /* 上传文件接口 */

/* 圈子 socket ip */
//extern NSString *const CIRCLESOCKETIP;                  /* 圈子 socket ip */
extern NSInteger const CIRCLESOCKETPORT;                /* 圈子 端口 */

/** 行情socket ip*/
//extern NSString *const ApiQuotationIP;                      /* 行情ip */
extern NSInteger const ApiQuotationPORT;

extern NSString *const SafariPageToHeader;
extern NSString *const OtherAppPageToHeader;
extern NSString *const OtherAppPageToParam;
extern NSString *const OtherAppPageToTypeString;

extern NSString *const QuotationKLineRedFillKey;//记录K线阳线是否实心

typedef NS_ENUM(NSUInteger, OtherAppPageToType) {
	OtherAppPageToType_None = 0,
	OtherAppPageToType_Stock,
	OtherAppPageToType_SetWidget,
    OtherAppPageToType_TJRManage
};


#pragma mark - 账户、交易与记录
static NSString *PCTradeLimitOrderType = @"limit";              //限价购买
static NSString *PCTradeMarketOrderType = @"market";            //市场价购买
static NSString *PCQuotationTransactionBuyType = @"buy";          //看涨
static NSString *PCQuotationTransactionSellType = @"sell";        //看跌
static NSString *PCAccountDigitalType = @"digital";               //数字货币
static NSString *PCAccountStockType = @"stock";                   //股指期货
static NSString *PCAccountFxType = @"fx";                   //外汇
static NSString *PCAccountFollowDigitalType = @"followdigital";   //跟单数字货币
static NSString *PCAccountFollowStockType = @"followstock";       //跟单股指期货
static NSString *PCAccountFollowFxType = @"followfx";       //外汇跟单账户
static NSString *PCAccountBalanceType = @"balance";               //余额

/** 交易状态*/
typedef NS_ENUM(NSInteger,PCTransactionDoneState) {
    PCTransactionDoneStateHistory = -1,     //历史已完成记录
    PCTransactionDoneStateCurrentOrder,     //当前委托
    PCTransactionDoneStateCurrentHold,      //当前的开仓

};

static NSString *PCTransactionHistoryOrderFilledState = @"filled";          //历史记录下已成交的订单
static NSString *PCTransactionHistoryOrderCanceledState = @"canceled";      //历史记录下已撤销的订单


#pragma mark - 提币充币
typedef NS_ENUM(NSInteger, PCCoinOperationInOut){
    PCCoinOperationTypeOut = -1,    //提币
    PCCoinOperationTypeIn = 1,   //充币
};

typedef NS_ENUM(NSInteger, PCCoinOperationState){
    PCCoinOperationStateFailed = -2,            //未通过审核
    PCCoinOperationStateCancel = -1,            //已撤销
    PCCoinOperationStateCommit = 0,             //已提交，提币时才有撤销按钮，其他状态没有
    PCCoinOperationStateAccepted = 1,           //已受理
    PCCoinOperationStateSuccess = 2,            //已成功
};
