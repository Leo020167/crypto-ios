//
//  QuotationSocket.h
//  Cropyme
//
//  Created by Hay on 2019/5/16.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "MHBaseSocket.h"


#define MHSocketDidConnectedToServerNotification      @"MHSocketDidConnectedToServerNotification"
#define MHSocketDidReadDataNotification               @"MHSocketDidReadDataNotification"
#define MHSocketDisconnectedToServerNotification      @"MHSocketDisconnectedToServerNotification"

#define PCShareTimeHistoryTotalDataCount            600             //历史分时取的数据



/** socket tag
 *  用于标识请求的消息，使其与返回的数据相对应
 */
typedef enum{
    QuotationSocketMarketTag  =   100,          //首页市值标签
    QuotationSocketRealTimeDataTag,             //行情实时数据标签
    QuotationSocketShareTimeHistoryTag,         //行情分时历史数据标签
    QuotationSocketFifteenMinutesTag,
    QuotationSocketOneHourTag,
    QuotationSocketFourHourTag,
    QuotationSocketOneDayTag,
    QuotationSocketOneWeekTag,
    
}QuotationSocketTag;

static NSString * _Nonnull HomeQuotationsTabCustom = @"optional";           //自选行情标签
static NSString * _Nonnull HomeQuotationsTabHB = @"digital";                //数字货币行情标签
static NSString * _Nonnull HomeQuotationsTabSotckFutures = @"stock";        //股指期货行情
static NSString * _Nonnull HomeQuotationsTabHS = @"fx";        //沪深行情
static NSString * _Nonnull HomeQuotationsTabHK = @"hk";        //港股行情

static NSString * _Nonnull PCQuotationKLineTypeShareTime = @"min1";         //1min,分时
static NSString * _Nonnull PCQuotationKLineTypeMin5     = @"min5";        //5分钟线
static NSString * _Nonnull PCQuotationKLineTypeMin15     = @"min15";        //15分钟线
static NSString * _Nonnull PCQuotationKLineTypeHour1     = @"hour1";        //1小时线
static NSString * _Nonnull PCQuotationKLineTypeHour4     = @"hour4";        //4小时线
static NSString * _Nonnull PCQuotationKLineTypeMin1      = @"min1";          //1分钟线
static NSString * _Nonnull PCQuotationKLineTypeDay       = @"day";          //日线
static NSString * _Nonnull PCQuotationKLineTypeWeek      = @"week";         //周线
static NSString * _Nonnull PCQuotationKLineTypeMonth     = @"month";        //月线



NS_ASSUME_NONNULL_BEGIN

@interface QuotationSocket : NSObject

+ (QuotationSocket *)shareQuotationSocket;

- (void)quotationSocketClose;
- (void)quotationSocketOpen;


//ps:要知道socket成功连接，接受数据等，必须实现以下方法,必须先注册再进行连接，否则连接的信息不能收到

/** 拼接通知字符串标识符*/
- (NSString *)fullConnectedToServerNotificationName;
- (NSString *)fullDisconnectedToServerNotificationName;

/** 注册连接上服务器消息通知*/
- (void)registerNotificationOfDidConnectedToServer:(id)observer selector:(SEL)selector;
/** 注册用户断开连接通知*/
- (void)registerNotificationOfDisconnectedToServer:(id)observer selector:(SEL)selector;

//ps:创建了通知必须在适当位置调用以下注销方法，否则容易导致数据错乱*/
/** 注销所有socket注册的方法，不包括其他自行注册的通知*/
- (void)cancelAllNotifcationOfSocket:(id)observer;

@end

NS_ASSUME_NONNULL_END
