//
//  NetWorkManage.m
//  tjr-taojinroad
//
//  Copyright (c) 2012年 Taojinroad. All rights reserved.
//

#import "NetWorkManage.h"
#import <AdSupport/AdSupport.h>

@implementation NetWorkManage

@synthesize mApiBaseUrl;
@synthesize mApiQuoteUrl;
@synthesize mPushSocket;
@synthesize mQuoteSocket;


static NetWorkManage *netWorkManage;

- (id)init {
	self = [super init];

	if (self) {
        mApiBaseUrl = ApiBaseUrl;
        mApiQuoteUrl = ApiQuoteUrl;
        mPushSocket = PushSocket;
        mQuoteSocket = QuoteSocket;
        mApiFileUrl = ApiFilesys;
#if UseLAN
        /** 设置内网，把UseLAN修改为1 ，根据具体情况，对上面5个成员变量进行修改赋值为内网地址*/
        /* 例如:
        mApiBaseUrl = @"http://192.168.1.68/......";
        mApiQuoteUrl = @"http://192.168.1.68/......";
        mApiFileUrl = @"http://192.168.1.68/......";
         */

#endif


	}
	return self;
}

/**
 *	@brief	共享网络单例
 *
 *	@return
 */
+ (NetWorkManage *)shareSingleNetWork {
	@synchronized(self) {
		if (!netWorkManage) {
			netWorkManage = [[NetWorkManage alloc] init];
		}
	}
	return netWorkManage;
}

/**
 *	@brief	网络回收
 */
+ (void)netWorkRelease {
	if (netWorkManage) TT_RELEASE_SAFELY(netWorkManage);
}


#pragma mark - 拼接基本URL

/**
 *	@brief	拼接基本URL
 *
 *	@param  apiUrl  接口
 *
 *	@return
 */
- (NSString *)fullApiBaseUrl:(NSString *)apiUrl {
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}


- (void)dealloc
{
    [mApiBaseUrl release];
    [mApiQuoteUrl release];
    [mPushSocket release];
    [mQuoteSocket release];
    [super dealloc];
}
@end
