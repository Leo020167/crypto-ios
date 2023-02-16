//
//  MsgNotificationController.h
//  TJRtaojinroad
//
//  Created by taojinroad on 1/18/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "TJRBaseViewController.h"

@interface MsgNotification : TJRBaseEntity
@property (assign, nonatomic) BOOL noice;
@property (assign, nonatomic) BOOL vibration;


+ (MsgNotification *)shareNotify;

@end



@interface MsgNotificationController : TJRBaseViewController

@end
