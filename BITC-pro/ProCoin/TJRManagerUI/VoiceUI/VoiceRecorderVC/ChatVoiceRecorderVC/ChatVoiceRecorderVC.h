//
//  ChatVoiceRecorderVC.h
//  TJRtaojinroad
//
//  Created by Jeans on 3/23/13.
//  Copyright (c) 2018 Taojinroad. All rights reserved.
//

#import "VoiceRecorderBaseVC.h"


#define kRecorderViewRect           CGRectMake([[UIScreen mainScreen]bounds].size.width/2 - 80, [[UIScreen mainScreen]bounds].size.height/2 - 80, 160, 160)

#define kCancelOriginY              ([[UIScreen mainScreen]bounds].size.height-70)

@interface ChatVoiceRecorderVC : VoiceRecorderBaseVC

//开始录音
- (void)beginRecordByChatTopicId:(NSString*)_topicId;

@end
