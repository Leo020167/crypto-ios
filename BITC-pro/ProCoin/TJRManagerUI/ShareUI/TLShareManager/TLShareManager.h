//
//  TLShareManager.h
//  Tjrv
//
//  Created by Hay on 2019/4/4.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    TLShareDestination_Circle = 1,                 //圈子分享
    TLShareDestination_Room   = 2,                 //直播间分享
}TLShareDestination;


@interface TLShareManager : NSObject

/** 需要保存一份manager在调用的类上，否则无法正确显示所有功能*/
- (instancetype)init;

#pragma mark - 显示分享页面
- (void)showShareViewInView:(UIView *)view shareDestination:(TLShareDestination)shareDestination shareParams:(NSString *)shareParams;

@end


