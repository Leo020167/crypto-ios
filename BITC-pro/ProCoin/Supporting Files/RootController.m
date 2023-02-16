//
//  RootController.m
//  tjr-taojinroad
//
//  Created by taojinroad on 12-8-24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "RootController.h"
#import "TJRAppDelegate.h"
#import "LoginViewController.h"
#import "WelcomeViewController.h"
#import "NetWorkManage.h"
#import "TJRDatabase.h"
#import "TTGlobalCore.h"
#import "CommonUtil.h"
#import "TJRBaseSocket.h"
#import <sys/xattr.h>
#import "HomeViewController.h"
#import "TJRBaseParserJson.h"
#import "TJRCache.h"
#import "LoginSQLModel.h"
#import "UserParser.h"
#import "CircleSocket.h"
#import "CircleEntity.h"
#import "LanguageManager.h"

@interface RootController () <UIGestureRecognizerDelegate>
{
	BOOL bCheck;
	BOOL bReqFinished;
    
}

@end

@implementation RootController

- (id)init {
	self = [super init];

	if (self) {

		_isRun = YES;
		_isBackgroud = NO;
		bCheck = YES;
		_globalFontLevel = 0;
	}
	return self;
}

- (void)dealloc {
    [_user release];
	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];	// 扬声器播放

    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = ([paths count] > 0) ?[paths objectAtIndex:0] : nil;
	[self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:documentsDirectory]];

	[self createEditableCopyOfDatabaseIfNeeded];

	UIViewController *loginController = [[WelcomeViewController alloc] init];
	TJRAppDelegate *tjrDelegate = (TJRAppDelegate *)[[UIApplication sharedApplication] delegate];
	[tjrDelegate.navigation pushViewController:loginController animated:NO];
	RELEASE(loginController);

	bReqFinished = YES;

	NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
	self.globalFontLevel = [[userInfo objectForKey:@"globalFontLevel"] integerValue];
    
    /**获取行情刷新时间*/
    NSString *time = [[NSUserDefaults standardUserDefaults] objectForKey:QuotationRefreshTimeSettingKey];
    if(!checkIsStringWithAnyText(time)){            //如果之前没保存到
        //默认使用1秒
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:QuotationRefreshTimeSettingKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.quotationRefreshTime = 3.0f;
    }else{
        self.quotationRefreshTime = [time doubleValue];
    }
    
    
    [LanguageManager setupCurrentLanguage];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
	return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - 重新获取行情刷新时间
- (void)reloadQuotationRefreshTime
{
    NSString *time = [[NSUserDefaults standardUserDefaults] objectForKey:QuotationRefreshTimeSettingKey];
    if(checkIsStringWithAnyText(time)){
        self.quotationRefreshTime = [time doubleValue];
    }
}

#pragma mark - 导入或创建程序数据库
- (void)createEditableCopyOfDatabaseIfNeeded {
	BOOL success = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];

	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:kDatabaseFileName];

	success = [fileManager fileExistsAtPath:writableDBPath];

	if (!success) {
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDatabaseFileName];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];

		if (!success) {
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		} else {
			NSLog(@"create Edit table Copy Of Database If Needed user table 初始化成功");
		}
	} else {
		NSLog(@"user 数据库存在");
	}

	// 通讯录数据库
	NSString *writableAddrBookPath = [documentsDirectory stringByAppendingPathComponent:addrbookDatabaseFileName];
	success = [fileManager fileExistsAtPath:writableAddrBookPath];

	if (!success) {

	}
}

// Documents目录下的文件不备份到iCloud
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
	assert([[NSFileManager defaultManager]fileExistsAtPath:[URL path]]);

	BOOL success = NO;

	if (CURRENT_DEVICE_VERSION >= 5.1) {
		NSError *error = nil;
		success = [URL setResourceValue:[NSNumber numberWithBool:YES]
								 forKey:NSURLIsExcludedFromBackupKey error:&error];

		if (!success) {
			NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
		}
	} else {
		const char *filePath = [[URL path] fileSystemRepresentation];

		const char *attrName = "com.apple.MobileBackup";
		u_int8_t attrValue = 1;

		int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);

		success = result == 0;
	}
	return success;
}

#pragma mark - wakeUp Application
- (void)wakeUpApplication {

}

#pragma mark - sleep Application
- (void)sleepApplication {

}

#pragma mark - 后台运行请求
- (void)reqRootBackground {}

- (void)reqRootBackgroundFinished:(NSDictionary *)jsonDic {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RootBackground_Finished" object:nil userInfo:jsonDic]];	// 发送通知
}

- (void)reqRootBackgroundFailed:(NSDictionary *)jsonDic {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RootBackground_Failed" object:nil userInfo:jsonDic]];// 发送通知
}

#pragma mark - 接收push，进行响应
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {

    if (userInfo) {
        if ([userInfo.allKeys containsObject:CIRCLE_PUSH_KEY]) {//圈子socket收到的Push
            NSNumber *number = userInfo[CIRCLE_PUSH_KEY];
            if (number) {
                NSInteger type = number.integerValue;
                if (type == 1) {//系统数据Push
                    NSString *pageName = userInfo[CIRCLE_PAGENAME_KEY];
                    NSString *params = userInfo[MSG_PARAMS];
                    [[TJRCache shareTJRCache] putValueToParamDictionary:MSG_PARAMS value:params forKey:MSG_PARAMS];
                    TJRBaseViewController *vc = (TJRBaseViewController *)[self getCurrentTopViewControllerView];
                    
                    [vc pageToViewControllerForName:pageName];
                    
                } else if (type == 2) {//圈子push
                    NSString *pageName = userInfo[CIRCLE_PAGENAME_KEY];
                    [[TJRCache shareTJRCache] putValueToParamDictionaryModel:CIRCLE_PUSH_KEY withDictionary:userInfo];
                    TJRBaseViewController *vc = (TJRBaseViewController *)[self getCurrentTopViewControllerView];
                    [vc pageToViewControllerForName:pageName];
                }
            }
        }else{
            TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];

            NSString *params = [parser stringParser:userInfo name:@"p"];
            NSString *pview = [parser stringParser:userInfo name:@"v"];
            
            if(TTIsStringWithAnyText(params)){
                [[TJRCache shareTJRCache] putValueToParamDictionary:MSG_PARAMS value:params forKey:MSG_PARAMS];
            }
            
            if(TTIsStringWithAnyText(pview)){
                
                BOOL isExist = NO;
                for (id object in [self.navigationController.viewControllers objectEnumerator]) {
                    if ([object isKindOfClass:[HomeViewController class]]) {
                        isExist = YES;
                        break;
                    }
                }
                if (isExist) {
                    TJRBaseViewController *vc = (TJRBaseViewController *)[self getCurrentTopViewControllerView];
                    [vc pageToViewControllerForName:pview];
                }else{
                    [[TJRCache shareTJRCache] putValueToParamDictionary:PushDict value:pview forKey:@"PushPview"];
                }
                
                
            }
        }
    }
}


#pragma mark - 接口检验回调
- (BOOL)rootCheckJson:(NSDictionary *)dic {

	BOOL error = NO;
	TJRBaseParserJson *parser = [[TJRBaseParserJson alloc]autorelease];

	if (![parser parseBaseIsOk:dic]) {
		if (bCheck) {
			bCheck = NO;
			NSString *code = [NSString stringWithFormat:@"%@", [dic objectForKey:@"code"]];

			if ([code isEqualToString:@"40008"] || [code isEqualToString:@"40009"]) {
				NSString *str = NSLocalizedStringForKey(@"数据错误，请重新登录");

				if ([dic objectForKey:@"msg"]) {
					str = [NSString stringWithFormat:@"%@", [dic objectForKey:@"msg"]];
				}
				UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:NSLocalizedStringForKey(@"温馨提示") message:str delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"重新登录") otherButtonTitles:nil, nil];
				alertView.tag = 40008;
				[alertView show];
				RELEASE(alertView);
				error = YES;
            } else {
				bCheck = YES;
			}
		}
	}
	return error;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 40008) {
        if (buttonIndex != alertView.cancelButtonIndex) {

        }
    }
	bCheck = YES;
}


#pragma mark - 退出登陆
- (void)logout {
    
    [self clean];

	TJRBaseViewController *ctr = [self getViewController];

	if (ctr) {
        [CommonUtil setPageToAnimation];
        [ctr pageToOrBackWithName:@"HomeViewController" animated:NO];
        [ctr pageToViewControllerForName:@"LoginViewController" animated:NO];
        //固定调到索引为3的页面，即HomeQuotationsController，逻辑固定，所以需要根据具体需求进行修改
        for(id object in [ctr.navigationController.viewControllers objectEnumerator]){
            if([object isKindOfClass:NSClassFromString(@"HomeViewController")]){
                UITabBarController *tabBarController = (UITabBarController *)object;
                [tabBarController setSelectedIndex:0];
            }
        }
        
//        [[ctr getTJRAppDelegate].navigation popToRootViewControllerAnimated:NO];
//        [ctr pageToOrBackWithName:@"LoginViewController" animated:NO];
	}
}

- (void)clean {

    // 清除消息通知
    HomeNewNumEntity *item = [[TJRCache shareTJRCache] getCacheValueForKey:HomeNewNumKey];
    item.msgCount = 0;
    item.chatCount = 0;
    [item postNotification];
    [[TJRCache shareTJRCache] removeCacheValueForKey:HomeNewNumKey];
    
    [[CircleSocket shareCircleSocket] close];
    [LoginSQLModel deleteLoginInfo];
    [[TJRDatabase shareFMDatabaseQueue] close];

    self.user = NULL;
}

#pragma mark - 退到首页
- (void)logtoHome {

	TJRBaseViewController *ctr = [self getViewController];

	if (ctr) {
        [CommonUtil setPageToAnimation];
		[[ctr getTJRAppDelegate].navigation popToRootViewControllerAnimated:NO];
		[ctr pageToOrBackWithName:@"HomeViewController" animated:NO];
	}
}

#pragma mark - getViewController
- (TJRBaseViewController *)getViewController {
	TJRBaseViewController *ctr = nil;
	TJRAppDelegate *application = (TJRAppDelegate *)[[UIApplication sharedApplication] delegate];

	for (id object in [application.navigation.viewControllers objectEnumerator]) {
        if ([object isKindOfClass:[TJRBaseViewController class]] || [object isKindOfClass:[TJRBaseTabBarController class]]) {
			ctr = object;
			break;
		}
	}

	return ctr;
}

#pragma mark - 获取当前最顶部的viewController（不一定为当前navigationController下的vc）
- (UIViewController *)getCurrentTopViewControllerView {
    
    UINavigationController *navigation = self.navigationController;
    
    if ([navigation presentedViewController]) {
        if ([[navigation presentedViewController] isKindOfClass:[UINavigationController class]]) {
            navigation = (UINavigationController *)[navigation presentedViewController];
        }else {
            return  [navigation presentedViewController];
        }
    }
    return navigation.topViewController;
}

#pragma mark - 获取是否登录状态
- (BOOL)getLoginStatus {
    
    if (TTIsStringWithAnyText(ROOTCONTROLLER_USER.userId)) {
        return YES;
    }else{
        [self showToast:NSLocalizedStringForKey(@"请登录账号")];
        [self performSelector:@selector(gotoLogin) withObject:nil afterDelay:0.5];
    }
    
    return NO;
}

- (void)gotoLogin {

    TJRBaseViewController *ctr = [self getViewController];
    
    if (ctr) {
        [CommonUtil setPageToAnimation];
        [ctr pageToOrBackWithName:@"LoginViewController" animated:NO];
    }
}

#pragma mark - 分享成功结果显示
- (void)shareFinish:(NSDictionary *)json {
    
    UIViewController *vc = [self getCurrentTopViewControllerView];
    
    int errCode = [[json objectForKey:@"errCode"] intValue];
    NSString *thirdType = [json objectForKey:@"thirdType"];
    
    if (errCode == 0) {
        [vc showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"分享成功") detailsMessage:@"" imageName:HUD_SUCCEED];
    }else if ((errCode == -2 && [thirdType isEqualToString:LoginAccountTypeWeiXin]) ||
              (errCode == -1 && [thirdType isEqualToString:LoginAccountTypeSinaWeibo]) ||
              (errCode == -4 && [thirdType isEqualToString:LoginAccountTypeTencentQQ]) ) {
        
        [vc showToast:NSLocalizedStringForKey(@"取消分享") inView:vc.view];
    }
    else {
        [vc showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"分享失败") detailsMessage:[NSString stringWithFormat:@"error ： %d",errCode] imageName:HUD_ERROR];
    }
}

@end
