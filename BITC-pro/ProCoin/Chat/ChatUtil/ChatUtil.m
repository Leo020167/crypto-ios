//
//  ChatUtil.m
//  TJRtaojinroad
//
//  Created by taojinroad on 06/12/2016.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "ChatUtil.h"
#import "ChatJonsParser.h"
#import "PrivateChatSQL.h"
#import "PrivateChatDataEntity.h"
#import "TJRBaseViewController.h"
#import "CommonUtil.h"

@implementation ChatUtil


+ (void)createChatTopic:(NSDictionary*)jsonDict ctr:(TJRBaseViewController*)ctr {
    
    ChatJonsParser *parser = [[ChatJonsParser alloc]init];
    if ([parser parseBaseIsOk:jsonDict]) {
        
        NSDictionary *dic = [jsonDict objectForKey:@"data"];
        
        NSDictionary *userDic = [dic objectForKey:@"user"];
        NSString *chatTopic = [dic objectForKey:@"chatTopic"];

        if (TTIsStringWithAnyText(chatTopic)) {
            PrivateChatDataEntity * item = [[[PrivateChatDataEntity alloc]init]autorelease];
            item.chatTopic = chatTopic;
            item.userId = [userDic objectForKey:@"userId"];
            item.headurl = [userDic objectForKey:@"headUrl"];
            item.name = [userDic objectForKey:@"name"];
            [PrivateChatSQL createPrivateChatSQL:item];
            
            [ctr putValueToParamDictionary:ChatDict value:chatTopic forKey:@"chatTopic"];
            [ctr putValueToParamDictionary:ChatDict value:item.userId forKey:@"taUserId"];
            [ctr putValueToParamDictionary:ChatDict value:item.name forKey:@"userName"];
            [ctr pageToOrBackWithName:@"ChatViewController"];
            
        }
    }else{
        NSString* str = @"发起私聊失败";
        if ([jsonDict objectForKey:@"msg"]) {
            str = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"msg"]];
        }
        [ctr showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_ERROR];
    }
    
    [parser release];
}

+ (void)createChatTopicWithUserId:(NSString*)taUserId userName:(NSString*)userName headurl:(NSString*)headurl ctr:(TJRBaseViewController*)ctr {
    if (!TTIsStringWithAnyText(taUserId) || !TTIsStringWithAnyText(ROOTCONTROLLER_USER.userId)) {
        return;
    }
    
    NSString* chatTopic = @"";
    if ([taUserId longLongValue] > [ROOTCONTROLLER_USER.userId longLongValue]) {
        chatTopic = [NSString stringWithFormat:@"%@-%@",ROOTCONTROLLER_USER.userId,taUserId];
    }else{
        chatTopic = [NSString stringWithFormat:@"%@-%@",taUserId,ROOTCONTROLLER_USER.userId];
    }
    
    if (TTIsStringWithAnyText(chatTopic)) {
        PrivateChatDataEntity * item = [[[PrivateChatDataEntity alloc]init]autorelease];
        item.chatTopic = chatTopic;
        item.userId = taUserId;
        item.name = userName;
        item.headurl = headurl;
        [PrivateChatSQL createPrivateChatSQL:item];
        
        [ctr putValueToParamDictionary:ChatDict value:chatTopic forKey:@"chatTopic"];
        [ctr putValueToParamDictionary:ChatDict value:taUserId forKey:@"taUserId"];
        [ctr putValueToParamDictionary:ChatDict value:item.name forKey:@"userName"];
        [ctr pageToOrBackWithName:@"ChatViewController"];
        
    }
}

@end
