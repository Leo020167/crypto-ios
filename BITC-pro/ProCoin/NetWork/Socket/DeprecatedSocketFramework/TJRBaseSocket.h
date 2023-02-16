//
//  TJRBaseSocket.h
//  
//
//  Created by taojinroad on 13-10-30.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//
//
//
//  socket基类
//  关于 请求-接收方式 的socket类。如要实现推送功能，则继承此类，重写发送接收方法;
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

#define WELCOME_MSG				0
#define ECHO_MSG				1
#define WARNING_MSG				2

#define SOCKET_HEARTBEATTIME	30
#define SOCKET_TIMEOUT			30
#define READ_STRING_EOF			@"\r\n"
#define SOCKET_RECONNECTTIME	5

@protocol TJRSocketDelegate <NSObject>
@optional
- (void)willDisconnectFailed:(NSString *)reason;
- (void)didConnectToHost;
- (void)didASDidDisconnect;
- (void)didConnectionRefused;
- (void)didReadData:(NSString *)data;
- (void)didReadDataWithKey:(NSString *)key value:(NSString *)value;
@end

extern NSString *const WillDisconnectFailed;
extern NSString *const FailedErrorString;
extern NSString *const WillConnectToHost;
extern NSString *const DidConnectToHost;
extern NSString *const DidASDidDisconnect;
extern NSString *const DidConnectionRefused;
extern NSString *const DidReadData;
extern NSString *const DidReadDataWithKey;
extern NSString *const ReadData;
extern NSString *const ReadDataKey;
extern NSString *const ReadDataValue;

@interface TJRBaseSocket : NSObject {
    AsyncSocket *asyncSocket;
	NSTimer *timer;
	int socketTimerCount;
	id <TJRSocketDelegate> delegate;
    
    NSMutableData* readCacheData;
    NSMutableDictionary* dataArr;
    
    
    UInt16 socketPort;
    
    int classIsa;
@private
    NSInteger _socketTag;
}
@property (nonatomic, retain) AsyncSocket *asyncSocket;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSMutableData* readCacheData;
@property (nonatomic, retain) NSMutableDictionary* dataArr;
@property (nonatomic, copy) NSString *postBaseKey;

@property (nonatomic, copy) NSString *socketIp;;

- (id)initSocket;
- (id)initSocketWithHost:(NSString*)hostName port:(UInt16)port;
- (void)sendFile:(NSData *)data;
- (void)sendMSG:(NSString *)str _delegate:(id)_delegate finish:(SEL)finish faild:(SEL)faild;
- (void)reconnect;
- (void)startTimer;
- (void)closeTimer;
- (void)close;
- (BOOL)isClosed;
- (void)onHeartBeatTimer:(NSTimer *)timer;
+ (NSString *)notificationKeyWith:(Class)object name:(NSString *)name;


/**
 *  @brief  从delegate字典里移除
 *
 *  @param _delegate  目标delegate
 *
 */
- (void)removeSocketDelegate:(id)_delegate;
@end




/**
 *	一个socket请求所包含内容，用于记录回调函数
 */
@interface TJRSocketBaseDelegate : NSObject {
    id _delegate;
    BOOL bFinish;
    int _classIsa;
    
    SEL requestDidFinishSelector;
	SEL requestDidFailSelector;
}
@property (nonatomic, assign, getter=isBfinish) BOOL bFinish;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) int classIsa;

@property (assign) SEL requestDidFinishSelector;
@property (assign) SEL requestDidFailSelector;

- (id)initWithDelegate:(id)delegate_ socketFinish:(SEL)finish socketFaild:(SEL)faild ;
@end
