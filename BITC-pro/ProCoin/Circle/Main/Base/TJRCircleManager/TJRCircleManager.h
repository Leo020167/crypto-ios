//
//  TJRCircleManager.h
//  TJRtaojinroad
//
//  Created by taojinroad on 1/6/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "TJRBaseManager.h"

@interface TJRCircleManager : TJRBaseManager

+ (TJRCircleManager *)shareSingleNetWork;
+ (void)netWorkRelease;

#pragma mark - 连接
- (NSString *)connect;

#pragma mark - 告诉服务器,socket正常连接
- (NSString *)connectWithGetData;

#pragma mark - 圈子发送聊天内容
- (NSString *)sendCircleChatMsg:(NSString *)chatMsg circleId:(NSString*)circleId code:(NSString *)code;

#pragma mark - 圈子发送聊天图片
- (NSString *)sendCircleChatImg:(NSString*)circleId code:(NSString *)code fileUrl:(NSString *)fileUrl imgWidth:(NSString *)imgWidth imgHeight:(NSString *)imgHeight;

#pragma mark - 圈子发送聊天语音
- (NSString *)sendCircleChatVoice:(NSString*)circleId code:(NSString *)code fileUrl:(NSString *)fileUrl second:(NSString *)second;

#pragma mark - 获取聊天数据
- (NSString *)getCircleRoomData:(NSString *)circleIdAndSynMark;

#pragma mark - 进入圈子时请求
- (NSString *)toCircleRoom:(NSString *)circleId;

#pragma mark - 私聊发送聊天内容
- (NSString *)sendPrivateChatMsg:(NSString *)chatMsg chatTopic:(NSString*)chatTopic code:(NSString *)code;

#pragma mark - 私聊发送聊天图片
- (NSString *)sendPrivateChatImg:(NSString*)chatTopic code:(NSString *)code fileUrl:(NSString *)fileUrl imgWidth:(NSString *)imgWidth imgHeight:(NSString *)imgHeight;

#pragma mark - 私聊发送聊天语音
- (NSString *)sendPrivateChatVoice:(NSString*)chatTopic code:(NSString *)code fileUrl:(NSString *)fileUrl second:(NSString *)second;
@end
