//
//  NetWorkManage.h
//  tjr-taojinroad
//
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicNameValuePair.h"
#import "TJRBaseManager.h"
#import "TJRDefineManage.h"

#define bAnda_b @"b"
#define bAnda_a @"a"

@interface NetWorkManage : TJRBaseManager {
    NSString *mApiBaseUrl;
    NSString *mApiQuoteUrl;
    NSString *mPushSocket;
    NSString *mQuoteSocket;

//    NSString *mApiCircleUrl;        // 主要对圈
//    NSString *mApiPaysysUrl;        // 主要对支付
//    NSString *mApiThirdUrl;         // 主要对分享
    NSString *mApiFileUrl;          // 主要对文件上传
}

+ (NetWorkManage *)shareSingleNetWork;
+ (void)netWorkRelease;
//+ (NSString *)getApiBaseUrl;

/** 获取各个API*/
@property (copy, nonatomic, readonly) NSString *mApiBaseUrl;
@property (copy, nonatomic, readonly) NSString *mApiQuoteUrl;
@property (copy, nonatomic, readonly) NSString *mPushSocket;
@property (copy, nonatomic, readonly) NSString *mQuoteSocket;

//@property ()

/** 解析动态dns*/
//- (void)parserDynamicDNS:(NSDictionary *)json;
- (NSString *)fullApiBaseUrl:(NSString *)apiUrl;
@end

