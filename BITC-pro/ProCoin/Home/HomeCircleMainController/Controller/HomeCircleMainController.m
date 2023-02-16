//
//  HomeCircleMainController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/11/24.
//  Copyright © 2019年 淘金路. All rights reserved.
//

#import "HomeCircleMainController.h"
#import "CommonUtil.h"
#import "TJRDatabase.h"
#import "CircleSocket.h"
#import "CircleEntity.h"
#import "CircleSettingRemindEntity.h"
#import "CircleSQL.h"
#import "VeDateUtil.h"
#import "CircleChatEntity.h"
#import "MLEmojiLabel.h"
#import "CircleBaseDataEntity.h"
#import "UIBackgroundColorLabel.h"
#import "UIButton+NewNum.h"
#import "HomeViewController.h"
#import "RZWebImageView.h"
#import "ChatUtil.h"

@interface HomeCircleMainController () <UITableViewDataSource, UITableViewDelegate>{
    
	NSMutableArray *dataSource;
	CircleEntity *selectItem;

	BOOL isReloadData;

    NSMutableDictionary* dicRemind;     //用于保存聊天通知开关
}
@property (retain, nonatomic) IBOutlet UIView *tipsView;

@end

@implementation HomeCircleMainController

- (void)viewDidLoad {
	[super viewDidLoad];

    dataSource = [[NSMutableArray alloc]init];
    dicRemind = [[NSMutableDictionary alloc]init];
    _tableView.tableHeaderView = nil;
    [self queryCircleDataFromDB];
    
    if (@available(iOS 11.0, *)) {
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    // 系统通知处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 收到通知就从数据库重新查询圈子信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryCircleDataFromDB) name:SOCKET_NOTIFACATION_KEY_CIRCLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCircleChatData:) name:SOCKET_NOTIFACATION_KEY_CIRCLE_CHAT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCircleChatDataFromDB:) name:CIRCLE_USER_DELETE_THE_LAST_CHAT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCircleTag:) name:SOCKET_NOTIFACATION_KEY_CIRCLE_ROLE_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCircleMsgClear:) name:SOCKET_NOTIFACATION_KEY_CIRCLE_CHAT_CLEAR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCircleLogo:) name:SOCKET_NOTIFACATION_KEY_CIRCLE_LOGO object:nil];
    
    
    // SOCKET连接处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectToHost) name:[CircleSocket notificationKeyWith:[CircleSocket class] name:DidConnectToHost] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStartToHost) name:[CircleSocket notificationKeyWith:[CircleSocket class] name:DidASDidDisconnect] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionRefused) name:[CircleSocket notificationKeyWith:[CircleSocket class] name:DidConnectionRefused] object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([[CircleSocket shareCircleSocket] isClosed]) {
		[self connectStartToHost];
		[[CircleSocket shareCircleSocket] ping];
	} else {
		[self connectToHost];
	}

	isReloadData = true;

	if (dataSource.count == 0) [self queryCircleDataFromDB];

	if (dataSource.count > 1) {
		[self sortBySortTime:false isSort:true];
	}
	BOOL reload = false;
	if ([self getValueFromModelDictionary:CircleDict forKey:RELOADDATA_DIC_KEY]) {
        // 是否要重新获取圈信息
		reload = [self queryCircleDataFromDB];
		[self removeParamFromModelDictionary:CircleDict forKey:RELOADDATA_DIC_KEY];
	}

	if ((dataSource.count > 0) && !reload) [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification{

    if ([CommonUtil getHomeViewTabBarIndex] == 1) {
        if ([[CircleSocket shareCircleSocket] isClosed]) {
            [self connectStartToHost];
            [[CircleSocket shareCircleSocket] ping];
        } else {
            [self connectToHost];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	isReloadData = false;
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {

	[super viewDidDisappear:animated];
}

- (void)connectStartToHost {
	_statusView.hidden = NO;
	UILabel *label = [_statusView viewWithTag:400];
	label.text = @"连接中";
}

- (void)connectToHost {
	_statusView.hidden = YES;
}

- (void)connectionRefused {
	UILabel *label = [_statusView viewWithTag:400];
	label.text = @"连接拒绝";
}

#pragma mark - 从数据库中查询圈子信息
- (BOOL)queryCircleDataFromDB {
	NSArray *circleArray = [CircleSQL queryCircleInfo];
	BOOL reload = false;

	if (circleArray) {
		[dataSource removeAllObjects];
		[dataSource addObjectsFromArray:circleArray];

		[self sortBySortTime:isReloadData isSort:true];
		reload = isReloadData;

		if ([CircleSocket shareCircleSocket].circleDetail.count == 0) {
			for (CircleEntity *item in circleArray) {
				CircleBaseDataEntity *data = [CircleSQL queryCircleChatNewsWithCircleId:item.circleId];
				[[CircleSocket shareCircleSocket].circleDetail setObject:data forKey:[NSString stringWithFormat:@"%@", item.circleId]];
			}
		} else {
			for (CircleEntity *item in circleArray) {
				CircleBaseDataEntity *b  = [CircleBaseDataEntity circleBaseDataWithCircleId:item.circleId];
				CircleBaseDataEntity *data = [CircleSQL queryCircleChatNewsWithCircleId:item.circleId];

				if (data) b.chatNews = data.chatNews;
			}
		}
        
	}
    [dicRemind removeAllObjects];
	_tableView.hidden = !(circleArray && circleArray.count > 0);
    _tipsView.hidden = !_tableView.hidden;
	return reload;
}


/**
 *  更新圈子头像
 *
 *  @param notification
 */
- (void)updateCircleLogo:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    if (userInfo) {
        CircleEntity *i = userInfo[SOCKET_NOTIFACATION_KEY_CIRCLE_USERINFO];
        
        if (!i) return;
        for (CircleEntity *item in dataSource) {
            if (([item.circleId isEqualToString:i.circleId]) && (TTIsStringWithAnyText(i.circleLogo) && ![i.circleLogo isEqualToString:item.circleLogo])) {
                item.circleLogo = i.circleLogo;
                break;
            }
        }
    }
}

- (void)reloadCircleMsgClear:(NSNotification *)notification {
    [dataSource removeAllObjects];
}

- (void)reloadCircleChatData:(NSNotification *)notification {
	for (CircleEntity *item in dataSource) {
		CircleChatEntity *entity = [CircleSQL queryCircleChatTheLatestOneWithCircleId:item.circleId];

		if (entity) {
			item.chatLast = entity.say;
			item.chatLastMark = entity.mark;
			item.chatTime = entity.createTime;
			item.chatLastSayType = entity.sayType;
			item.chatUserName = entity.userName;
			item.chatUserId = entity.userId;
		}
	}
}

/**
 *  聊天通知
 *
 *  @param notification notification description
 */
- (void)updateCircleChatData:(NSNotification *)notification {
	NSDictionary *userInfo = notification.userInfo;

	if (userInfo) {
		id userData = userInfo[SOCKET_NOTIFACATION_KEY_CIRCLE_USERINFO];

		if ([userData isKindOfClass:[NSArray class]]) {
			NSArray *array = (NSArray *)userData;

			if (array && (array.count > 0)) {
				// 将新收到的聊天信息加入到首页的圈子里
				[dataSource makeObjectsPerformSelector:@selector(addTheLastOneChatDataFromArray:) withObject:array];

				[self sortBySortTime:true isSort:true];
			}
		} else if ([userData isKindOfClass:[CircleChatEntity class]]) {
			CircleChatEntity *item = (CircleChatEntity *)userData;

			if (item) {
				// 将新收到的聊天信息加入到首页的圈子里
				[dataSource makeObjectsPerformSelector:@selector(addTheLastOneChatData:) withObject:item];
				[self sortBySortTime:true isSort:true];
			}
		}
	}
}

/**
 *  更新首页排序时间
 *
 *  @param time      新的时间
 *  @param circleNum 圈号
 */
- (void)updateCircleSortTime:(NSString *)time circleId:(NSString*)circleId {
	if (TTIsStringWithAnyText(time)) {
		NSUInteger sortTime = [time integerValue];

		for (CircleEntity *item in dataSource) {
			if (([item.circleId isEqualToString:circleId]) && (item.sortTime < sortTime)) {
				item.sortTime = sortTime;
				break;
			}
		}
	}
}

/**
 *  更新首页排序时间
 *
 *  @param item 圈子数据
 *  @param time 时间
 */
- (void)updateCircleSortTimeWithCircleEntity:(CircleEntity *)item sortTime:(NSString *)time {
	if (TTIsStringWithAnyText(time) && item) {
		NSUInteger sortTime = [time integerValue];

		if (item.sortTime < sortTime) {
			item.sortTime = sortTime;
		}
	}
}

/**
 *  将圈子按时间排序
 *
 *  @param reloadData 是否刷新列表
 *  @param isSort     是否要对圈子进行排序
 */
- (void)sortBySortTime:(BOOL)reloadData isSort:(BOOL)isSort {
	if (isSort) [dataSource sortUsingSelector:@selector(compareCircleTimeByDes:)];	// 将圈子按排序时间排序

	if (isReloadData && reloadData) {// 当全局可以刷新和调用的地方可以刷新时,才刷新
		[self.tableView reloadData];
	}
}

/**
 *  当用户删除最后一条聊天时的通知
 *
 *  @param notification notification description
 */
- (void)updateCircleChatDataFromDB:(NSNotification *)notification {
	NSDictionary *userInfo = notification.userInfo;

	if (userInfo) {
		NSString* circleId = userInfo[SOCKET_NOTIFACATION_KEY_CIRCLE_USERINFO];
		CircleChatEntity *item = [CircleSQL queryCircleChatTheLatestOneWithCircleId:circleId];
		// 将新收到的聊天信息加入到首页的圈子里
		[dataSource makeObjectsPerformSelector:@selector(addTheLastOneChatData:) withObject:item];
		[self sortBySortTime:true isSort:false];
	}
}

/**
 *  圈子新消息的通知
 *
 *  @param notification notification description
 */
- (void)reloadCircleMsgData:(NSNotification *)notification {
	NSDictionary *userInfo = notification.userInfo;

	if (userInfo) {
		CircleBaseDataEntity *item = userInfo[SOCKET_NOTIFACATION_KEY_CIRCLE_BASEDATAENTITY];

		if ([item isKindOfClass:[CircleBaseDataEntity class]]) {
			[self sortBySortTime:YES isSort:YES];
		}
	}
	[self.tableView reloadData];
}

- (void)updateCircleTag:(NSNotification *)notification {
	if (isReloadData) [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CircleMainCell" owner:self options:nil] lastObject];
	return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleMainCell"];

	if (!cell) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"CircleMainCell" owner:self options:nil] lastObject];
		UIButton *btnMember = (UIButton *)[cell viewWithTag:6];
		[btnMember setBackgroundImage:[CommonUtil createImageWithColor:btnMember.backgroundColor] forState:UIControlStateNormal];
        
        UIButton *btnLocation = (UIButton *)[cell viewWithTag:7];
        [btnLocation setBackgroundImage:[CommonUtil createImageWithColor:btnLocation.backgroundColor] forState:UIControlStateNormal];
        
	}
	CircleEntity *item = dataSource[indexPath.row];

	RZWebImageView *ivCircleLogo = (RZWebImageView *)[cell viewWithTag:1];
	[ivCircleLogo showImageWithUrl:item.circleLogo];
	UILabel *lbCircleName = (UILabel *)[cell viewWithTag:2];
	lbCircleName.text = item.circleName;

	UIButton *btnNew = (UIButton *)[cell viewWithTag:2232];
	CircleBaseDataEntity *d = [CircleBaseDataEntity circleBaseDataWithCircleId:item.circleId];
    
	NSInteger newNum = 0;
    if (d) {
        newNum = d.chatNews + d.showNews + d.articleNews + d.applyNews;
    }

	btnNew.hidden = (newNum == 0);

    CircleSettingRemindEntity *sEntity = nil;
    NSString* circleId = [NSString stringWithFormat:@"%@", d.circleId];
    if ([dicRemind objectForKey:circleId]) {
        sEntity = [dicRemind objectForKey:circleId];
    }else{
        sEntity = [CircleSQL queryCircleSettingWithCircleId:d.circleId];
        if (sEntity) {
            [dicRemind setObject:sEntity forKey:circleId];
        }
    }
    
    if (newNum > 0) {
        if (sEntity.chatRemind){
            [btnNew showNewNum:newNum isShowDot:YES];
        }else {
            [btnNew showNewNum:newNum isShowDot:NO];
        }
    }
    
	UILabel *lbTime = (UILabel *)[cell viewWithTag:4];
    lbTime.text = [VeDateUtil sortTimeDateFormatter:item.chatTime];

	MLEmojiLabel *lbChat = (MLEmojiLabel *)[cell viewWithTag:5];
    
    NSString* noRemind = @"";
    if (sEntity.chatRemind && d.chatNews>0) {
        noRemind = [NSString stringWithFormat:@"[%@条] ",@(newNum)];
    }

	if (TTIsStringWithAnyText(item.chatUserName)) {
		if ([CIRCLE_CHAT_TYPE_IMG isEqualToString:item.chatLastSayType]) {
			lbChat.text = [NSString stringWithFormat:@"%@%@: [图片]",noRemind, item.chatUserName];
		} else if ([CIRCLE_CHAT_TYPE_VOICE isEqualToString:item.chatLastSayType]) {
			lbChat.text = [NSString stringWithFormat:@"%@%@: [语音]",noRemind, item.chatUserName];
		} else if ([CIRCLE_CHAT_TYPE_SYSTEM isEqualToString:item.chatLastSayType]) {
            NSString *chatLast = [CircleChatEntity simpleForAtParam:item.chatLast];
			lbChat.text = [NSString stringWithFormat:@"%@%@",noRemind, chatLast];
		} else if ([CIRCLE_CHAT_TYPE_JSON isEqualToString:item.chatLastSayType]) {
			lbChat.text = [NSString stringWithFormat:@"%@%@: 发送了一条消息",noRemind, item.chatUserName];
        } else if ([CIRCLE_CHAT_TYPE_TEXT isEqualToString:item.chatLastSayType]) {
			NSString *chatLast = [CircleChatEntity simpleForAtParam:item.chatLast];

			if (TTIsStringWithAnyText(item.chatUserName)) {
				NSDictionary *dic = [lbChat extractEmojiText:[NSString stringWithFormat:@"%@%@: %@",noRemind, item.chatUserName, chatLast] textFont:lbChat.font isNeedUrl:false isNeedPhoneNumber:false isNeedEmail:false isNeedAt:false isNeedPoundSign:false isNeedFullcode:false isNeedTjrAt:NO];
				[lbChat setEmojiTextWithDictionary:dic];
			} else {
				NSDictionary *dic = [lbChat extractEmojiText:chatLast textFont:lbChat.font isNeedUrl:false isNeedPhoneNumber:false isNeedEmail:false isNeedAt:false isNeedPoundSign:false isNeedFullcode:false isNeedTjrAt:NO];
				[lbChat setEmojiTextWithDictionary:dic];
			}
		} else {
			lbChat.text = [NSString stringWithFormat:@"%@当前版本暂不支持该消息",noRemind];
		}
	} else {
        if ([CIRCLE_CHAT_TYPE_SYSTEM isEqualToString:item.chatLastSayType]) {
            NSString *chatLast = [CircleChatEntity simpleForAtParam:item.chatLast];
            lbChat.text = [NSString stringWithFormat:@"%@%@",noRemind, chatLast];
        }else{
            lbChat.text = @"";
        }
	}
    
    UIImageView *notify = (UIImageView *)[cell viewWithTag:55];
    notify.hidden = !sEntity.chatRemind;
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:true];
	CircleEntity *item = dataSource[indexPath.row];
    if (item) {
        [self putValueToParamDictionary:CircleDict value:[NSString stringWithFormat:@"%@", item.circleId] forKey:@"circleId"];
        [self putValueToParamDictionary:CircleDict value:item.circleName forKey:@"circleName"];
        [self pageToOrBackWithName:@"CircleChatController"];
    }
}

- (IBAction)createAction:(id)sender {
	[self pageToOrBackWithName:@"CircleCreateViewController"];
}

- (IBAction)nearbyAction:(id)sender {
	[self pageToOrBackWithName:@"CircleInfoViewController"];
}

- (IBAction)searchAction:(id)sender {
    [self pageToOrBackWithName:@"CircleSearchViewController"];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [dicRemind removeAllObjects];
    [dicRemind release];
	[dataSource removeAllObjects];
	RELEASE(dataSource);
	[_tableView release];
	[_statusView release];
    [_tipsView release];
    [super dealloc];
}
@end
