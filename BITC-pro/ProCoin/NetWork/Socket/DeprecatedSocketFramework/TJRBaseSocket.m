//
//  TJRBaseSocket.m
//
//
//  Created by taojinroad on 13-10-30.
//  Copyright (c) 2013年  All rights reserved.
//
//
//
//  socket基类
//  关于 请求-接收方式 的socket类。如要实现推送功能，则继承此类，重写发送接收方法;
//
#import "TJRBaseSocket.h"
#import "CommonUtil.h"


 NSString *const WillDisconnectFailed = @"willDisconnectFailed";
 NSString *const FailedErrorString = @"failedErrorString";
 NSString *const WillConnectToHost = @"willConnectToHost";
 NSString *const DidConnectToHost = @"didConnectToHost";
 NSString *const DidASDidDisconnect = @"didASDidDisconnect";
 NSString *const DidConnectionRefused = @"didConnectionRefused";
 NSString *const DidReadData = @"didReadData";
 NSString *const DidReadDataWithKey = @"didReadDataWithKey";
 NSString *const ReadData = @"ReadData";
 NSString *const ReadDataKey = @"ReadDataKey";
 NSString *const ReadDataValue = @"ReadDataValue";

@implementation TJRBaseSocket
@synthesize delegate;
@synthesize timer;
@synthesize asyncSocket;
@synthesize readCacheData;
@synthesize dataArr;

- (id)initSocket {
	self = [super init];

	if (self) {
        self.postBaseKey = NSStringFromClass([self class]);
		[self reconnect];
	}
	return self;
}

- (id)initSocketWithHost:(NSString *)hostName port:(UInt16)port {
	self = [super init];
	if (self) {
        self.postBaseKey = NSStringFromClass([self class]);
		self.socketIp = hostName;
		socketPort = port;
		[self reconnect];
	}
	return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.postBaseKey = NSStringFromClass([self class]);
    }
    return self;
}

- (void)dealloc {
    RELEASE(_postBaseKey);
	self.delegate = nil;
	[dataArr release];
	[readCacheData release];
	[timer release];
	[asyncSocket release];
	[super dealloc];
}

- (void)setDelegate:(id)iDelegate {
	delegate = iDelegate;
	classIsa = [CommonUtil getDelegateIsa:iDelegate];
}

#pragma mark - 开启定时器
- (void)startTimer {
    [self closeTimer];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onHeartBeatTimer:) userInfo:nil repeats:YES];
}

#pragma mark - 关闭定时器
- (void)closeTimer {
    @synchronized(self) {
        if (timer && timer.isValid) {
            [timer invalidate];
            timer = nil;
        }
    }
}

- (void) reconnect {
	if (self.timer == nil) [self startTimer];

	asyncSocket.delegate = nil;

	self.asyncSocket = nil;

	asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
	// Advanced options - enable the socket to contine operations even during modal dialogs, and menu browsing
	[asyncSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];

	if (readCacheData == nil) {
		self.readCacheData = [NSMutableData data];
	} else {
		[readCacheData setLength:0];
	}

	if (dataArr == nil) {
		self.dataArr = [NSMutableDictionary dictionary];
	} else {
		[dataArr removeAllObjects];
	}

	NSError *err = nil;

    [[NSNotificationCenter defaultCenter] postNotificationName:[self basePostKeyWithName:WillConnectToHost] object:nil];
    if (self.socketIp == nil || self.socketIp.length == 0) {
        return;
    }
	if (![asyncSocket connectToHost:self.socketIp onPort:socketPort withTimeout:SOCKET_TIMEOUT error:&err]) {
		NSLog(@"Error: %@", err);
		socketTimerCount = SOCKET_HEARTBEATTIME - 5;	// 连接不上时，加快连接的间隔，时间为5后连接
        
        [[NSNotificationCenter defaultCenter] postNotificationName:[self basePostKeyWithName:DidConnectionRefused] object:nil];
		if ([CommonUtil cheackDelegateIsNotRelease:delegate oldClassIsa:classIsa] && [delegate respondsToSelector:@selector(didConnectionRefused)]) {
			[delegate didConnectionRefused];
		}
	}
}

- (NSString *)basePostKeyWithName:(NSString *)name {
    NSAssert(TTIsStringWithAnyText(self.postBaseKey) == YES, @"postBaseKey不能为空." );
    return [NSString stringWithFormat:@"%@_%@",self.postBaseKey,name];
}

/**
 *  接收断线等通知的Key
 *
 *  @param object 当前的socket类,传self就可以
 *  @param name   <#name description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)notificationKeyWith:(Class)object name:(NSString *)name {
    NSAssert(object != nil, @"不能为空." );
    return [NSString stringWithFormat:@"%@_%@",NSStringFromClass(object),name];
}


- (BOOL)isClosed
{
	return self.asyncSocket && [self.asyncSocket isConnected] ? NO : YES;
}

- (void)close
{
    NSLog(@"%@  socket close",NSStringFromClass([self class]));
    _socketTag = 0;
    [self closeTimer];
	[asyncSocket disconnect];
	asyncSocket.delegate = nil;
	self.asyncSocket = nil;
	socketTimerCount = 0;
	[dataArr removeAllObjects];
	self.dataArr = nil;
}

/**
 *	@brief  连接完成函数	在函数中请求读取数据, AsyncSocket内部会在有接收到数据的时候调用函数
 *   onSocket:(AsyncSocket *)sock didReadData
 *  @param  err     对应NSError对象
 *	@param  sock    对应AsyncSocket对象
 */
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
	NSLog(@" socket Connectioned %@",[self basePostKeyWithName:DidConnectToHost]);
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:SOCKET_TIMEOUT tag:0];	// 指定读取到"\r\n"。
	// [sock readDataWithTimeout:SOCKET_TIMEOUT tag:0];
	socketTimerCount = 0;
	[self sendMSG:@""];
    [[NSNotificationCenter defaultCenter] postNotificationName:[self basePostKeyWithName:DidConnectToHost] object:nil];
    if ([CommonUtil cheackDelegateIsNotRelease:delegate oldClassIsa:classIsa] && [delegate respondsToSelector:@selector(didConnectToHost)]) {
        [delegate didConnectToHost];
    }
}

- (void)onSocketDidSecure:(AsyncSocket *)sock {
	NSLog(@"onSocketDidSecure:%p", sock);
}

/**
 *	@brief  socket关闭执行函数	连接即将结束
 *  @param  err     对应NSError对象
 *	@param  sock    对应AsyncSocket对象
 */
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
	if (err != nil) {
		NSLog(@"Error %ld (%@).", (long)[err code], [err localizedDescription]);
        [[NSNotificationCenter defaultCenter] postNotificationName:[self basePostKeyWithName:WillDisconnectFailed] object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[err localizedDescription],FailedErrorString, nil]];
		if ([CommonUtil cheackDelegateIsNotRelease:delegate oldClassIsa:classIsa] && [delegate respondsToSelector:@selector(willDisconnectFailed:)]) {
			[delegate willDisconnectFailed:[err localizedDescription]];
		}
	} else {
		NSLog(@"Socket will disconnect. No error.");
	}
	socketTimerCount = SOCKET_HEARTBEATTIME - 5;	// 5秒后进行重连
}

/**
 *	@brief  socket关闭执行函数	连接结束后执行
 *
 *	@param  sock    对应AsyncSocket对象
 */
- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
	NSLog(@"%@ onSocketDidDisconnect:%p",NSStringFromClass([self class]), sock);
    
    socketTimerCount = SOCKET_HEARTBEATTIME - 5;	// 5秒后进行重连
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[self basePostKeyWithName:DidASDidDisconnect] object:nil];
	if ([CommonUtil cheackDelegateIsNotRelease:delegate oldClassIsa:classIsa] && [delegate respondsToSelector:@selector(didASDidDisconnect)]) {
		[delegate didASDidDisconnect];
	}
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
	[timer invalidate];
}

/**
 *	@brief  接收数据函数,接收数据都为NSData
 *  @param  data    接收对应数据data
 *	@param  sock    对应AsyncSocket对象
 *  @param  tag     对应AsyncSocket对象的唯一标识，可以区分是警告包或者是数据包
 */
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	if (data.length < 2) {
		NSLog(@"Error received data < 2");
		return;
	}

	const unsigned char *bytes = [data bytes] + data.length - 2;

	if ([[AsyncSocket CRLFData] isEqualToData:[NSData dataWithBytes:bytes length:2]]) {
		[readCacheData appendData:data];
		NSString *msg = [[[NSString alloc] initWithData:readCacheData encoding:NSUTF8StringEncoding] autorelease];

		if (msg) {
			NSArray *msgArray = [msg componentsSeparatedByString:@"$"];
			NSString *msgId = [msgArray firstObject];
			NSString *body = [msgArray lastObject];

			//            NSLog(@"msgid:%@",msgId);
			if (msgArray.count > 2) {
				NSLog(@"Error,数据重叠");
				NSLog(@"%@", msg);
				msg = [msg stringByReplacingOccurrencesOfString:@"0${}" withString:@""];
				NSArray *msgTmpArray = [msg componentsSeparatedByString:@"$"];
				msgId = [msgTmpArray firstObject];
				msgId = [msgId stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
				body = [msgTmpArray lastObject];
			}

			if (![msgId isEqualToString:@"0"]) {
				TJRSocketBaseDelegate *socketData = [dataArr objectForKey:msgId];

				if (delegate && socketData && socketData.delegate) return;

				if (socketData) {
					if (body.length > 0) {
						if (socketData.requestDidFinishSelector) {
							if (![body isEqualToString:READ_STRING_EOF]) {
								if ([CommonUtil cheackDelegateIsNotRelease:socketData.delegate oldClassIsa:socketData.classIsa]) {
									[socketData.delegate performSelector:socketData.requestDidFinishSelector withObject:[CommonUtil jsonValue:body]];
								}
							}
						}
					} else {
						if ([CommonUtil cheackDelegateIsNotRelease:socketData.delegate oldClassIsa:socketData.classIsa]) {
							[socketData.delegate performSelector:socketData.requestDidFailSelector withObject:[CommonUtil jsonValue:@"{\"success\":false}"]];
						}
					}
					[dataArr removeObjectForKey:msgId];
				}
			}
		} else {
			NSLog(@"Error converting received data into UTF-8 String");
		}
		[readCacheData setLength:0];
		[self startTimer];
		socketTimerCount = 0;
	} else {
		[readCacheData appendData:data];
	}
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:tag];// 指定读取到"\r\n"。
}

/**
 *	@brief  This method is called if a read has timed out.It allows us to optionally extend the timeout.
 *          We use this method to issue a warning to the user prior to disconnecting them.
 *  @param  elapsed 超时时间间隔
 *	@param  sock    对应AsyncSocket对象
 *  @param  tag     对应AsyncSocket对象的唯一标识，可以区分是警告包或者是数据包
 *  @param  length  字节长度
 */
- (NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(CFIndex)length {
	if (elapsed >= SOCKET_TIMEOUT) {
		[asyncSocket disconnect];
		return 5.0;// 等待5秒
	}

	return 0.0;
}

#pragma mark - function
- (void)sendMSG:(NSString *)str {
	if (![asyncSocket isConnected]) {
		[self reconnect];
		return;
	}
	NSString *body = @"";
    
    _socketTag++;	// key值，请求的唯一标识。
    if (_socketTag >= NSIntegerMax) {
        _socketTag = 1;
    }
    
	if (str.length > 0) {
        
        body = [NSString stringWithFormat:@"%@&msgId=%ld&msgIdSign=%@", str,_socketTag,[CommonUtil getMD5:[NSString stringWithFormat:@"%ld%@",_socketTag,RedzAPISecret]].uppercaseString];
	} else {
        body = [NSString stringWithFormat:@"/?msgId=%ld",_socketTag];
	}

	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData *msgBodyData = [NSMutableData data];
	[msgBodyData appendData:data];
	[msgBodyData appendData:[READ_STRING_EOF dataUsingEncoding:NSUTF8StringEncoding]];
	[asyncSocket writeData:msgBodyData withTimeout:-1 tag:0];
	socketTimerCount = 0;
}

- (void)sendMSG:(NSString *)str _delegate:(id)_delegate finish:(SEL)finish faild:(SEL)faild {

	self.delegate = _delegate;

    //忽略LOG出uniqkeyid
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[[str componentsSeparatedByString:@"uniqkeyid"] firstObject]]);
    
	if (![asyncSocket isConnected]) {
		// 连接没成功，跳出返回error
		if ([CommonUtil cheackDelegateIsNotRelease:_delegate oldClassIsa:classIsa] && faild) {
			[_delegate performSelector:faild withObject:[CommonUtil jsonValue:@"{\"success\":false}"]];
		}
	}

	[self sendMSG:str];

	NSString *key = [NSString stringWithFormat:@"%ld", _socketTag];
	TJRSocketBaseDelegate *socketData = [[[TJRSocketBaseDelegate alloc] initWithDelegate:self.delegate socketFinish:finish socketFaild:faild] autorelease];
	[dataArr setValue:socketData forKey:key];
}

/**
 *  @brief  从delegate字典里移除
 *
 *  @param _delegate  目标delegate
 *
 */ 
- (void)removeSocketDelegate:(id)_delegate {
    if (dataArr) {
        @synchronized (dataArr) {
            NSArray *keyArr = [dataArr allKeysForObject:_delegate];
            if (keyArr) {
                [dataArr removeObjectsForKeys:keyArr];
            }
        }
    }
}

- (void)sendFile:(NSData *)data {
	if (![asyncSocket isConnected]) {
		[self reconnect];
	}
	NSMutableData *fileBodyData = [NSMutableData data];
	[fileBodyData appendData:[@"101404" dataUsingEncoding:NSUTF8StringEncoding]];
	[fileBodyData appendData:[[NSString stringWithFormat:@"%08lud",(unsigned long) data.length] dataUsingEncoding:NSUTF8StringEncoding]];
	[fileBodyData appendData:data];

	uint32_t len = (uint32_t)[fileBodyData length];	// 8位包体长度header
	NSLog(@"Len = %u", len);
	NSMutableData *header = [NSMutableData dataWithCapacity:sizeof(len) + len];
	[header appendData:[[NSString stringWithFormat:@"%08ld", (unsigned long)fileBodyData.length] dataUsingEncoding:NSUTF8StringEncoding]];
	[header appendData:fileBodyData];
	[asyncSocket writeData:(NSData *)header withTimeout:-1 tag:0];
}

#pragma mark - timer
/**
 *  定时器回调方法
 *
 *  @param timer timer description
 */
- (void)onHeartBeatTimer:(NSTimer *)timer {
    
	socketTimerCount++;
	if (socketTimerCount >= SOCKET_HEARTBEATTIME) {
		if ([asyncSocket isConnected]) {
			[self sendMSG:@""];
		} else {
			[self reconnect];
		}
		socketTimerCount = 0;
	}
}

@end

@implementation TJRSocketBaseDelegate
@synthesize delegate;
@synthesize requestDidFinishSelector;
@synthesize requestDidFailSelector;
@synthesize bFinish;

- (id)initWithDelegate:(id)delegate_ socketFinish:(SEL)finish socketFaild:(SEL)faild{
	self = [super init];

	if (self) {
		self.delegate = delegate_;
		[self setRequestDidFinishSelector:finish];
		[self setRequestDidFailSelector:faild];
		self.classIsa = [CommonUtil getDelegateIsa:delegate_];
	}
	return self;
}

@end

