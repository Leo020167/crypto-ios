//
//  ShareBase.h
//  Perval
//
//  Created by taojinroad on 27/09/2017.
//  Copyright © 2018 BPerval. All rights reserved.
//

#import "TJRBaseObj.h"
#import "NetWorkManage+Share.h"

typedef enum
{
    SHARETYPE_CIRCLE = 1,                                       //TOKA分享
    SHARETYPE_ROOM,                                             //直播分享
    SHARETYPE_COMPONENTS                                        //动态分享
    
}SHARETYPE;

@interface ShareBase : TJRBaseObj

@property (assign, nonatomic) NetWorkManageShareType shareType;//分享类型
@property (copy, nonatomic) NSString *shareParams;

@property (assign, nonatomic) BOOL isSession;//分享微信好友，朋友圈

- (void)share:(UIView*)superView;

@end
