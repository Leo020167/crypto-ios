//
//  MHShareViewController.h
//  Cropyme
//
//  Created by Hay on 2019/7/11.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseViewController.h"

#define MHShareViewUserIdKey        @"MHShareViewUserIdKey"
#define MHShareViewUserHeadLogoKey  @"MHShareViewUserHeadLogoKey"
#define MHShareViewUserNameKey      @"MHShareViewUserNameKey"

typedef enum{
    MHShareViewShareTypePersonalInvite = 0,         //个人邀请
    MHShareViewShareTypeOthers,                     //分享别人
}MHShareViewShareType;

@interface MHShareViewController : TJRBaseViewController

/** infoDic格式为 {MHShareViewUserIdKey : @"",MHShareViewUserHeadLogoKey : @"",MHShareViewUserNameKey : @""} ,可以为nil,默认取个人信息*/
- (void)controllerShowInController:(UIViewController *)controller withShareUrl:(NSString *)shareUrl withShareType:(MHShareViewShareType)shareType withInfo:(NSDictionary *)infoDic;

@end


