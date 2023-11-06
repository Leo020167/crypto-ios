//
//  TJRSetUpViewController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-9-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRSetUpViewController.h"
#import "TTURLCache.h"
#import "CommonUtil.h"
#import "TJRCache.h"
#import "TJRBaseParserJson.h"
#import "LoginSQLModel.h"
#import "NetWorkManage+Security.h"
#import "NetWorkManage+User.h"
#import "TTCacheManager.h"
#import "UIScrollView+AllowPanGestureEventPass.h"
#import "NetWorkManage+Circle.h"
#import "PrivateChatDataEntity.h"
#import "PrivateChatSQL.h"
#import "CircleSocket.h"
#import "CircleChatEntity.h"
#import "UserInfoSQL.h"
#import "UIButton+NewNum.h"
#import "HomeViewController.h"
#import "MyRealNameOauthViewController.h"
#import "LoginBase.h"
#import "HomeMineDataEntity.h"
#import "NetWorkManage+Home.h"

#define TJRSetUpCell @"TJRSetUpCell"
#define TJRSetUpLogoutCell @"TJRSetUpLogoutCell"

NSString *const TJRSetUpIconName = @"TJRSetUpIconName";
NSString *const TJRSetUpLanguage = @"TJRSetUpLanguage";
NSString *const TJRSetUpName = @"TJRSetUpName";
NSString *const TJRSetUpToPageName = @"TJRSetUpToPageName";

NSString *const TJRSetUpCleanCache = @"TJRSetUpCleanCache";//用来记录清除缓存的
NSString *const TJRSetUpLogout = @"TJRSetUpLogout";        // 退出登录
NSString *const TJRSetUpChatService = @"TJRSetUpChatService";

@interface TJRSetUpViewController ()
{
    BOOL enabled; // 是否开启了通知
}
@property (nonatomic, strong) TJRUser *user;
@property (retain, nonatomic) HomeMineDataEntity *dataEntity;               //数据对象
@end
@implementation TJRSetUpViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    dataArray = [NSMutableArray new];

	folderSize = 0;
    isLoadFolderSize = YES;
    // 在子线程计算缓存大小
	NSString *folderPath = [CommonUtil TTPathForDocumentsResource:kDefaultCacheName];
    [self performSelectorInBackground:@selector(folderSizeAtPath:) withObject:folderPath];
    
    [self createDataArray];

    [_tvSetUp setScreenEdgePanGestureRecognizerPriority];
    [self reqHomeMineData];
}

#pragma mark - 请求数据
- (void)reqHomeMineData
{
    [[NetWorkManage shareSingleNetWork] reqHomeMineData:self finishedCallback:@selector(reqHomeMineDataFninshed:) failedCallback:nil];
}

- (void)reqHomeMineDataFninshed:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.dataEntity = [[[HomeMineDataEntity alloc] initWithJson:dataDic] autorelease];
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)createDataArray {

    NSArray *array = @[
                       @{TJRSetUpName:NSLocalizedStringForKey(@"登录密码"),TJRSetUpToPageName:@"ModifyPasswordController"},
//                       @{TJRSetUpNam/*e:NSLocalizedStringForKey(@"交易密码管理"),TJRS*/etUpToPageName:@"PayPasswordController"},
//                       @{TJRSetUpName:NSLocalizedStringForKey(@"修改绑定手机"),TJRSetUpToPageName:@"ModifyPhoneController"},
                       @{TJRSetUpName:NSLocalizedStringForKey(@"更换语言"),TJRSetUpToPageName:@"LanguageViewController"},
                       ];
    [dataArray addObject:array];

    array = @[@{TJRSetUpName:NSLocalizedStringForKey(@"刷新频率设置"),TJRSetUpToPageName:@"QuotationRefreshSettingController"},
              @{TJRSetUpName:NSLocalizedStringForKey(@"涨跌颜色"),TJRSetUpToPageName:@"color"},
              @{TJRSetUpName:NSLocalizedStringForKey(@"消息推送"),TJRSetUpToPageName:@"MsgNotificationController"},
              @{TJRSetUpName:NSLocalizedStringForKey(@"清除缓存"),TJRSetUpToPageName:TJRSetUpCleanCache}];
    [dataArray addObject:array];

    
    array = @[@{TJRSetUpName:NSLocalizedStringForKey(@"关于我们"),TJRSetUpToPageName:@"TJRWebViewController"}];
    [dataArray addObject:array];

    NSDictionary *loginOutDic = @{TJRSetUpName:NSLocalizedStringForKey(@"退出登录"),TJRSetUpToPageName:TJRSetUpLogout};
    array = @[loginOutDic];
    
    [dataArray addObject:array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getUserData];
}

- (void)getUserData{
    [YYRequestUtility Post:@"user/info.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        NSLog(@"responseDict : %@", responseDict);
        if ([responseDict[@"code"] intValue] == 200) {
            TJRUser *user = [TJRUser yy_modelWithDictionary:responseDict[@"data"]];
            self.user = user;
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *array = dataArray[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *a = dataArray[indexPath.section];
    NSDictionary *dic = a[indexPath.row];
    NSString *toPageName = dic[TJRSetUpToPageName];

    if([toPageName isEqualToString:TJRSetUpLogout]){
        NSString *identifier = TJRSetUpLogoutCell;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil] lastObject];
        }
        return cell;
    }else{
        NSString *identifier = TJRSetUpCell;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil] lastObject];
        }
        UILabel *lbName = (UILabel *)[cell viewWithTag:1];
        lbName.text = dic[TJRSetUpName];
        UILabel *lbDetail = (UILabel *)[cell viewWithTag:2];
        if ([TJRSetUpCleanCache isEqualToString:toPageName]) {
            lbDetail.hidden = NO;
            if (isLoadFolderSize) {
                lbDetail.text = NSLocalizedStringForKey(@"计算中");
            }else{
                if (folderSize == 0) {
                    lbDetail.text = @"0M";
                } else {
                    lbDetail.text = [NSString stringWithFormat:@"%.2fM",folderSize];
                }
            }
            
        } else {
            lbDetail.hidden = YES;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *a = dataArray[indexPath.section];
    NSDictionary *dic = a[indexPath.row];
    NSString *toPageName = dic[TJRSetUpToPageName];

    if (TTIsStringWithAnyText(toPageName)) {
        if ([toPageName isEqualToString:@"PayPasswordController"]){
            if (!self.user.phone.length) {
                [self pageToOrBackWithName:@"ModifyPhoneController"];
            } else {
                [self pageToOrBackWithName:toPageName];
            }
        }
        else if ([TJRSetUpCleanCache isEqualToString:toPageName]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringForKey(@"清除缓存") message:NSLocalizedStringForKey(@"清除缓存后W.W.C.T上所有的头像、图片等要重新下载,是否清除?") delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"取消") otherButtonTitles:NSLocalizedStringForKey(@"清除"), nil];
            [alertView show];
            alertView.tag = 1001;
            RELEASE(alertView);
            
        } else if ([TJRSetUpLogout isEqualToString:toPageName]){
            
            UIAlertView *alt = [[UIAlertView alloc] initWithTitle:NSLocalizedStringForKey(@"温馨提示") message:[NSString stringWithFormat:NSLocalizedStringForKey(@"是否确定退出该账号?")] delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"取消") otherButtonTitles:NSLocalizedStringForKey(@"确定"),nil];
            
            alt.tag = 1000;
            [alt show];
            RELEASE(alt);
            
        } else if ([TJRSetUpChatService isEqualToString:toPageName]){
            [self reqPrivateChatService];
            
        } else if ([@"color" isEqualToString:toPageName]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            NSArray *titleArray = @[NSLocalizedStringForKey(@"红涨绿跌"), NSLocalizedStringForKey(@"绿涨红跌")];
            NSArray *languageArray = @[@"red", @"green"];
            for (int i = 0; i < titleArray.count; i ++) {
                [alert addAction:[UIAlertAction actionWithTitle:titleArray[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[NSUserDefaults standardUserDefaults] setObject:languageArray[i] forKey:@"appColor"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [NSBundle setLanguage:languageArray[i]];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[self getTJRAppDelegate].navigation popToRootViewControllerAnimated:NO];
                        [self pageToOrBackWithName:@"HomeViewController" animated:NO];
                    });
                }]];
            }
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else if ([TJRSetUpLanguage isEqualToString:toPageName]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            NSArray *titleArray = @[NSLocalizedStringForKey(@"简体中文"), NSLocalizedStringForKey(@"繁体中文"), NSLocalizedStringForKey(@"日语"), NSLocalizedStringForKey(@"英语")];
            NSArray *languageArray = @[@"zh-Hans", @"zh-HK", @"ja", @"en"];
            for (int i = 0; i < titleArray.count; i ++) {
                [alert addAction:[UIAlertAction actionWithTitle:titleArray[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[NSUserDefaults standardUserDefaults] setObject:languageArray[i] forKey:@"appLanguage"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [NSBundle setLanguage:languageArray[i]];
                    [QMUITips showSucceed:@"设置成功"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[self getTJRAppDelegate].navigation popToRootViewControllerAnimated:NO];
                        [self pageToOrBackWithName:@"HomeViewController" animated:NO];
                    });
                }]];
            }
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else if([toPageName isEqualToString:@"TJRWebViewController"]){
            TYWebViewController *web = [[TYWebViewController alloc] init];
            web.title = NSLocalizedStringForKey(@"关于我们");
            //web.url = _dataEntity.aboutUsUrl;
            web.url = AboutUsWebURL;
            [self.navigationController pushViewController:web animated:YES];
            
            //TYWebViewController *web = [[TYWebViewController alloc] init];
            //web.url = AboutUsWebURL;
            //[QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
        } else if([toPageName isEqualToString:@"MyOauthController"]){
            [YYRequestUtility Post:@"identity/get.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        //        state  0：审核中，1：已通过，2：未通过
                if ([responseDict[@"code"] intValue] == 200) {
                    if ([responseDict[@"data"][@"identityAuth"][@"state"] intValue] == 1) {
                        MyRealNameOauthViewController *web = [[MyRealNameOauthViewController alloc] init];
                        [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
                    }else{
                        [self pageToOrBackWithName:toPageName];
                    }
                }else{
                    [QMUITips showError:responseDict[@"msg"]];
                }
            } failure:^(NSError *error) {
            }];
        }  else {
            [self pageToOrBackWithName:toPageName];
        }
    }
}


- (void)requestLogoutDataFinished:(NSDictionary *)json {
    [self dismissProgress];
    self.canDragBack = YES;
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];
    
    if (isok) {
        [self logout];
    }
    
}

- (void)requestLogoutDataFalid:(NSDictionary *)json {
    [self dismissProgress];
    self.canDragBack = YES;
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (!isok) {
        NSLog(@"上传token失败");
    }
    [self showToastCenter:NSLocalizedStringForKey(@"注销失败") inView:self.view];
}

// 计算缓存目录下所有文件大小
- (void)folderSizeAtPath:(NSString *)folderPath {
    long long size = 0;

	NSFileManager *manager = [NSFileManager defaultManager];

    if (![manager fileExistsAtPath:folderPath])  {
        // 文件不存在,创建文件夹，显示缓存为0
        [manager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            folderSize = size / (1024.0 * 1024.0);
            [_tvSetUp reloadData];
        });
        return;
    }

	NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
	NSString *fileName;

	while ((fileName = [childFilesEnumerator nextObject]) != nil) {
		NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
		size += [self fileSizeAtPath:fileAbsolutePath];
	}
    isLoadFolderSize = NO;
	folderSize = size / (1024.0 * 1024.0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
         [_tvSetUp reloadData];
    });
   
}

#pragma mark - 退出登陆
- (void)logout {
    
    [ROOTCONTROLLER logout];
}

/* 清除缓存 */
- (void)cleanCache {

	NSString *folderPath = [CommonUtil TTPathForDocumentsResource:kDefaultCacheName];
	NSFileManager *manager = [NSFileManager defaultManager];

	if ([manager fileExistsAtPath:folderPath]) {
		[manager removeItemAtPath:folderPath error:nil];
	}

	if (![manager fileExistsAtPath:folderPath]) {	/* 创建tt缓存文件夹 */
		[manager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	/* 删除旧版中的一些文件 */
	NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	folderPath = [dirs firstObject];

	NSString *fileName;

	if ([manager fileExistsAtPath:folderPath]) {
		NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];

		while ((fileName = [childFilesEnumerator nextObject]) != nil) {
			if (([fileName rangeOfString:@".bm"].location != NSNotFound) ||
				([fileName rangeOfString:@".wav"].location != NSNotFound) ||
				([fileName rangeOfString:@".amr"].location != NSNotFound) ||
				([fileName rangeOfString:@".png"].location != NSNotFound)) {
				NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
				[manager removeItemAtPath:fileAbsolutePath error:nil];
			}
		}
	}

	/* 删除html目录 */
	NSString *fileAbsolutePath = [folderPath stringByAppendingString:HtmlDefaultCacheName];
	[manager removeItemAtPath:fileAbsolutePath error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissProgress];
        [self showToast:NSLocalizedStringForKey(@"清除缓存成功") inView:self.view];
        folderSize = 0;
        [_tvSetUp reloadData];
    });
}
// 计算某文件的大小
- (long long)fileSizeAtPath:(NSString *)filePath {
	NSFileManager *manager = [NSFileManager defaultManager];

	if ([manager fileExistsAtPath:filePath]) {
		return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
	}
	return 0;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (IBAction)backAction:(id)sender {
	[self goBack];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView.tag == 1000) {
        
        if (alertView.firstOtherButtonIndex == buttonIndex) {
            if (TTIsStringWithAnyText([self getTJRAppDelegate].pushToken)) {
                [self showProgress:NSLocalizedStringForKey(@"正在注销用户登录.") detailsText:NSLocalizedStringForKey(@"请稍后...")];
                self.canDragBack = NO;
                [[NetWorkManage shareSingleNetWork] reqLogout:self userId:ROOTCONTROLLER_USER.userId pushToken:[self getTJRAppDelegate].pushToken finishedCallback:@selector(requestLogoutDataFinished:) failedCallback:@selector(requestLogoutDataFalid:)];
            }else{
                [self logout];
            }
        }
    }else if (alertView.tag == 1001) {
        if (alertView.firstOtherButtonIndex == buttonIndex) {
            [self showProgress:NSLocalizedStringForKey(@"清除缓存") detailsText:NSLocalizedStringForKey(@"正在清除中......")];
            [self performSelectorInBackground:@selector(cleanCache) withObject:nil];
        }
    }
}


#pragma mark - 请求客服接口
- (void)reqPrivateChatService
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqGetPrivateChatService:self finishedCallback:@selector(reqPrivateChatServiceFinished:) failedCallback:@selector(reqPrivateChatServiceFailed:)];
}

- (void)reqPrivateChatServiceFinished:(NSDictionary *)json
{
    [self dismissProgress];
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc]init] autorelease];
    
    if([parser parseBaseIsOk:json]){
        
        NSDictionary *data = [json objectForKey:@"data"];
        NSString *chatTopicId = [parser stringParser:data name:@"chatTopic"];
        
        if (TTIsStringWithAnyText(chatTopicId)) {
            
            NSString* userId =  [parser stringParser:data name:@"userId"];
            NSString* headUrl =  [parser stringParser:data name:@"headUrl"];
            NSString* userName =  [parser stringParser:data name:@"userName"];
            
            PrivateChatDataEntity * item = [[[PrivateChatDataEntity alloc]init]autorelease];
            item.chatTopic = chatTopicId;
            item.userId = userId;
            item.headurl = headUrl;
            item.name = userName;
            [PrivateChatSQL createPrivateChatSQL:item];
            [UserInfoSQL insertOrUpdateUserInfoWithUserId:userId userName:userName userLevel:0 headerUrl:headUrl];
            
            PrivateChatDataEntity *entity = [PrivateChatSQL getPrivateTopic:item.chatTopic];
            if (entity) {
                [self putValueToParamDictionary:ChatDict value:entity.chatTopic forKey:@"chatTopic"];
                [self putValueToParamDictionary:ChatDict value:entity.name forKey:@"userName"];
                [self putValueToParamDictionary:ChatDict value:entity.userId forKey:@"taUserId"];
                
            }
            [self pageToOrBackWithName:@"ChatViewController"];
        
        }
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqPrivateChatServiceFailed:(NSDictionary *)json
{
    [self  dismissProgress];
    [self showToast:NSLocalizedStringForKey(@"请求失败")];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [dataArray removeAllObjects];
    RELEASE(dataArray);
    [_tvSetUp release];
    [_dataEntity release];
	[super dealloc];
}


@end

