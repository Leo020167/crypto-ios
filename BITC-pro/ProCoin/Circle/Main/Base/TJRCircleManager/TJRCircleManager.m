//
//  TJRCircleManager.m
//  TJRtaojinroad
//
//  Created by taojinroad on 1/6/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "TJRCircleManager.h"
#import "CommonUtil.h"

static TJRCircleManager *netWorkManage;

#define URL_API_CIRCLE_CONNECT		        @"/connect"
#define URL_API_CIRCLE_DATA_COMMAND	        @"/data/command"
#define URL_API_CHAT_SEND                   @"/chat/send"


#define URL_API_CIRCLE_SEND                 @"/circle/send"
#define URL_API_CIRCLE_SYNJOIN              @"/circle/synjoin"
#define URL_API_CIRCLE_INTO                 @"/circle/into"

@implementation TJRCircleManager

- (id)init {
	self = [super init];

	if (self) {}
	return self;
}

/**
 *	@brief	共享网络单例
 *
 *	@return
 */
+ (TJRCircleManager *)shareSingleNetWork {
	@synchronized(self) {
		if (!netWorkManage) {
			netWorkManage = [[TJRCircleManager alloc] init];
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

- (NSString *)fullApiBaseUrl:(NSString *)url params:(NSString *)params {
	return [NSString stringWithFormat:@"%@?%@", url, params];
}

#pragma mark - 连接
- (NSString *)connect{
	return [self fullApiBaseUrl:URL_API_CIRCLE_CONNECT params:
           [self fetchUrlParam: nil]];
}

#pragma mark - 告诉服务器,socket正常连接
- (NSString *)connectWithGetData {
	return [self fullApiBaseUrl:URL_API_CIRCLE_DATA_COMMAND params:
           [self fetchUrlParam:
           [BasicNameValuePair setName:@"userId" value:ROOTCONTROLLER_USER.userId],
            nil]];
}

#pragma mark -------------------------圈子-------------------------

#pragma mark - 圈子发送聊天内容
- (NSString *)sendCircleChatMsg:(NSString *)chatMsg circleId:(NSString*)circleId code:(NSString *)code {
    if (TTIsStringWithAnyText(circleId)) {
        return [self fullApiBaseUrl:URL_API_CIRCLE_SEND params:
                [self fetchUrlParam:
                 [BasicNameValuePair setName:@"circleId" value:circleId],
                 [BasicNameValuePair setName:@"type" value:@"text"],
                 [BasicNameValuePair setName:@"say" value:chatMsg],
                 [BasicNameValuePair setName:@"verify" value:code], nil]];
    }
    return nil;
}

#pragma mark - 圈子发送聊天图片
- (NSString *)sendCircleChatImg:(NSString*)circleId code:(NSString *)code fileUrl:(NSString *)fileUrl imgWidth:(NSString *)imgWidth imgHeight:(NSString *)imgHeight{
    if (TTIsStringWithAnyText(circleId)) {
        return [self fullApiBaseUrl:URL_API_CIRCLE_SEND params:
                [self fetchUrlParam:
                 [BasicNameValuePair setName:@"circleId" value:circleId],
                 [BasicNameValuePair setName:@"type" value:@"img"],
                 [BasicNameValuePair setName:@"fileUrl" value:fileUrl],
                 [BasicNameValuePair setName:@"imgWidth" value:imgWidth],
                 [BasicNameValuePair setName:@"imgHeight" value:imgHeight],
                 [BasicNameValuePair setName:@"verify" value:code], nil]];
    }
    return nil;
}

#pragma mark - 圈子发送聊天语音
- (NSString *)sendCircleChatVoice:(NSString*)circleId code:(NSString *)code fileUrl:(NSString *)fileUrl second:(NSString *)second{
    if (TTIsStringWithAnyText(circleId)) {
        return [self fullApiBaseUrl:URL_API_CIRCLE_SEND params:
                [self fetchUrlParam:
                 [BasicNameValuePair setName:@"circleId" value:circleId],
                 [BasicNameValuePair setName:@"type" value:@"voice"],
                 [BasicNameValuePair setName:@"fileUrl" value:fileUrl],
                 [BasicNameValuePair setName:@"second" value:second],
                 [BasicNameValuePair setName:@"verify" value:code], nil]];
    }
    return nil;
}


#pragma mark - 获取聊天数据
- (NSString *)getCircleRoomData:(NSString *)circleIdAndSynMark{
    return [self fullApiBaseUrl:URL_API_CIRCLE_SYNJOIN params:
            [self fetchUrlParam:
             [BasicNameValuePair setName:@"circleIdAndSynMark" value:circleIdAndSynMark], nil]];
}

#pragma mark - 进入圈子时请求
- (NSString *)toCircleRoom:(NSString *)circleId{
    return [self fullApiBaseUrl:URL_API_CIRCLE_INTO params:
            [self fetchUrlParam:
             [BasicNameValuePair setName:@"circleId" value:circleId], nil]];
}


#pragma mark -------------------------私聊-------------------------

#pragma mark - 私聊发送聊天内容
- (NSString *)sendPrivateChatMsg:(NSString *)chatMsg chatTopic:(NSString*)chatTopic code:(NSString *)code{
    if (TTIsStringWithAnyText(chatTopic)) {
        return [self fullApiBaseUrl:URL_API_CHAT_SEND params:
                [self fetchUrlParam:
                 [BasicNameValuePair setName:@"chatTopic" value:chatTopic],
                 [BasicNameValuePair setName:@"type" value:@"text"],
                 [BasicNameValuePair setName:@"say" value:chatMsg],
                 [BasicNameValuePair setName:@"verify" value:code], nil]];
    }
    return nil;
}

#pragma mark - 私聊发送聊天图片
- (NSString *)sendPrivateChatImg:(NSString*)chatTopic code:(NSString *)code fileUrl:(NSString *)fileUrl imgWidth:(NSString *)imgWidth imgHeight:(NSString *)imgHeight{
    if (TTIsStringWithAnyText(chatTopic)) {
        return [self fullApiBaseUrl:URL_API_CHAT_SEND params:
                [self fetchUrlParam:
                 [BasicNameValuePair setName:@"chatTopic" value:chatTopic],
                 [BasicNameValuePair setName:@"type" value:@"img"],
                 [BasicNameValuePair setName:@"fileUrl" value:fileUrl],
                 [BasicNameValuePair setName:@"imgWidth" value:imgWidth],
                 [BasicNameValuePair setName:@"imgHeight" value:imgHeight],
                 [BasicNameValuePair setName:@"verify" value:code], nil]];
    }
    return nil;
}

#pragma mark - 私聊发送聊天语音
- (NSString *)sendPrivateChatVoice:(NSString*)chatTopic code:(NSString *)code fileUrl:(NSString *)fileUrl second:(NSString *)second{
    if (TTIsStringWithAnyText(chatTopic)) {
        return [self fullApiBaseUrl:URL_API_CHAT_SEND params:
                [self fetchUrlParam:
                 [BasicNameValuePair setName:@"chatTopic" value:chatTopic],
                 [BasicNameValuePair setName:@"type" value:@"voice"],
                 [BasicNameValuePair setName:@"fileUrl" value:fileUrl],
                 [BasicNameValuePair setName:@"second" value:second],
                 [BasicNameValuePair setName:@"verify" value:code], nil]];
    }
    return nil;
}

@end
