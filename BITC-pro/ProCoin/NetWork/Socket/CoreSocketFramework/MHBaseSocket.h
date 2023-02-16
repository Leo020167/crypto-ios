//
//  MHBaseSocket.h
//  Cropyme
//
//  Created by Hay on 2019/8/2.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

#define MHSocketDidConnectedToServerNotification      @"MHSocketDidConnectedToServerNotification"
#define MHSocketDidReadDataNotification               @"MHSocketDidReadDataNotification"
#define MHSocketDisconnectedToServerNotification      @"MHSocketDisconnectedToServerNotification"

#define MHSocketJsonKey                               @"MHSocketJsonKey"
#define MHSocketTagKey                                @"MHSocketTagKey"
#define MHSocketReceiveTypeKey                        @"MHSocketReceiveTypeKey"

#define OnHeartTimeInterval                           3   //心跳包调用时间间隔5s
#define SocketTimeOutInterval                         7  //连接超时

/** socket基类，自定义的socket类都需要继续自此类
    然后重写自己所需要的逻辑类 */

#define READ_STRING_EOF            @"\r\n"
#define MAX_SAVE_POST_COUNT         1000                //socketPostDic字典最大存放数量


/** 不使用delegate 或 block 回调，直接使用消息通知机制*/
//
//@protocol MHBaseSocketDelegate <NSObject>
//
//@required
//
//
//
//@optional
///** 连接上服务器回调*/
//- (void)socketDidConnectedToServer;
///** 与服务器断开连接*/
//- (void)socketDidDisConnectedToServer;
//
//@end

@interface MHBaseSocket : NSObject
{
    GCDAsyncSocket *asyncSocket;
    BOOL makeSureConnected;
}

@property (retain, nonatomic) NSMutableData *readCacheData;                     //读取的数据


/** 初始化*/
- (id)init;
- (id)initSocketWithHost:(NSString *)hostName port:(UInt16)port;

- (void)socketConnectIfNeed;

/** 向服务器发送信息后接受到服务器信息后回调,需要子类重写*/
- (void)socket:(GCDAsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag;

/** 关闭socket*/
- (void)close;

/** 与服务器进行通信
 *  由子类重写逻辑
 */
- (void)sendMsgToServer:(NSString *)request;
- (void)sendMsgToServer:(NSString *)request withTag:(long)tag;


//ps:要知道socket成功连接，接受数据等，必须实现以下方法,必须先注册再进行连接，否则连接的信息不能收到

/** 拼接通知字符串标识符*/
- (NSString *)fullConnectedToServerNotificationName;
- (NSString *)fullDidReadDataNotificationName;
- (NSString *)fullDisconnectedToServerNotificationName;

/** 注册连接上服务器消息通知*/
- (void)registerNotificationOfDidConnectedToServer:(id)observer selector:(SEL)selector;
/** 注册收到服务器消息内容通知*/
- (void)registerNotificationOfReadData:(id)observer selector:(SEL)selector;
/** 注册用户断开连接通知*/
- (void)registerNotificationOfDisconnectedToServer:(id)observer selector:(SEL)selector;

//ps:创建了通知必须在适当位置调用以下注销方法，否则容易导致数据错乱*/
/** 注销所有socket注册的方法，不包括其他自行注册的通知*/
- (void)cancelAllNotifcationOfSocket:(id)observer;
@end


