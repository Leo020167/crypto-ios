//
//  NetWorkManage+Circle.h
//  TJRtaojinroad
//
//  Created by taojinroad on 11/5/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "NetWorkManage.h"

@interface NetWorkManage (Circle)

#pragma mark - 用户发起与客服私聊
- (void)reqCreateChatTopic:(id)delegate taUserId:(NSString *)taUserId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 私聊，上传图片或者语音
- (void)reqPrivateChatSendFile:(id)delegate chatTopic:(NSString *)chatTopic verifi:(NSString*)verifi type:(NSString *)type second:(NSString *)second picLength:(NSString *)picLength picWidth:(NSString *)picWidth fileName:(NSString *)fileName finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 新版用户获取与客服私聊信息
- (void)reqGetPrivateChatService:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 用户设置私聊提醒
- (void)reqGetRemind:(id)delegate chatTopic:(NSString *)chatTopic finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 用户设置私聊提醒
- (void)reqSetRemind:(id)delegate chatTopic:(NSString *)chatTopic remind:(NSInteger)remind finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -----------------------------圈子的接口-----------------------------

#pragma mark - 创建圈子
- (void)reqCircleCreate:(id)delegate circleName:(NSString *)circleName brief:(NSString *)brief circleLogo:(NSString *)circleLogo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取圈子信息接口
- (void)reqCircleOppGet:(id)delegate circleId:(NSString *)circleId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 修改圈子信息接口
- (void)reqCircleOppUpdate:(id)delegate circleId:(NSString *)circleId circleName:(NSString *)circleName brief:(NSString *)brief circleLogo:(NSString *)circleLogo circleBg:(NSString *)circleBg finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 申请进圈接口
- (void)reqCircleApplyJoin:(id)delegate circleId:(NSString *)circleId reason:(NSString *)reason finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取某个圈子的申请进圈记录
- (void)reqCircleFindApplyJoinList:(id)delegate circleId:(NSString *)circleId pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 审批入圈申请,status(-1 拒绝，1允许入圈)
- (void)reqCircleApproveApply:(id)delegate circleId:(NSString *)circleId applyId:(NSString *)applyId status:(NSInteger)status finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 取消拉黑,int status(-1拉黑,1取消拉黑)
- (void)reqCircleHandleBlack:(id)delegate circleId:(NSString *)circleId blackUserId:(NSString *)blackUserId status:(NSInteger)status finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 圈子成员列表
- (void)reqCircleMemberList:(id)delegate circleId:(NSString *)circleId pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 圈子黑名单列表
- (void)reqCircleBlackList:(id)delegate circleId:(NSString *)circleId pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 设置入圈方式,joinMode：0：需确认（默认），1：无需确认
- (void)reqCircleSetupJoinMode:(id)delegate circleId:(NSString *)circleId joinMode:(NSInteger)joinMode finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 搜索圈子接口
- (void)reqCircleSearch:(id)delegate keyValue:(NSString *)keyValue finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 设置管理员,targetUid：目标用户ID,role：0：普通用户，10：管理员
- (void)reqCircleUpdateRole:(id)delegate circleId:(NSString *)circleId targetUid:(NSString *)targetUid role:(NSInteger)role finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 移除圈子成员,addToBlackList：true：加入黑名单，false：不加入黑名单
- (void)reqCircleRemoveMember:(id)delegate circleId:(NSString *)circleId targetUid:(NSString *)targetUid addToBlackList:(BOOL)addToBlackList finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 退出圈子
- (void)reqCircleExit:(id)delegate circleId:(NSString *)circleId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 设置圈子成员发言状态,int speakStatus(0为允许发言，1为禁止发言)
- (void)reqCircleSetSpeakStatus:(id)delegate circleId:(NSString *)circleId speakStatus:(NSInteger)speakStatus finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 设置圈子消息提醒状态,int msgAlert(0为提醒，1为不提醒)
- (void)reqCircleSetMsgAlert:(id)delegate circleId:(NSString *)circleId msgAlert:(NSInteger)msgAlert finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

@end
