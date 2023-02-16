//
//  MHBaseSocket.m
//  Cropyme
//
//  Created by Hay on 2019/8/2.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "MHBaseSocket.h"
#import "CommonUtil.h"

@interface MHBaseSocket()<GCDAsyncSocketDelegate>
{
    NSTimer *onHeartTimer;              //心跳包定时器
}

@property (copy, nonatomic) NSString *hostName;             //主机名
@property (assign, nonatomic) UInt16 port;                  //端口号


@end

@implementation MHBaseSocket

- (id)init
{
    if(self = [super init]){
        self.readCacheData = [NSMutableData data];
//        dispatch_queue_t queue = dispatch_queue_create(NSStringFromClass([self class]).UTF8String, DISPATCH_QUEUE_SERIAL);

    }
    return self;
}


- (id)initSocketWithHost:(NSString *)hostName port:(UInt16)port
{
    if(self = [super init]){
        self.hostName = hostName;
        self.port = port;
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.readCacheData = [NSMutableData data];
        makeSureConnected = NO;
        [self socketConnectIfNeed];
    }
    return self;
    
}

- (void)dealloc
{
    [self closeOnHeartTimer];
    RZReleaseSafe(asyncSocket);
    [_hostName release];
    [_readCacheData release];
    [super dealloc];
}

#pragma mark - 请求与服务器建立socket连接
- (void)socketConnectIfNeed
{
    if(![asyncSocket isConnected] && [asyncSocket isDisconnected]){     //确认已经断开
        NSError *err = nil;
        [self startOnHeartTimer];
        NSLog(@"%@ Socket 正在进行连接",NSStringFromClass([self class]));
        if(![asyncSocket connectToHost:_hostName onPort:_port error:&err]){
            NSLog(@"%@ Socket Connect Error:%@",NSStringFromClass([self class]),err);
        }
    }
}

#pragma mark - 关闭socket
- (void)close
{
    NSLog(@"%@  socket close",NSStringFromClass([self class]));
    [self closeOnHeartTimer];
    [asyncSocket disconnect];
}


#pragma mark - 向服务器发送通信信息
- (void)sendMsgToServer:(NSString *)request
{
    
}
- (void)sendMsgToServer:(NSString *)request withTag:(long)tag
{
    
}

#pragma mark - CGDAsyncSocket delegate
/** socket连接成功回调*/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self.readCacheData setLength:0];       //与服务器连接后立即保持空数据
//    //加上这个相当于开启接受返回信息，如果不加，则无法正常接受到后台返回的消息。后台会在连接成功第一时间返回一条socket,而socket:didReadData:withTag回调触发必须要先设置readDataWithTimeout:tag;
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:SocketTimeOutInterval tag:0];
    NSLog(@"%@ Scoket连接成功",NSStringFromClass([self class]));
    /** 成功连接服务器通知,用于请求通信或其他逻辑操作*/
    makeSureConnected = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:[self fullConnectedToServerNotificationName] object:nil];
}

/** socket连接失败,断开回调*/
- (void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)err
{
    NSLog(@"%@ Socket Disconnect Error:%@",NSStringFromClass([self class]),err);
    /** 与服务器断开连接通知*/
    makeSureConnected = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:[self fullDisconnectedToServerNotificationName] object:nil];
}

/** 向服务器发送信息后回调*/
- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag
{
}

/** 向服务器发送信息后接受到服务器信息后回调*/
- (void)socket:(GCDAsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag
{
    //子类重写该类，自己进行数据处理,进行消息通知发送
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    return -1;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    return -1;
}


#pragma mark - 注册关键通知
- (NSString *)fullConnectedToServerNotificationName
{
    return [NSString stringWithFormat:@"%@_%@",MHSocketDidConnectedToServerNotification,NSStringFromClass([self class])];
}

- (NSString *)fullDidReadDataNotificationName
{
    return [NSString stringWithFormat:@"%@_%@",MHSocketDidReadDataNotification,NSStringFromClass([self class])];
}

- (NSString *)fullDisconnectedToServerNotificationName
{
    return [NSString stringWithFormat:@"%@_%@",MHSocketDisconnectedToServerNotification,NSStringFromClass([self class])];
}

/** 注册连接上服务器消息通知*/
- (void)registerNotificationOfDidConnectedToServer:(id)observer selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:[self fullConnectedToServerNotificationName] object:nil];
}

/** 注册收到服务器消息内容通知*/
- (void)registerNotificationOfReadData:(id)observer selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:[self fullDidReadDataNotificationName] object:nil];
}

/** 注册用户断开连接通知*/
- (void)registerNotificationOfDisconnectedToServer:(id)observer selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:[self fullDisconnectedToServerNotificationName] object:nil];
}

#pragma mark - 取消关键通知
/** 注销所有socket注册的方法，不包括其他自行注册的通知*/
- (void)cancelAllNotifcationOfSocket:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:[self fullConnectedToServerNotificationName] object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:[self fullDidReadDataNotificationName] object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:[self fullDisconnectedToServerNotificationName] object:nil];
}


#pragma mark - 心跳包定时器开启与关闭
- (void)startOnHeartTimer
{
    if(onHeartTimer == nil){
        onHeartTimer = [NSTimer timerWithTimeInterval:OnHeartTimeInterval target:self selector:@selector(onHeartBeatTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:onHeartTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)closeOnHeartTimer
{
    if(onHeartTimer != nil && [onHeartTimer isValid]){
        [onHeartTimer invalidate];
        onHeartTimer = nil;
    }
}

- (void)onHeartBeatTime
{
    if(asyncSocket != nil && [asyncSocket isConnected] && ![asyncSocket isDisconnected]){
        [self sendMsgToServer:@""];
    }else{
        [self socketConnectIfNeed];
    }
    
}
@end
