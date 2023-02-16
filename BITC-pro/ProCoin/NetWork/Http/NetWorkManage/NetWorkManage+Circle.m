//
//  NetWorkManage+Circle.m
//  TJRtaojinroad
//
//  Created by taojinroad on 11/5/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "NetWorkManage+Circle.h"
#import "CommonUtil.h"


#define URL_API_CHAT_SEND_FILE                      @"chat/sendFile"
#define URL_API_CHAT_CREATE                         @"chat/createChatTopic"
#define URL_API_PRIVATE_CHAT_SERVICE_CHAT           @"config/svcChatTopic"
#define URL_API_CHAT_SET_REMIND                     @"chat/setRemind"
#define URL_API_CHAT_GET_REMIND                     @"chat/getRemind"


#define URL_API_CIRCLE_OPP_CREATE                   @"circle/opp/create"
#define URL_API_CIRCLE_OPP_GET                      @"circle/opp/get"
#define URL_API_CIRCLE_OPP_UPDATE                   @"circle/opp/update"
#define URL_API_CIRCLE_OPP_APPLY_JOIN               @"circle/opp/applyJoinCirlce"
#define URL_API_CIRCLE_OPP_APPROVE_APPLY            @"circle/opp/handleApply"
#define URL_API_CIRCLE_OPP_HANDLE_BLACK             @"circle/opp/handleBlack"
#define URL_API_CIRCLE_OPP_FIND_APPLYLIES           @"circle/opp/findApplies"
#define URL_API_CIRCLE_OPP_GET_MEMBER_LIST          @"circle/opp/getMemberList"
#define URL_API_CIRCLE_OPP_BLACK_LIST               @"circle/opp/blackList"
#define URL_API_CIRCLE_OPP_SEARCH                   @"circle/opp/search"
#define URL_API_CIRCLE_OPP_SETUP_JOIN_MODE          @"circle/opp/setupJoinMode"
#define URL_API_CIRCLE_OPP_UPDATE_ROLE              @"circle/opp/updateRole"
#define URL_API_CIRCLE_OPP_REMOVE_MEMBER            @"circle/opp/removeMember"
#define URL_API_CIRCLE_OPP_EXIT                     @"circle/opp/exit"
#define URL_API_CIRCLE_OPP_SET_SPEAK_STATUS         @"circle/opp/setSpeakStatus"
#define URL_API_CIRCLE_OPP_SET_MSG_ALERT            @"circle/opp/setMsgAlert"

@implementation NetWorkManage (Circle)

#pragma mark - 拼接圈子的接口

/**
 *	@brief	拼接圈子的接口
 *
 *	@param  apiUrl  接口
 *
 *	@return
 */
- (NSString *)fullApiBaseUrlCircle:(NSString *)apiUrl {
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}


#pragma mark - 用户发起私聊
- (void)reqCreateChatTopic:(id)delegate taUserId:(NSString *)taUserId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CHAT_CREATE]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"taUserId" value:taUserId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 私聊，上传图片或者语音
- (void)reqPrivateChatSendFile:(id)delegate chatTopic:(NSString *)chatTopic verifi:(NSString*)verifi type:(NSString *)type second:(NSString *)second picLength:(NSString *)picLength picWidth:(NSString *)picWidth fileName:(NSString *)fileName finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase uploadFileToServer:[self fullApiBaseUrlCircle:URL_API_CHAT_SEND_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"chatTopic" value:chatTopic],
                                        [BasicNameValuePair setName:@"verifi" value:verifi],
                                        [BasicNameValuePair setName:@"type" value:type],
                                        [BasicNameValuePair setName:@"second" value:second],
                                        [BasicNameValuePair setName:@"picLength" value:picLength],
                                        [BasicNameValuePair setName:@"picWidth" value:picWidth],nil]
                                files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"fileName" value:fileName],nil]
                          delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 用户获取与客服私聊信息
- (void)reqGetPrivateChatService:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlCircle:URL_API_PRIVATE_CHAT_SERVICE_CHAT]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 用户设置私聊提醒
- (void)reqGetRemind:(id)delegate chatTopic:(NSString *)chatTopic finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlCircle:URL_API_CHAT_GET_REMIND]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"chatTopic" value:chatTopic],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 用户设置私聊提醒
- (void)reqSetRemind:(id)delegate chatTopic:(NSString *)chatTopic remind:(NSInteger)remind finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlCircle:URL_API_CHAT_SET_REMIND]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"remind" value:[NSString stringWithFormat:@"%@",@(remind)]],
                                      [BasicNameValuePair setName:@"chatTopic" value:chatTopic],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark -----------------------------圈子的接口-----------------------------

#pragma mark - 创建圈子
- (void)reqCircleCreate:(id)delegate circleName:(NSString *)circleName brief:(NSString *)brief circleLogo:(NSString *)circleLogo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_CREATE]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleName" value:circleName],
                                       [BasicNameValuePair setName:@"brief" value:brief],
                                       [BasicNameValuePair setName:@"circleLogo" value:circleLogo],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取圈子信息接口
- (void)reqCircleOppGet:(id)delegate circleId:(NSString *)circleId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_GET]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 修改圈子信息接口
- (void)reqCircleOppUpdate:(id)delegate circleId:(NSString *)circleId circleName:(NSString *)circleName brief:(NSString *)brief circleLogo:(NSString *)circleLogo circleBg:(NSString *)circleBg finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_UPDATE]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"circleName" value:circleName],
                                       [BasicNameValuePair setName:@"brief" value:brief],
                                       [BasicNameValuePair setName:@"circleLogo" value:circleLogo],
                                       [BasicNameValuePair setName:@"circleBg" value:circleBg],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 申请进圈接口
- (void)reqCircleApplyJoin:(id)delegate circleId:(NSString *)circleId reason:(NSString *)reason finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_APPLY_JOIN]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"reason" value:reason],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取某个圈子的申请进圈记录
- (void)reqCircleFindApplyJoinList:(id)delegate circleId:(NSString *)circleId pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_FIND_APPLYLIES]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 审批入圈申请,status(-1 拒绝，1允许入圈)
- (void)reqCircleApproveApply:(id)delegate circleId:(NSString *)circleId applyId:(NSString *)applyId status:(NSInteger)status finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_APPROVE_APPLY]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"applyId" value:applyId],
                                       [BasicNameValuePair setName:@"status" value:[NSString stringWithFormat:@"%@",@(status)]],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 取消拉黑,int status(-1拉黑,1取消拉黑)
- (void)reqCircleHandleBlack:(id)delegate circleId:(NSString *)circleId blackUserId:(NSString *)blackUserId status:(NSInteger)status finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_HANDLE_BLACK]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"blackUserId" value:blackUserId],
                                       [BasicNameValuePair setName:@"status" value:[NSString stringWithFormat:@"%@",@(status)]],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 圈子成员列表
- (void)reqCircleMemberList:(id)delegate circleId:(NSString *)circleId pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_GET_MEMBER_LIST]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 圈子黑名单列表
- (void)reqCircleBlackList:(id)delegate circleId:(NSString *)circleId pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_BLACK_LIST]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 设置入圈方式,joinMode：0：需确认（默认），1：无需确认
- (void)reqCircleSetupJoinMode:(id)delegate circleId:(NSString *)circleId joinMode:(NSInteger)joinMode finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_SETUP_JOIN_MODE]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"joinMode" value:[NSString stringWithFormat:@"%@",@(joinMode)]],nil]
                               delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 搜索圈子接口
- (void)reqCircleSearch:(id)delegate keyValue:(NSString *)keyValue finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_SEARCH]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:keyValue],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 设置管理员,targetUid：目标用户ID,role：0：普通用户，10：管理员
- (void)reqCircleUpdateRole:(id)delegate circleId:(NSString *)circleId targetUid:(NSString *)targetUid role:(NSInteger)role finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_UPDATE_ROLE]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"targetUid" value:targetUid],
                                       [BasicNameValuePair setName:@"role" value:[NSString stringWithFormat:@"%@",@(role)]],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 移除圈子成员,addToBlackList：true：加入黑名单，false：不加入黑名单
- (void)reqCircleRemoveMember:(id)delegate circleId:(NSString *)circleId targetUid:(NSString *)targetUid addToBlackList:(BOOL)addToBlackList finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_REMOVE_MEMBER]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"targetUid" value:targetUid],
                                       [BasicNameValuePair setName:@"addToBlackList" value:[NSString stringWithFormat:@"%@",@(addToBlackList)]],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 退出圈子
- (void)reqCircleExit:(id)delegate circleId:(NSString *)circleId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_EXIT]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 设置圈子成员发言状态,int speakStatus(0为允许发言，1为禁止发言)
- (void)reqCircleSetSpeakStatus:(id)delegate circleId:(NSString *)circleId speakStatus:(NSInteger)speakStatus finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_SET_SPEAK_STATUS]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"speakStatus" value:[NSString stringWithFormat:@"%@",@(speakStatus)]],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 设置圈子消息提醒状态,int msgAlert(0为提醒，1为不提醒)
- (void)reqCircleSetMsgAlert:(id)delegate circleId:(NSString *)circleId msgAlert:(NSInteger)msgAlert finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlCircle:URL_API_CIRCLE_OPP_SET_MSG_ALERT]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"circleId" value:circleId],
                                       [BasicNameValuePair setName:@"msgAlert" value:[NSString stringWithFormat:@"%@",@(msgAlert)]],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


@end
