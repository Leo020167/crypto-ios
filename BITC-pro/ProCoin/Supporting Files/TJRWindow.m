//
//  TJRWindow.m
//  TJRtaojinroadHD
//
//  Created by taojinroad on 13-2-20.
//  Copyright (c) 2013年 Taojinroad. All rights reserved.
//

#import "TJRWindow.h"

@implementation TJRWindow

/* - (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        UIStatusBar *sb = [UIStatusBar ];
    }
    return self;
}
*/

-(void)sendEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {//发送一个名为‘nScreenTouch’（自定义）的事件
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
    }
    [super sendEvent:event];
}
@end
