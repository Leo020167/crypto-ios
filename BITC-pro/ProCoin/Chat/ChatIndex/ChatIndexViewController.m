//
//  ChatIndexViewController.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-12.
//  Copyright (c) 2012年 淘金路. All rights reserved.
//

#import "ChatIndexViewController.h"
#import "CommonUtil.h"
#import "CircleSocket.h"
#import "TJRHeadView.h"
#import "VeDateUtil.h"
#import "NetWorkManage+Circle.h"
#import "PrivateChatSQL.h"
#import "PrivateChatDataEntity.h"
#import "MLEmojiLabel.h"
#import "CircleChatEntity.h"
#import "ChatUtil.h"
#import "UIButton+NewNum.h"
#import "CircleSQL.h"

@interface ChatIndexViewController (){
    NSMutableArray* tableData;
    BOOL bReqFinished;
}
@property (retain, nonatomic) IBOutlet UIView *tipsView;
@property (retain, nonatomic) IBOutlet UIView *statusView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ChatIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    tableData = [[NSMutableArray alloc] init];
    bReqFinished = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectToHost) name:[CircleSocket notificationKeyWith:[CircleSocket class] name:DidConnectToHost] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStartToHost) name:[CircleSocket notificationKeyWith:[CircleSocket class] name:DidASDidDisconnect] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionRefused) name:[CircleSocket notificationKeyWith:[CircleSocket class] name:DidConnectionRefused] object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadChatMsgClear:) name:SOCKET_NOTIFACATION_KEY_PRIVATE_CHAT_CLEAR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePrivateChatData:) name:SOCKET_NOTIFACATION_KEY_PRIVATE_CHAT object:nil];
    
    [CommonUtil setExtraCellLineHidden:_tableView];
    
    [self queryChatDataFromDB];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[CircleSocket shareCircleSocket] isClosed]) {
        [self connectStartToHost];
        [[CircleSocket shareCircleSocket] ping];
    } else {
        [self connectToHost];
    }
    
    BOOL reload = NO;
    if ([self getValueFromModelDictionary:ChatDict forKey:@"reloadIndexData"]) {
        reload = YES;
        [self removeParamFromModelDictionary:ChatDict forKey:@"reloadIndexData"];
    }
    
    if (tableData == 0 || reload) {
        [self queryChatDataFromDB];
    }else{
        [tableData sortUsingSelector:@selector(compareChatTimeByDes:)];
        [_tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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

- (void)applicationDidBecomeActive:(NSNotification *)notification{
    
    if ([CommonUtil getHomeViewTabBarIndex] == 4) {
        if ([[CircleSocket shareCircleSocket] isClosed]) {
            [self connectStartToHost];
            [[CircleSocket shareCircleSocket] ping];
        } else {
            [self connectToHost];
        }
    }
}

- (void)updatePrivateChatData:(NSNotification *)notification {
    
    @synchronized(self){
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            CircleChatEntity *entity = userInfo[SOCKET_NOTIFACATION_KEY_PRIVATE_USERINFO];
            if (entity) {
                PrivateChatDataEntity * item = nil;
                if ([[CircleSocket shareCircleSocket].privateDetail objectForKey:entity.chatTopic]) {
                    item = [[CircleSocket shareCircleSocket].privateDetail objectForKey:entity.chatTopic];
                }else{
                    item = [[[PrivateChatDataEntity alloc]init]autorelease];
                    item.userId = entity.userId;
                    item.headurl = entity.headUrl;
                    item.name = entity.userName;
                    item.chatNews = 1;
                    [[CircleSocket shareCircleSocket].privateDetail setObject:item forKey:entity.chatTopic];
                    [tableData addObject:item];
                }
                item.chatTopic = entity.chatTopic;
                item.content = entity.say;
                item.sayType = entity.sayType;
                item.mark = entity.mark;
                item.createTime = entity.createTime;
                item.isPush = entity.isPush;
            }
            if ([[ROOTCONTROLLER.navigationController.viewControllers lastObject] isKindOfClass:[self class]]) {
                [tableData sortUsingSelector:@selector(compareChatTimeByDes:)];
                [_tableView reloadData];
            }
        }
    }
}

- (IBAction)gobackPressed:(id)sender {
    [self goBack];
}

#pragma mark - 从数据库中查询圈子信息
- (void)queryChatDataFromDB {

    NSArray *chatArray = [PrivateChatSQL queryPrivateChatInfo];
    
    if (chatArray) {
        [[CircleSocket shareCircleSocket].privateDetail removeAllObjects];
        
        for (PrivateChatDataEntity *item in chatArray) {
            if (TTIsStringWithAnyText(item.chatTopic)) {
                [[CircleSocket shareCircleSocket].privateDetail setObject:item forKey:item.chatTopic];
            }
        }
        
        [tableData removeAllObjects];
        [tableData addObjectsFromArray:chatArray];
    }
    [_tableView reloadData];

    if (tableData.count>0) {
        _tipsView.hidden = YES;
        _tableView.hidden = NO;
    }else {
        _tipsView.hidden = NO;
        _tableView.hidden = YES;
    }
}

- (void)reloadChatMsgClear:(NSNotification *)notification {
    [tableData removeAllObjects];
    [_tableView reloadData];
}

#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatIndexCell" owner:self options:nil] lastObject];
    CGFloat height = cell.frame.size.height;
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"ChatIndexCellIdentifier"];
    if(cell == nil){
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ChatIndexCell" owner:nil options:nil] lastObject];
    }
    
    PrivateChatDataEntity *item = [tableData objectAtIndex:[indexPath row]];
    
    TJRHeadView *headImageView = (TJRHeadView *)[cell viewWithTag:100];
    [headImageView showImageViewWithURL:item.headurl canTouch:YES userid:item.userId isCornerRadius:NO userLevel:item.userLevel];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    nameLabel.text = item.name;

    UILabel *timeLable = (UILabel *)[cell viewWithTag:103];
    
    MLEmojiLabel *lbChat = (MLEmojiLabel *)[cell viewWithTag:102];
    
    if (!TTIsStringWithAnyText(item.sayType)) {
        lbChat.text = @"";
    }else if ([CIRCLE_CHAT_TYPE_IMG isEqualToString:item.sayType]) {
        lbChat.text = [NSString stringWithFormat:@"[图片]"];
    } else if ([CIRCLE_CHAT_TYPE_VOICE isEqualToString:item.sayType]) {
        lbChat.text = [NSString stringWithFormat:@"[语音]"];
    }   else if ([CIRCLE_CHAT_TYPE_SYSTEM isEqualToString:item.sayType]) {
        NSString *chatLast = [CircleChatEntity simpleForAtParam:item.content];
        lbChat.text = [NSString stringWithFormat:@"%@", chatLast];
    } else if ([CIRCLE_CHAT_TYPE_JSON isEqualToString:item.sayType]) {
        lbChat.text = [NSString stringWithFormat:@"[消息]"];
    } else if ([CIRCLE_CHAT_TYPE_TEXT isEqualToString:item.sayType]) {
        NSString *chatLast = [CircleChatEntity simpleForAtParam:item.content];
        NSDictionary *dic = [lbChat extractEmojiText:chatLast textFont:lbChat.font isNeedUrl:false isNeedPhoneNumber:false isNeedEmail:false isNeedAt:false isNeedPoundSign:false isNeedFullcode:false isNeedTjrAt:NO];
        [lbChat setEmojiTextWithDictionary:dic];
    } else {
        lbChat.text = [NSString stringWithFormat:@"[新的消息]，当前版本暂不支持"];
    }
    
    timeLable.text = [VeDateUtil dateFormatter:item.createTime];
    
    UIButton *btnDot = (UIButton *)[cell viewWithTag:105];
    [btnDot showNewNum:item.chatNews];
    
    UIImageView *notify = (UIImageView *)[cell viewWithTag:104];
    notify.hidden = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PrivateChatDataEntity *item = tableData[indexPath.row];
    if (item && TTIsStringWithAnyText(item.chatTopic)) {
        [self putValueToParamDictionary:ChatDict value:[NSString stringWithFormat:@"%@",item.chatTopic] forKey:@"chatTopic"];
        [self putValueToParamDictionary:ChatDict value:item.name forKey:@"userName"];
        [self putValueToParamDictionary:ChatDict value:item.userId forKey:@"taUserId"];
        [self pageToOrBackWithName:@"ChatViewController"];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    PrivateChatDataEntity *item = tableData[indexPath.row];
    if (item && TTIsStringWithAnyText(item.chatTopic)) {
        [PrivateChatSQL deletePrivateTopic:item.chatTopic];
        [CircleSQL clearPrivateChatWithChatTopic:item.chatTopic];
        [[CircleSocket shareCircleSocket].privateDetail removeObjectForKey:item.chatTopic];
        [tableData removeObjectAtIndex:row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
}


- (void)dealloc {
    [tableData release];
    [_tableView release];
    [_statusView release];
    [_tipsView release];
    [super dealloc];
}
@end
