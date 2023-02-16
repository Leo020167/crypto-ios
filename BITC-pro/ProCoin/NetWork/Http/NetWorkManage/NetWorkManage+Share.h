//
//  NetWorkManage+Share.h
//  Perval
//
//  Created by taojinroad on 27/09/2017.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "NetWorkManage.h"

typedef enum
{
    NetWorkManageShareType_Invite = 1,          //邀请分享
}NetWorkManageShareType;

@interface NetWorkManage (Share)

#pragma mark - 获取分享信息数据
- (void)reqShareData:(id)delegate shareType:(NetWorkManageShareType)shareType params:(NSString*)params finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

@end
