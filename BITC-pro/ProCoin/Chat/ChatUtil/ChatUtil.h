//
//  ChatUtil.h
//  TJRtaojinroad
//
//  Created by taojinroad on 06/12/2016.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "TJRBaseObj.h"

@class TJRBaseViewController;

@interface ChatUtil : TJRBaseObj

+ (void)createChatTopic:(NSDictionary*)jsonDict ctr:(TJRBaseViewController*)ctr;

+ (void)createChatTopicWithUserId:(NSString*)taUserId userName:(NSString*)userName headurl:(NSString*)headurl ctr:(TJRBaseViewController*)ctr;
@end
