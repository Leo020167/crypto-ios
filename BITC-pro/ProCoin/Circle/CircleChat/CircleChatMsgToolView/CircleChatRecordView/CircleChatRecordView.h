//
//  CircleChatRecordView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-6-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRRecordView.h"

@class CircleChatRecordView;

@protocol CircleRecordDelegate <NSObject>

- (void)recordView:(CircleChatRecordView *)recordView recordOnClickSend:(NSString*)fileName length:(NSInteger)length;

@end

@interface CircleChatRecordView : TJRRecordView{

}
@property (assign, nonatomic) id <CircleRecordDelegate> circleDelegate;
- (void)clean;
@end

