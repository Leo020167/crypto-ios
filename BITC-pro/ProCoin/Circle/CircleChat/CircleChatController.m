//
//  CircleChatController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 11/13/15.
//  Copyright © 2015 淘金路. All rights reserved.
//

#import "CircleChatController.h"
#import "HPGrowingTextView.h"
#import "VeDateUtil.h"
#import "CommonUtil.h"
#import "UIButton+NewNum.h"
#import "MLEmojiLabel.h"

#import "CircleChatMsgToolView.h"
#import "CircleChatTableView.h"
#import "CircleSocket.h"
#import "CircleEntity.h"
#import "CircleSQL.h"
#import "TJRBaseTitleView.h"
#import "CircleChatExtendEntity.h"
#import "NetWorkManage+File.h"
#import "TJRBaseParserJson.h"
#import "CircleChatPictureView.h"
#import "CircleBaseDataEntity.h"
#import "LewPopupViewAnimationSpring.h"
#import "NetWorkManage+Circle.h"



#define MAX_TIMEOUT 60
#define PER_SECOND 6
#define DISPLAY_CHATNEWS_COUNT 10

@interface CircleChatController ()<UIGestureRecognizerDelegate,CircleChatMsgToolViewDelegate,CircleChatTableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    BOOL bReqFinished;
    NSMutableDictionary* reqDic;
    
    CircleChatPictureView* picView;
    NSTimer* timer;

    
    CGRect tableDefaultRect;
    id object;
    
    NSMutableDictionary* atDic;

}

@property (retain, nonatomic) IBOutlet UIButton *rightBtn;

@property (retain, nonatomic) IBOutlet UIButton *btnNewsSys;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (retain, nonatomic) IBOutlet CircleChatMsgToolView *msgToolView;
@property (retain, nonatomic) IBOutlet CircleChatTableView *tableView;
@property (retain, nonatomic) IBOutlet TJRBaseTitleView *baseTitleView;

@property (copy, nonatomic) NSString *circleId;
@property (copy, nonatomic) NSString *resendKey;
@property (retain, nonatomic) IBOutlet UIButton *btnNewBottom;
@property (retain, nonatomic) IBOutlet UIView *statusView;
@property (retain, nonatomic) IBOutlet UIButton *btnNewTop;

@end

@implementation CircleChatController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[CircleSocket shareCircleSocket] isClosed]) {
        [self connectStartToHost];
        [[CircleSocket shareCircleSocket] ping];
    }else{
        [self connectToHost];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (CGRectIsEmpty(tableDefaultRect)) {
        tableDefaultRect = _tableView.frame;
        _tableView.tableViewRect = tableDefaultRect;
    }
    
    CircleBaseDataEntity *item = [CircleSocket shareCircleSocket].circleDetail[self.circleId];
    if (item.chatNews > 0) {
        [self tableView:_tableView moreNewTop:item.chatNews];
    }
    [self showSysMsgWithCircleId:item];
    
    [self startTimer];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    object = [[UIView alloc]init];
    bReqFinished = YES;
    _msgToolView.delegate = self;
    _tableView.circleDelegate = self;
    reqDic = [[NSMutableDictionary alloc]init];
    atDic = [[NSMutableDictionary alloc]init];
    
    _baseTitleView.frame = CGRectMake(0, 0, CGRectGetWidth(phoneRectScreen), NAVIGATION_BAR_HEIGHT);
    _tableView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, CGRectGetWidth(phoneRectScreen) , CGRectGetHeight(phoneRectScreen) - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT);
    _msgToolView.frame = CGRectMake(0, CGRectGetHeight(phoneRectScreen) - IPHONEX_BOTTOM_HEIGHT - _msgToolView.frame.size.height, CGRectGetWidth(phoneRectScreen), _msgToolView.frame.size.height);
    
    // 系统通知处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dragBackStart) name:DragBackBegan object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dragBackStop) name:DragBackUp object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanData) name:DragBackEnd object:nil];
    
    // 收到通知就从数据库重新查询圈子信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCircleChatData:) name:SOCKET_NOTIFACATION_KEY_CIRCLE_CHAT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCircleRoleChange:) name:SOCKET_NOTIFACATION_KEY_CIRCLE_ROLE_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCircleMsgClear:) name:SOCKET_NOTIFACATION_KEY_CIRCLE_CHAT_CLEAR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memberTalkPermission:) name:[CircleSocket circleNotifacationKey:ReceiveModelCircleSpeakStatus] object:nil];
    
    // SOCKET连接处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectToHost) name:[CircleSocket notificationKeyWith:[CircleSocket class] name:DidConnectToHost] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStartToHost) name:[CircleSocket notificationKeyWith:[CircleSocket class] name:DidASDidDisconnect] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionRefused) name:[CircleSocket notificationKeyWith:[CircleSocket class] name:DidConnectionRefused] object:nil];

    NSString *paramsString = [self getValueFromModelDictionary:MSG_PARAMS forKey:MSG_PARAMS];
    if (TTIsStringWithAnyText(paramsString)) {//从消息进入
        NSDictionary *params = [CommonUtil jsonValue:paramsString];
        self.circleId = [NSString stringWithFormat:@"%@",params[@"circleId"]];
        NSString *circleName = params[@"circleName"];
        if (TTIsStringWithAnyText(circleName)) {
            _titleLabel.text = circleName;
        }
        [self putValueToParamDictionary:CircleDict value:self.circleId forKey:@"circleId"];
        [self removeModelDictionaryFromParamDictionary:MSG_PARAMS];
    } else if([self getValueFromModelDictionary:CircleDict  forKey:@"circleId"]){
        self.circleId = [self getValueFromModelDictionary:CircleDict  forKey:@"circleId"];
        NSString *circleName = [self getValueFromModelDictionary:CircleDict  forKey:@"circleName"];
        if (TTIsStringWithAnyText(circleName)) {
            _titleLabel.text = circleName;
        }
    }
    if (TTIsStringWithAnyText(self.circleId)) {
        [_tableView queryDataFromDB:self.circleId];
        [[CircleSocket shareCircleSocket] sendMSG:[[TJRCircleManager shareSingleNetWork] toCircleRoom:_circleId]];
        
        CircleBaseDataEntity *item = [CircleSocket shareCircleSocket].circleDetail[self.circleId];
        if (item.chatNews >= DISPLAY_CHATNEWS_COUNT) {
            //生成本地提示信息
            CircleChatExtendEntity *tmp = [[[CircleChatExtendEntity alloc]init]autorelease];
            tmp.sayType = CIRCLE_CHAT_TYPE_LOCAL;
            tmp.say = @"以下是您未读的内容";
            tmp.circleId = self.circleId;
            tmp.userId = ROOTCONTROLLER_USER.userId;
            tmp.userName = ROOTCONTROLLER_USER.name;
            [_tableView insertEntity:tmp index:item.chatNews];
        }
        
        item.bInChat = YES;//标记已经进入聊天页面
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched:)];
    [tapGestureRecognizer setDelegate:self];
    [_tableView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    
    
}

- (void)connectStartToHost{
    _statusView.hidden = NO;
    UILabel* label = [_statusView viewWithTag:400];
    label.text = @"连接中";
}

- (void)connectToHost{
    _statusView.hidden = YES;
}

- (void)connectionRefused{
    UILabel* label = [_statusView viewWithTag:400];
    label.text = @"连接拒绝";
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DragBackChange object:nil];
    [self closeTimer];
    [super viewDidDisappear:animated];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification{

    if ([CommonUtil getHomeViewTabBarIndex] == 0) {
        if ([[CircleSocket shareCircleSocket] isClosed]) {
            [self connectStartToHost];
            [[CircleSocket shareCircleSocket] ping];
        } else {
            [self connectToHost];
        }
    }
}

- (void)updateCircleChatData:(NSNotification *)notification {
    
    @synchronized(self){
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            CircleChatEntity *entity = userInfo[SOCKET_NOTIFACATION_KEY_CIRCLE_USERINFO];
            if (entity && [entity.circleId isEqualToString:self.circleId] ) {
                CircleChatExtendEntity *item = [CircleChatExtendEntity toExtendEntity:entity];
                CircleChatExtendEntity *tmp = [reqDic objectForKey:item.verifi];
                
                if (tmp && [item.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
                    [_tableView replaceEntity:item tmpEntity:tmp];
                    [reqDic removeObjectForKey:tmp.verifi];
                }else{
                    [_tableView insertEntity:item];
                }
            }
        }
    }
    
}

- (void)reloadCircleRoleChange:(NSNotification *)notification {
    CircleBaseDataEntity *item = [CircleSocket shareCircleSocket].circleDetail[self.circleId];
    if ([[NSString stringWithFormat:@"%@",item.userId] isEqualToString:ROOTCONTROLLER_USER.userId]) {
        [_msgToolView resetRole:[item isHostOrAdministrator]];
        if ([item isHostOrAdministrator]) {
            _msgToolView.userInteractionEnabled = YES;
            _msgToolView.alpha = 1;
            _msgToolView.textView.placeHolder = @"";
        }
    }
}

- (void)memberTalkPermission:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo) {
        if ([[userInfo objectForKey:CircleNotifyKeySuccess]boolValue]){
            NSDictionary *dic = [userInfo objectForKey:CircleNotifyKeyReceive];
            NSString* circleId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"circleId"]];
            BOOL bSay = [dic[@"speak"] boolValue];
            if ([circleId isEqualToString:self.circleId]) {
                CircleBaseDataEntity *item = [CircleSocket shareCircleSocket].circleDetail[circleId];
                if(!bSay || [item isHostOrAdministrator]){
                    _msgToolView.userInteractionEnabled = YES;
                    _msgToolView.alpha = 1;
                    _msgToolView.textView.placeHolder = @"";                    
                } else {
                    _msgToolView.userInteractionEnabled = NO;
                    _msgToolView.alpha = 0.6;
                    NSString* msg = dic[@"tip"];
                    _msgToolView.textView.placeHolder = msg;
                }
            }
        }
    }
}


- (void)reloadCircleMsgClear:(NSNotification *)notification {
    [_tableView clearTableData];
    [self cleanData];
    [self tableView:_tableView moreNewTop:0];
}

- (void)showSysMsgWithCircleId:(CircleBaseDataEntity *)item {
    [_btnNewsSys showNewNum:(item.applyNews + item.articleNews + item.showNews)];
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (![touch.view isKindOfClass:[MLEmojiLabel class]]){
        return YES;
    }else{
        return NO;
    }
}
- (void)backgroundTouched:(UIGestureRecognizer*) recognizer{
    if(([recognizer isKindOfClass:[UIPanGestureRecognizer class]] && recognizer.state == UIGestureRecognizerStateBegan) ||
       ([recognizer isKindOfClass:[UITapGestureRecognizer class]] && recognizer.state == UIGestureRecognizerStateEnded)) {
        [_msgToolView resignKeyboard];
    }
}

- (IBAction)leftButtonClicked:(id)sender {
    [self goBack];
}

- (void)cleanData{
    CircleBaseDataEntity *item = [CircleSocket shareCircleSocket].circleDetail[self.circleId];
    item.chatNews = 0;
    [CircleSQL updateUserNewsChat:item];
}

- (IBAction)rightButtonClicked:(id)sender {
    if (TTIsStringWithAnyText(_circleId)) {
        [self resignKeyboard];
        
        [self putValueToParamDictionary:CircleDict value:_circleId forKey:@"circleId"];
        [self pageToOrBackWithName:@"CircleInfoViewController"];
    }
}

- (IBAction)buttonNewBottomClicked:(id)sender {
    
    _tableView.moreBottom = 0;
    
    CGRect frame = self.btnNewBottom.frame;
    frame.origin.x = self.view.frame.size.width;
    [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.btnNewBottom.frame = frame;
        
    }completion:^(BOOL finished){
        [_tableView scrollToBottom:YES];
    }];

}

- (IBAction)buttonNewTopClicked:(id)sender {
    
    _tableView.moreTop = 0;
    
    CGRect frame = self.btnNewTop.frame;
    frame.origin.x = self.view.frame.size.width;
    [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.btnNewTop.frame = frame;
        
    }completion:^(BOOL finished){
        [_tableView scrollToTop:YES];
    }];
}

- (void)btnNewTopAutoDisappear{
    
    self.btnNewTop.enabled = NO;
    _tableView.moreTop = 0;
    
    CGRect frame = self.btnNewTop.frame;
    frame.origin.x = self.view.frame.size.width;
    [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.btnNewTop.frame = frame;
    }completion:^(BOOL finished){
        self.btnNewTop.enabled = YES;
    }];
}

#pragma mark - alert view 回调
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.cancelButtonIndex == buttonIndex){
        return;
    }
}

#pragma mark -
#pragma mark msgToolView deleagte
- (void)msgToolView:(CircleChatMsgToolView *)toolView sendClicked:(HPGrowingTextView*)textView msgOrFileName:(NSString *)msgOrFileName type:(NSString*)type length:(NSUInteger)length{

    
    CircleChatExtendEntity *tmp = [[[CircleChatExtendEntity alloc]init]autorelease];//构建临时的item
    NSString* code = [NSString stringWithFormat:@"%@%@",[VeDateUtil currentDateTimeIntervalToString],[CommonUtil generateRandomCode:7]];
    
    if([type isEqualToString:CIRCLE_CHAT_TYPE_VOICE]){
        
        if (!bReqFinished || msgOrFileName.length<=0) return;
        bReqFinished = NO;
        
        [[NetWorkManage shareSingleNetWork] reqUploadChatVideoFile:self videoFile:msgOrFileName verify:code finishedCallback:@selector(reqSendFileFinished:) failedCallback:@selector(reqSendFileFailed:)];
        
        tmp.sayType = CIRCLE_CHAT_TYPE_VOICE;
        tmp.voiceLength = [NSString stringWithFormat:@"%lu",(unsigned long)length];
        tmp.say = msgOrFileName;
        
    }else if([type isEqualToString:CIRCLE_CHAT_TYPE_IMG]){
        
        
        if (!bReqFinished || msgOrFileName.length<=0) return;
        bReqFinished = NO;
        
        NSString *path = [CommonUtil TTPathForDocumentsResourceEtag:msgOrFileName];
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
        
        [[NetWorkManage shareSingleNetWork] reqUploadChatImgFile:self imageFile:msgOrFileName verify:code finishedCallback:@selector(reqSendFileFinished:) failedCallback:@selector(reqSendFileFailed:)];
        
        
        tmp.imgSize = image.size;
        tmp.sayType = CIRCLE_CHAT_TYPE_IMG;
        tmp.say = msgOrFileName;
        
    }else{
        
        if ([[msgOrFileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
            //文本中只有空格
            [self showToast:@"不能发送空白消息"];
            textView.text = @"";
            [toolView resignKeyboard];
            return;
        }
        
        NSString* str = msgOrFileName;
        for (NSString* key in [atDic allKeys]) {
            NSString* value = [NSString stringWithFormat:@"%@",[atDic objectForKey:key]];
            str = [str stringByReplacingOccurrencesOfString:key withString:value];
        }
        [atDic removeAllObjects];
        
        [[CircleSocket shareCircleSocket] sendMSG:[[TJRCircleManager shareSingleNetWork] sendCircleChatMsg:str circleId:self.circleId code:code]];
        
        tmp.say = str;
        tmp.sayType = CIRCLE_CHAT_TYPE_TEXT;
        textView.text = @"";
    }

    tmp.isUploading = YES;
    tmp.userId = ROOTCONTROLLER_USER.userId;
    tmp.userName = ROOTCONTROLLER_USER.name;
    tmp.verifi = code;
    tmp.createTime = [VeDateUtil getNowTime];
    [_tableView insertEntity:tmp];
    
    @synchronized(self){
        [reqDic setObject:tmp forKey:tmp.verifi];
    }
    
}

- (void)msgToolView:(CircleChatMsgToolView *)toolView keyboardReset:(CGRect)keyboardRect{
    
    _tableView.moreBottom = 0;
    [self tableView:_tableView moreNewBottom:0];
    
    float vHeight = [_tableView getTableViewVisibleHeight];

    keyboardRect = [self.view convertRect:keyboardRect fromView:toolView];
    
    if (vHeight > keyboardRect.origin.y || fabs(vHeight - keyboardRect.origin.y) < 50) {
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, keyboardRect.origin.y - _tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height);
        [_tableView scrollToBottom:NO];
    }else if (keyboardRect.origin.y > _tableView.frame.size.height) {
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, tableDefaultRect.origin.y, _tableView.frame.size.width, tableDefaultRect.size.height);
    }else{
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, tableDefaultRect.origin.y, _tableView.frame.size.width, keyboardRect.origin.y);
    }
    _tableView.tableViewRect = _tableView.frame;

}

- (void)msgToolView:(CircleChatMsgToolView *)toolView willBecomeFirstResponder:(HPGrowingTextView*)textView{
    [_tableView scrollToBottom:YES];
}

- (void)msgToolView:(CircleChatMsgToolView *)toolView keyboardClicked:(NSString *)key{
    
    if ([key isEqualToString:@"@"]) {
    }
}

- (void)reqSendFileFinished:(id)result{
    bReqFinished = YES;
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init] autorelease];
    
    if ([jsonParser parseBaseIsOk:result]) {
        NSDictionary *dataDic = [result objectForKey:@"data"];
        NSString* verify = [jsonParser stringParser:dataDic name:@"verify"];
        
        CircleChatExtendEntity *tmp = [reqDic objectForKey:verify];
        if (tmp) {
            if ([tmp.sayType isEqualToString:CIRCLE_CHAT_TYPE_IMG]) {
                NSString* fileUrl = [((NSArray*)[dataDic objectForKey:@"imageUrlList"]) firstObject];
                NSString* height = [NSString stringWithFormat:@"%.0f",tmp.imgSize.height];
                NSString* width = [NSString stringWithFormat:@"%.0f",tmp.imgSize.width];
                [[CircleSocket shareCircleSocket] sendMSG:[[TJRCircleManager shareSingleNetWork] sendCircleChatImg:self.circleId code:tmp.verifi fileUrl:fileUrl imgWidth:width imgHeight:height]];
                
            }else if ([tmp.sayType isEqualToString:CIRCLE_CHAT_TYPE_VOICE]) {
                NSString* fileUrl = [((NSArray*)[dataDic objectForKey:@"fileUrlList"]) firstObject];
                [[CircleSocket shareCircleSocket] sendMSG:[[TJRCircleManager shareSingleNetWork] sendCircleChatVoice:self.circleId code:tmp.verifi fileUrl:fileUrl second:tmp.voiceLength]];
            }
        }
        [_msgToolView cleanRecordData];
    }else{
        NSString* str = @"发送失败";
        if ([result objectForKey:@"msg"]) {
            str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
        }
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_ERROR];
    }
}

- (void)reqSendFileFailed:(id)result{
    bReqFinished = YES;
    [self showProgressHUDCompleteMessage:@"W.W.C.T提示" detailsMessage:@"发送失败" imageName:HUD_ERROR];
}

- (void)msgToolView:(CircleChatMsgToolView *)toolView box:(NSString *)box{
}

- (void)msgToolView:(CircleChatMsgToolView *)toolView kline:(NSString *)kline{
}

- (void)msgToolViewOnPaper:(CircleChatMsgToolView *)toolView{
}

- (void)msgToolViewOnAReward:(CircleChatMsgToolView *)toolView{
}

- (void)msgToolViewOnCard:(CircleChatMsgToolView *)toolView{
}

#pragma mark -
#pragma mark tableView deleagte
- (void)tableView:(CircleChatTableView *)tableView imageViewsTouched:(NSMutableDictionary*)touchViews url:(NSString*)url{
    [self resignKeyboard];
    
    if (url.length<=0) return;
    
    if (!picView) {
        picView = [[CircleChatPictureView alloc] init];
    }
    NSMutableArray* picArr = [[[NSMutableArray alloc]init]autorelease];
    NSArray* arr = [CircleSQL queryCircleChatPictureWithCircleId:self.circleId];
    NSInteger index = -1;
    for (int i = 0; i< [arr count]; i++) {
        CircleChatEntity *entity = [arr objectAtIndex:i];
        CircleChatExtendEntity *item = [CircleChatExtendEntity toExtendEntity:entity];
        [picArr addObject:item.say];
        
        if ([item.say isEqualToString:url]) {
            index = i;
        }
    }
    if (index>=0) {
        [picView showPicView:picArr pageIndex:index touchViews:touchViews];
    }

}

- (void)tableView:(CircleChatTableView *)tableView buttonErrorClicked:(NSString*)key{
    self.resendKey = key;
    [self resendClicked];
}

- (void)tableView:(CircleChatTableView *)tableView moreNewBottom:(NSInteger)count{
    
    if (count>0) {
        [self.btnNewBottom setTitle:[NSString stringWithFormat:@"%ld条新消息",count] forState:UIControlStateNormal];
        CGRect frame = self.btnNewBottom.frame;
        frame.origin.x = self.view.frame.size.width - self.btnNewBottom.frame.size.width;
        [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.btnNewBottom.frame = frame;
            
        }completion:^(BOOL finished){
            [self cleanData];
        }];
    }else{
        CGRect frame = self.btnNewBottom.frame;
        frame.origin.x = self.view.frame.size.width;
        [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.btnNewBottom.frame = frame;
            
        }completion:^(BOOL finished){
        }];
    }
}

- (void)tableView:(CircleChatTableView *)tableView moreNewTop:(NSInteger)count{
    
    if (count>0) {
        self.btnNewTop.enabled = NO;
        
        [self.btnNewTop setTitle:[NSString stringWithFormat:@"%ld条新消息",count] forState:UIControlStateNormal];
        CGRect frame = self.btnNewTop.frame;
        frame.origin.x = self.view.frame.size.width - self.btnNewTop.frame.size.width;
        [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.btnNewTop.frame = frame;

        }completion:^(BOOL finished){
            
            if (count < DISPLAY_CHATNEWS_COUNT) {
                [self performSelector:@selector(btnNewTopAutoDisappear) withObject:nil afterDelay:2.0];
            }else{
                self.btnNewTop.enabled = YES;
            }
            [self cleanData];
        }];
    }else{
        CGRect frame = self.btnNewTop.frame;
        frame.origin.x = self.view.frame.size.width;
        [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.btnNewTop.frame = frame;
            
        }completion:^(BOOL finished){
        }];
    }
}

- (void)tableView:(CircleChatTableView *)tableView deleteItem:(NSInteger)index{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SOCKET_NOTIFACATION_KEY_CIRCLE object:nil userInfo:nil];
}

- (void)tableView:(CircleChatTableView *)tableView linkClicked:(NSString *)url{
    [self resignKeyboard];
    
    if ([url rangeOfString:@"http"].location == NSNotFound) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = url;
    [ROOTCONTROLLER.navigationController pushViewController:web animated:YES];
}
 
- (void)tableView:(CircleChatTableView *)tableView fullcodeClicked:(NSString *)fullcode{
    [self resignKeyboard];
}

- (void)tableView:(CircleChatTableView *)tableView atClicked:(NSString *)userId{
    [self resignKeyboard];
    
}

- (void)tableView:(CircleChatTableView *)tableView setupAtUser:(NSString *)userId name:(NSString*)name{

    NSString* str = [self jsonAtUser:userId name:name];
    NSString* key = [NSString stringWithFormat:@"@%@",name];
    
    [atDic setObject:str forKey:key];
    [_msgToolView.textView insertText:[NSString stringWithFormat:@"%@ ",key]];
    [_msgToolView.textView becomeFirstResponder];
}

- (NSString*)tableView:(CircleChatTableView *)tableView paramsContent:(NSString *)content{

    [atDic removeAllObjects];
    NSString* str = [CircleChatEntity simpleForAtParam:content atDic:atDic];
    return str;
}

- (void)tableView:(CircleChatTableView *)tableView scrollViewDidScroll:(UIScrollView *)scrollView{
    [self resignKeyboard];
}

- (void)tableView:(CircleChatTableView *)tableView headViewClicked:(NSString *)userId name:(NSString*)name{
    [self resignKeyboard];
    if (TTIsStringWithAnyText(userId)) {
        [self putValueToParamDictionary:PersonalDict value:userId forKey:@"targetUid"];
        [self pageToViewControllerForName:@"PersonViewController"];
    }
}

- (void)resignKeyboard{
    if([_msgToolView checkKeyboardUp]){
        [_msgToolView resignKeyboard];
    }
}

- (void)dragBackStart{
    _msgToolView.bDragBack = YES;
}

- (void)dragBackStop{
    _msgToolView.bDragBack = NO;
}

#pragma mark - resend
- (void)resendClicked{
    UIActionSheet *reSendActSheet = [[UIActionSheet alloc] initWithTitle:@"发送出现错误，您可以尝试:" delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:@"重发", nil];
    [reSendActSheet showInView:self.view];
    [reSendActSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != actionSheet.cancelButtonIndex){
        if ([@"重发" isEqualToString:[actionSheet buttonTitleAtIndex:buttonIndex]]){
            
            @synchronized(self){
                CircleChatExtendEntity *item = [reqDic objectForKey:self.resendKey];
                item.timeout = 0;
                [self resend:item];
            }
            
        }
        
    }
}

- (void)resend:(CircleChatExtendEntity *)item{

    if([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_VOICE]){
        
         [[NetWorkManage shareSingleNetWork] reqUploadChatVideoFile:self videoFile:item.say verify:item.verifi finishedCallback:@selector(reqSendFileFinished:) failedCallback:@selector(reqSendFileFailed:)];
        
    }else if([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_IMG]){
        
        [[NetWorkManage shareSingleNetWork] reqUploadChatImgFile:self imageFile:item.say verify:item.verifi finishedCallback:@selector(reqSendFileFinished:) failedCallback:@selector(reqSendFileFailed:)];
        
    }else{
        
        [[CircleSocket shareCircleSocket] sendMSG:[[TJRCircleManager shareSingleNetWork] sendCircleChatMsg:item.say circleId:self.circleId code:item.verifi]];
    }
    item.isUploading = YES;
    item.isUploadFailed = NO;
    [_tableView reloadData];
    
}

- (void)tableView:(CircleChatTableView *)tableView contentClicked:(NSString *)pview params:(NSString*)params {
    [self resignKeyboard];
    
    [self putValueToParamDictionary:MSG_PARAMS value:params forKey:MSG_PARAMS];
    [self pageToOrBackWithName:pview];
}

#pragma mark - 定时器 统计超时
- (void)startTimer{
    [self closeTimer];
    if (timer == nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:PER_SECOND target:self selector:@selector(timeoutCalculater) userInfo:nil repeats:YES];
    }
}

- (void)closeTimer{
    @synchronized(timer) {
        if (timer && timer.isValid) {
            [timer invalidate];
            timer = nil;
        }
    }
}

- (void)timeoutCalculater{
    
    if ([reqDic allKeys].count>10) return;
    
    for (NSString *key in [reqDic allKeys]) {
        CircleChatExtendEntity *item = [reqDic objectForKey:key];
        if (item.isUploading) {
            item.timeout = item.timeout + PER_SECOND;
        }
        
        if (![[CircleSocket shareCircleSocket] isClosed]) {
            @synchronized(self){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (item.isResend) {
                        item.isResend = NO;
                        [self resend:item];
                    }
                });
            }
        }else{ 
            item.isResend = YES;
            [[CircleSocket shareCircleSocket] ping];
        }
        
        if ((item.timeout == MAX_TIMEOUT && !item.isUploadFailed)) {
            item.isUploadFailed = YES;
            item.isUploading = NO;
            [_tableView reloadData];
        }
    }
    
}


- (NSString*)jsonAtUser:(NSString*)userId name:(NSString*)name{
    
    NSString* params = [NSString stringWithFormat:@"{\\\"userId\\\":%@}",userId];
    NSString* json = [NSString stringWithFormat:@"{\"type\":%@,\"params\":\"%@\"}",@"1",params];
    NSString* str = [NSString stringWithFormat:@"@(@%@)「%@」",name,json];
    
    return str;
}


#pragma mark - circlePeopleSelecter delegate
- (void)circlePeopleSelecterRightButtonClicked:(id)sender userId:(NSString*)userId nameStr:(NSString*)nameStr{
    
    NSString* str = [self jsonAtUser:userId name:nameStr];
    
    NSString* key = [NSString stringWithFormat:@"@%@",nameStr];
    
    [atDic setObject:str forKey:key];
    [_msgToolView.textView insertText:[NSString stringWithFormat:@"%@ ",key]];

}

- (void)dealloc {
    
    CircleBaseDataEntity *item = [CircleSocket shareCircleSocket].circleDetail[self.circleId];
    item.bInChat = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [reqDic removeAllObjects];
    [reqDic release];
    [atDic removeAllObjects];
    [atDic release];
    [_circleId release];
    [_msgToolView release];
    [_tableView release];
    [timer release];
    [_btnNewBottom release];
    [_statusView release];
    [_titleLabel release];
    [_btnNewsSys release];
    [_rightBtn release];
    [_btnNewTop release];
    [super dealloc];
}

@end
