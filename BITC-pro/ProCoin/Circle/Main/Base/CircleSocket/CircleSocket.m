//
//  CircleSocket.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/11/26.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "CircleSocket.h"
#import "CommonUtil.h"
#import "CircleSQL.h"
#import "CircleEntity.h"
#import "CircleChatEntity.h"
#import "CircleSettingRemindEntity.h"
#import "UserInfoSQL.h"
#import "PrivateChatSQL.h"
#import "CircleBaseDataEntity.h"
#import "MsgNotificationController.h"
#import "PrivateChatDataEntity.h"
#import "TJRCustomPushBar.h"
#import "HomeNewNumEntity.h"
#import "NetWorkManage.h"

NSString *const CircleNotifyKeyReceive   = @"receive";
NSString *const CircleNotifyKeySuccess   = @"success";
NSString *const CircleNotifyKeyType      = @"type";

@implementation CircleSocket

static CircleSocket *circleSocket;

/**
 *    初始化圈子socket,使用单例
 *    @returns 当前类
 */
+ (CircleSocket *)shareCircleSocket {
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		NSLog(@"圈子socket初始化成功");
        circleSocket = [[CircleSocket alloc] init];
	});
	return circleSocket;
}

- (instancetype)init {
    
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"api.%@", ip];
    self = [super initSocketWithHost:urlApi port:CIRCLESOCKETPORT];

	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

		circleArray = [NSMutableArray new];
		_circleDetail = [NSMutableDictionary new];
        _privateDetail = [NSMutableDictionary new];
		isPostNotification = true;
		isSaveFinish = true;
        isDisconnect = NO;
	}
	return self;
}



- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	if (data.length < 2) {
		NSLog(@"Error received data < 2");
		return;
	}

	const unsigned char *bytes = [data bytes] + data.length - 2;

	if ([[AsyncSocket CRLFData] isEqualToData:[NSData dataWithBytes:bytes length:2]]) {
		[readCacheData appendData:data];
		NSString *readMsg = [[NSString alloc] initWithData:readCacheData encoding:NSUTF8StringEncoding];
		NSString *msg = [readMsg stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
		RELEASE(readMsg);

		if (msg) {
			if (![msg isEqualToString:@"pong"]) {
				if (TTIsStringWithAnyText(msg)) {
					NSDictionary *json = [CommonUtil jsonValue:msg];

					if (json) {
						NSString *success = json[@"success"];
						NSString *reqDo = json[@"reqDo"];
						NSInteger type = [json[@"type"] integerValue];
						NSDictionary *receive = [CommonUtil jsonValue:json[@"receive"]];

						if (TTIsStringWithAnyText(reqDo)) {
							if ([@"/connect" isEqualToString:reqDo]) {	// 连接并传userid
								[self sendMsgWithType:CircleSocketConnect];
							} else if ([@"/ok" isEqualToString:reqDo]) {// socket准备完成,可以做其他操作
								isCanSend = true;
								// 获取首页圈子信息
								[self sendMsgWithType:CircleSocketCircleHome];
								//[self sendMsgWithType:CircleSocketCircleRoom];
                            } else if ([@"/getData" isEqualToString:reqDo]) {// 数据接收提醒信号,用于服务器判断socket是否连接
                                //告诉服务器,socket正常连接
                                [self sendMSG:[[TJRCircleManager shareSingleNetWork] connectWithGetData]];
                            }
						} else if (receive) {// 当receive存在的时候
							if (![success boolValue]) {
								if ([ROOTCONTROLLER rootCheckJson:receive]) {
                                    [ROOTCONTROLLER logout];
                                    return;
								}
							}
							switch (type) {

								case ReceiveModelSysTjrPush:// 官方推送
									{
                                        NSString *body = receive[@"body"];
                                        NSString *head = receive[@"head"];
                                        NSString *pview = receive[@"v"];
                                        NSString *params = receive[@"p"];
                                        NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
                                        
                                        NSMutableDictionary *userInfo = [[[NSMutableDictionary alloc]init] autorelease];
                                        [userInfo setValue:[NSNumber numberWithInteger:1] forKey:CIRCLE_PUSH_KEY];
                                        if (params.length>0) {
                                            [userInfo setValue:params forKey:MSG_PARAMS];
                                        }
                                        if (pview.length>0) {
                                            [userInfo setValue:pview forKey:CIRCLE_PAGENAME_KEY];
                                        }
                                        
                                        if (!isPostNotification) {
                                            //应用按下home键
                                            [CommonUtil registerLocalNotification:0.1 alertBody:body badgeNumber:badge userInfo:userInfo];
                                        }else{
                                            //应用打开中
                                            MsgNotification *msg = [MsgNotification shareNotify];
                                            [CommonUtil callNotificationWithNoice:msg.noice vibration:msg.vibration];
                                            
                                            [[TJRCustomPushBar shareStatusBar] showStatusMessage:body head:head didClicked:^{
                                                [ROOTCONTROLLER didReceiveRemoteNotification:userInfo];
                                            }];
                                        }
                                        break;
									}
								case ReceiveModelPushDynamicsTip:// 2500:推送动态点赞、评论消息提示更新
                                {
                                    HomeNewNumEntity *item = [[TJRCache shareTJRCache] getCacheValueForKey:HomeNewNumKey];
                                    if (!item) {
                                        item = [[HomeNewNumEntity alloc] initWithJson:receive];
                                        [[TJRCache shareTJRCache] putCacheValue:item forKey:HomeNewNumKey];
                                    }
                                    //记录本地数据
                                    NSString *jsonStr = [CommonUtil jsonToString:receive];
                                    [[NSUserDefaults standardUserDefaults] setObject:jsonStr forKey:@"PushDynamics"];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                    
                                    [item postNotification];
                                    break;
                                }
                                case ReceiveModelPrivateChatRecord:         // 2300:私聊天一条记录信息返回码
                                {
                                    
                                    CircleChatEntity *item = [[CircleChatEntity alloc] initWithJson:receive];
                                    
                                    NSString *chatTopic = receive[@"chatTopic"];
                                    
                                    if (!TTIsStringWithAnyText(chatTopic)) return;
                                    
                                    CircleChatEntity *entity = [CircleSQL queryPrivateChatTheLatestOneWithChatTopic:chatTopic];
                                    PrivateChatDataEntity *data = self.privateDetail[chatTopic];
                                    
                                    if (data && (entity.mark != 0) && !(item.mark == entity.mark) && ![item.userId isEqualToString:ROOTCONTROLLER_USER.userId] && !data.bInChat) {
                                        data.chatNews++;
                                        [PrivateChatSQL updatePrivateTopicNews:chatTopic chatNews:data.chatNews];
                                    }

                                    [CircleSQL replaceIntoPrivateChat:item];//插入聊天记录
                                    [PrivateChatSQL replaceChatSQL:item];//更新私聊列表
                                    [UserInfoSQL insertOrUpdateUserInfoWithUserId:item.userId userName:item.userName userLevel:0 headerUrl:item.headUrl];//更新用户信息
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:SOCKET_NOTIFACATION_KEY_PRIVATE_CHAT object:nil userInfo:@{SOCKET_NOTIFACATION_KEY_PRIVATE_USERINFO:item}];
                                    
                                    if (item.isPush) {
                                        if (isPostNotification) {
                                            if (![item.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
                                                MsgNotification *msg = [MsgNotification shareNotify];
                                                [CommonUtil callNotificationWithNoice:msg.noice vibration:msg.vibration];
                                            }
                                        }
                                        
                                        NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
                                        NSString *say = @"";
                                        
                                        if ([CIRCLE_CHAT_TYPE_IMG isEqualToString:item.sayType]) {
                                            say  = [NSString stringWithFormat:@"%@: [图片]", item.userName];
                                        } else if ([CIRCLE_CHAT_TYPE_VOICE isEqualToString:item.sayType]) {
                                            say  = [NSString stringWithFormat:@"%@: [语音]", item.userName];
                                        }else if ([CIRCLE_CHAT_TYPE_SYSTEM isEqualToString:item.sayType]) {
                                            NSString *say = [CircleChatEntity simpleForAtParam:item.say];
                                            say  = item.say;
                                        }else if ([CIRCLE_CHAT_TYPE_JSON isEqualToString:item.sayType]) {
                                            say  = [NSString stringWithFormat:@"%@: 发送了一条消息", item.userName];
                                        }else if ([CIRCLE_CHAT_TYPE_TEXT isEqualToString:item.sayType]) {
                                            NSString* simpleSay = [CircleChatEntity simpleForAtParam:item.say];
                                            say = [NSString stringWithFormat:@"%@: %@", item.userName,simpleSay];
                                        } else {
                                            say = [NSString stringWithFormat:@"%@ 发送了新的消息，当前版本暂不支持",item.userName];
                                        }
                                        [CommonUtil registerLocalNotification:0.1 alertBody:say badgeNumber:badge userInfo:nil];
                                    }
                                    
                                    RELEASE(item);
                                    break;
                                }
                                case ReceiveModelCircleList:// 3100:用户订阅的圈子的最新信息返回码
                                {
                                    NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
                                    
                                    for (NSDictionary *dic in receive.objectEnumerator) {
                                        CircleEntity *item = [[[CircleEntity alloc] initWithJson:dic]autorelease];
                                        [array addObject:item];
                                    }
                                    
                                    [CircleSQL otherQueueToDo:^{//使用异步线程执行
                                        [CircleSQL replaceIntoCircleInfoWithArray:[NSArray arrayWithArray:array]];// 将圈子信息保存到数据库
                                    }];

                                    [[NSNotificationCenter defaultCenter] postNotificationName:SOCKET_NOTIFACATION_KEY_CIRCLE object:nil userInfo:nil];
                                    break;
                                }
                                case ReceiveModelCircleRoleList:// 3200:用户在圈子角色
                                {
                                    for (NSDictionary *j in receive.objectEnumerator) {
                                        NSString *circleId = [NSString stringWithFormat:@"%@", j[@"circleId"]];
                                        
                                        if (TTIsStringWithAnyText(circleId)) {
                                            CircleBaseDataEntity *item = self.circleDetail[circleId];
                                            
                                            if (item) {
                                                [item updateWithJson:j];
                                            } else {
                                                item = [[[CircleBaseDataEntity alloc] initWithJson:j]autorelease];
                                                [self.circleDetail setObject:item forKey:circleId];
                                            }
                                        }
                                    }
                                    
                                    if (self.circleDetail && (self.circleDetail.count > 0)) {
                                        [CircleSQL replaceIntoMyCircleWithArray:self.circleDetail.allValues];
                                    }
                                    [[NSNotificationCenter defaultCenter] postNotificationName:SOCKET_NOTIFACATION_KEY_CIRCLE_ROLE_CHANGE object:nil];
                                    break;
                                }
                                case ReceiveModelCircleChatRecord:// 3000:圈子聊天一条记录信息返回码
                                {
                                    
                                    CircleChatEntity *item = [[CircleChatEntity alloc] initWithJson:receive];
                                    
                                    NSString *circleId = receive[@"chatTopic"];
                                    
                                    if (!TTIsStringWithAnyText(circleId)) return;
                                    
                                    CircleChatEntity *entity = [CircleSQL queryCircleChatTheLatestOneWithCircleId:circleId];
                                    CircleBaseDataEntity *data = self.circleDetail[circleId];
                                    
                                    if (data && (entity.mark != 0) && !(item.mark == entity.mark) && ![item.userId isEqualToString:ROOTCONTROLLER_USER.userId] && !data.bInChat) {
                                        data.chatNews++;
                                        [CircleSQL updateUserNewsChat:data];
                                    }
                                    
                                    [CircleSQL replaceIntoCircleChat:item];//插入聊天记录
                                    [UserInfoSQL insertOrUpdateUserInfoWithUserId:item.userId userName:item.userName userLevel:0 headerUrl:item.headUrl];//更新用户信息
                                    [CircleSQL updateSortTimeSQLWithCircleId:circleId sortTime:item.createTime];
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:SOCKET_NOTIFACATION_KEY_CIRCLE_CHAT object:nil userInfo:@{SOCKET_NOTIFACATION_KEY_CIRCLE_USERINFO:item}];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:SOCKET_NOTIFACATION_KEY_CIRCLE object:nil userInfo:nil];
                                    
                                    if (item.isPush) {
                                        if (isPostNotification) {
                                            if (![item.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
                                                MsgNotification *msg = [MsgNotification shareNotify];
                                                [CommonUtil callNotificationWithNoice:msg.noice vibration:msg.vibration];
                                            }
                                        }
                                        
                                        NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
                                        NSString *say = @"";
                                        
                                        if ([CIRCLE_CHAT_TYPE_IMG isEqualToString:item.sayType]) {
                                            say  = [NSString stringWithFormat:@"%@: [图片]", item.userName];
                                        } else if ([CIRCLE_CHAT_TYPE_VOICE isEqualToString:item.sayType]) {
                                            say  = [NSString stringWithFormat:@"%@: [语音]", item.userName];
                                        }else if ([CIRCLE_CHAT_TYPE_SYSTEM isEqualToString:item.sayType]) {
                                            NSString *say = [CircleChatEntity simpleForAtParam:item.say];
                                            say  = item.say;
                                        }else if ([CIRCLE_CHAT_TYPE_JSON isEqualToString:item.sayType]) {
                                            say  = [NSString stringWithFormat:@"%@: 发送了一条消息", item.userName];
                                        }else if ([CIRCLE_CHAT_TYPE_TEXT isEqualToString:item.sayType]) {
                                            NSString* simpleSay = [CircleChatEntity simpleForAtParam:item.say];
                                            say = [NSString stringWithFormat:@"%@: %@", item.userName,simpleSay];
                                        } else {
                                            say = [NSString stringWithFormat:@"%@ 发送了新的消息，当前版本暂不支持",item.userName];
                                        }
                                        [CommonUtil registerLocalNotification:0.1 alertBody:say badgeNumber:badge userInfo:nil];
                                    }
                                    
                                    RELEASE(item);
                                    break;
                                }
                                case ReceiveModelCircleSettingData:         // 3600:圈子配置信息(成员申请数、消息免打扰等等)
                                {
                                    for (NSDictionary *dic in receive.objectEnumerator) {
                                        NSString *circleId = [NSString stringWithFormat:@"%@", dic[@"circleId"]];
                                        NSInteger chatRemind = [dic[@"msgAlert"] integerValue];
                                        
                                        if (TTIsStringWithAnyText(circleId)) {
                                            CircleBaseDataEntity *item = self.circleDetail[circleId];
                                            
                                            if (item) {
                                                [item updateWithJson:dic];
                                            } else {
                                                item = [[[CircleBaseDataEntity alloc] initWithJson:dic]autorelease];
                                                [self.circleDetail setObject:item forKey:circleId];
                                            }
                                            
                                            //消息免打扰
                                            CircleSettingRemindEntity* settingEntity = [CircleSQL queryCircleSettingWithCircleId:circleId];
                                            settingEntity.circleId = circleId;
                                            settingEntity.chatRemind = chatRemind;
                                            [CircleSQL updateCircleSetting:circleId chatRemind:settingEntity.chatRemind];
                                        }
                                    }
                                    [[NSNotificationCenter defaultCenter] postNotificationName:SOCKET_NOTIFACATION_KEY_CIRCLE object:nil userInfo:nil];
                                    break;
                                }
                                case ReceiveModelCircleLogout:    // 3400: 用户退出/被圈主被出
                                {
                                    BOOL isNeedUpdate;

                                    for (id cId in receive.objectEnumerator) {
                                        NSString *circleId = [NSString stringWithFormat:@"%@", cId];
                                        if (TTIsStringWithAnyText(circleId)) {
                                            [CircleSQL exitCircleWithCircleId:circleId];
                                            isNeedUpdate = true;
                                        }
                                    }
                                    
                                    if (isNeedUpdate) {
                                        [[NSNotificationCenter defaultCenter] postNotificationName:SOCKET_NOTIFACATION_KEY_CIRCLE object:nil userInfo:nil];
                                    }
                                    break;
                                }

                                case ReceiveModelCircleSpeakStatus:         // 3500:圈子禁言状态
								case ReceiveModelHomeSubRecord:             // 3000:首页用户相关信息
                                case ReceiveModelPushRecordList:            // Push推送列表，包括首页信息以及私聊列表
								default: {
										NSDictionary *userInfo = [self receiveData:receive success:success type:type];
										[[NSNotificationCenter defaultCenter] postNotificationName:[CircleSocket circleNotifacationKey:type] object:nil userInfo:userInfo];
										break;
									}
							}
						}
					}
				}
			}
		} else {
			NSLog(@"Error converting received data into UTF-8 String");
		}
		[readCacheData setLength:0];
        if (!isCloseTimer) {
            [self startTimer];
        }else{
            isCloseTimer = NO;
        }
		socketTimerCount = 0;
	} else {
		[readCacheData appendData:data];
	}
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:tag];// 指定读取到"\r\n"。
}

- (NSDictionary *)receiveData:(id)receive success:(NSString *)success type:(NSInteger)type {
	NSDictionary *userInfo = @{CircleNotifyKeyReceive:receive,
							   CircleNotifyKeySuccess:success,
							   CircleNotifyKeyType:@(type)};

	return userInfo;
}

/**
 *  获取通知的key，格式：CircleNotifacationKey-ReceiveModelType
 *
 *  @param type  socket唯一码标志
 *  @return key
 */
+ (NSString *)circleNotifacationKey:(ReceiveModelType)type {
	return [NSString stringWithFormat:@"%@-%@", @"CircleNotifacationKey", @(type)];
}

- (void)sendMsgWithType:(CircleSocketMsgType)type {
	switch (type) {
		case CircleSocketConnect:
			{
                if (TTIsStringWithAnyText(ROOTCONTROLLER_USER.userId) && TTIsStringWithAnyText(ROOTCONTROLLER_USER.token)) {
                    [self sendMSG:[[TJRCircleManager shareSingleNetWork] connect]];
                }
			}
			break;

		case CircleSocketCircleHome:// 获取圈子信息
			{
                [circleArray removeAllObjects];
                [circleArray addObjectsFromArray:[CircleSQL queryCircleInfo]];
                NSMutableString *circleIdAndSynMark = [NSMutableString string];
                
                if (circleArray.count > 0) {
                    for (CircleEntity *item in circleArray) {
                        [circleIdAndSynMark appendFormat:@"%@:%@,", item.circleId, @(item.synMark)];
                    }
                }
                [self sendMSG:[[TJRCircleManager shareSingleNetWork] getCircleRoomData:circleIdAndSynMark]];
				break;
			}

		case CircleSocketCircleRoom:// 获取聊天数据
			{
				break;
			}

		default:
			break;
	}
}

/**
 *  心跳包连接
 */
- (void)ping {
	[self sendMSG:@""];
}

- (void)sendMSG:(NSString *)str {
	if (![asyncSocket isConnected]) {
		[self reconnect];
		return;
	}
	NSString *body = @"";

	if (TTIsStringWithAnyText(str)) {
		body = [NSString stringWithFormat:@"%@", str];
		NSLog(@"圈子:%@", body);
	} else {
		body = @"ping";
	}
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData *eventBodyData = [NSMutableData data];
	[eventBodyData appendData:data];
	[eventBodyData appendData:[READ_STRING_EOF dataUsingEncoding:NSUTF8StringEncoding]];
	[asyncSocket writeData:eventBodyData withTimeout:-1 tag:0];
	socketTimerCount = 0;
}

- (void)onHeartBeatTimer:(NSTimer *)timer {
	socketTimerCount++;

	if ((!isDisconnect && socketTimerCount >= SOCKET_HEARTBEATTIME) || (isDisconnect && socketTimerCount >= SOCKET_RECONNECTTIME)) {
        
        //正常时30秒发送心跳包;断开连接时，5秒重连
		if ([asyncSocket isConnected]) {
			[self ping];
		} else {
			[self reconnect];
            
		}
		socketTimerCount = 0;
	}
}

- (void)applicationDidBecomeActive {
	isPostNotification = true;
}

- (void)applicationDidEnterBackground {
	isPostNotification = false;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    [super onSocket:sock didConnectToHost:host port:port];
    isDisconnect = NO;
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    [super onSocket:sock willDisconnectWithError:err];
    isDisconnect = YES;
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
	[super onSocketDidDisconnect:sock];
    isDisconnect = YES;
	isCanSend = false;
}

- (void)close {
    [self closeTimer];
	self.baseUrlParameters = nil;
	[_circleDetail removeAllObjects];
    [super close];
    isCloseTimer = YES;
}

- (void)dealloc {
    [_privateDetail removeAllObjects];
    [_privateDetail release];
	[_circleDetail removeAllObjects];
	RELEASE(_circleDetail);
	[circleArray removeAllObjects];
	RELEASE(circleArray);
	RELEASE(_baseUrlParameters);
	[super dealloc];
}

@end
