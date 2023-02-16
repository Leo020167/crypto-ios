//
//  CircleJoinViewController.m
//  TJRtaojinroad
//
//  Created by Wgh on 15-3-26.
//  Copyright (c) 2015年 Redz. All rights reserved.
//

#import "CircleJoinViewController.h"
#import "RZWebImageView.h"
#import "NetWorkManage+Circle.h"
#import "CommonUtil.h"
#import "CircleEntity.h"
#import "TJRBaseParserJson.h"
#import "UIImage+Size.h"
#import "CircleMemberEntity.h"

#define HEADER_BG_HEIGHT    120.0

@interface CircleJoinViewController (){

    BOOL bReqFinished;
    BOOL bLoadListFinished;
    
    NSMutableArray *tableData;
    
    NSInteger selectRow;
    BOOL bIsStateBarWhite;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet RZWebImageView *ivCircleBG;
@property (retain, nonatomic) IBOutlet UIButton *btnSend;

@property (copy, nonatomic) NSString *circleId;

@property (copy, nonatomic) NSString *articleAmount;
@property (copy, nonatomic) NSString *memberAmount;
@property (copy, nonatomic) NSString *showAmount;

@property (assign, nonatomic) NSInteger role;

@property (retain, nonatomic) IBOutlet UIView *statusBarView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutHeaderBGHeight;

@property (retain, nonatomic) CircleEntity* circleEntity;
@end

@implementation CircleJoinViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    tableData = [[NSMutableArray alloc]init];

    bReqFinished = YES;
    bIsStateBarWhite = YES;
    selectRow = -1;
    
    [_tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([self getValueFromModelDictionary:CircleDict  forKey:@"circleId"]){
        self.circleId = [self getValueFromModelDictionary:CircleDict  forKey:@"circleId"];
        if (TTIsStringWithAnyText(_circleId)) {
            [self reqCircleData:_circleId];
        }
        [self removeParamFromModelDictionary:CircleDict forKey:@"circleId"];
    }
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return bIsStateBarWhite ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

#pragma mark - 请求圈子数据
- (void)reqCircleData:(NSString*)circleId{
    
    if (bReqFinished) {
        bReqFinished = NO;
        [[NetWorkManage shareSingleNetWork] reqCircleOppGet:self circleId:circleId finishedCallback:@selector(requestCircleFinish:) failedCallback:@selector(requestCircleFalid:)];
    }
}

- (void)requestCircleFinish:(NSDictionary *)result {
    
    bReqFinished = YES;
    bLoadListFinished = YES;
    [self dismissProgress];
    
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init]autorelease];
    
    NSDictionary* json = [result objectForKey:@"data"];
    
    if ([jsonParser parseBaseIsOk:result]) {
        
        for (NSString *key in [json keyEnumerator]) {
            
            if ([key isEqualToString:@"circle"]) {
                NSDictionary *dic = [json objectForKey:key];
                CircleEntity* item = [[[CircleEntity alloc]initWithJson:dic]autorelease];
                self.circleEntity = item;
            }
            
            if ([key isEqualToString:@"circleConfig"]) {
                NSDictionary *dic = [json objectForKey:key];
                self.articleAmount = [jsonParser stringParser:dic name:@"articleAmount"];
                self.memberAmount = [jsonParser stringParser:dic name:@"memberAmount"];
                self.showAmount = [jsonParser stringParser:dic name:@"showAmount"];
            }
            
            if ([key isEqualToString:@"circleRole"]) {
                NSDictionary *dic = [json objectForKey:key];
                self.role = [jsonParser integerParser:dic name:@"role"];
            }
        }
        
        [_ivCircleBG showImageWithUrl:_circleEntity.circleBg];
        [_tableView reloadData];
    }
    [_btnSend setTitle:(_role!=CRICLE_ROLE_ILLEGAL?@"您已加入该圈子":@"申请入圈") forState:UIControlStateNormal];
    _btnSend.enabled = (_role!=CRICLE_ROLE_ILLEGAL?NO:YES);
}

- (void)requestCircleFalid:(NSError *)error {
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - 请求入圈
- (void)requestData:(NSString*)str
{
    if(bReqFinished)
    {
        bReqFinished = NO;
        self.btnSend.enabled = NO;
        [self showProgressDefaultText];
        
        [[NetWorkManage shareSingleNetWork] reqCircleApplyJoin:self circleId:_circleId reason:str finishedCallback:@selector(reqDataFinished:) failedCallback:@selector(reqDataFailed:) ];
    }
}

- (void)reqDataFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    self.btnSend.enabled = YES;
    
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init]autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    if ([jsonParser parseBaseIsOk:result]) {
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_SUCCEED];
        [self performSelector:@selector(goHomeController) withObject:Nil afterDelay:1.0];
        self.btnSend.enabled = NO;
        self.view.userInteractionEnabled = NO;
        self.canDragBack = NO;
    }else{
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_ERROR];
    }
}

- (void)reqDataFailed:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    self.btnSend.enabled = YES;
    [self showProgressHUDCompleteMessage:@"提交失败" detailsMessage:@"" imageName:HUD_ERROR];
}

- (void)goHomeController{
    [self goBackToViewControllerForName:@"HomeViewController" animated:YES];
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleJoinHeaderView" owner:self options:nil] lastObject];
        
        RZWebImageView *ivCircleLogo = (RZWebImageView *)[header viewWithTag:100];
        [ivCircleLogo showImageWithUrl:_circleEntity.circleLogo];
        
        UILabel* lbCircleName = (UILabel *)[header viewWithTag:101];
        lbCircleName.text = _circleEntity.circleName;
        
        UILabel* lbCircleId = (UILabel *)[header viewWithTag:102];
        lbCircleId.text = [NSString stringWithFormat:@"（圈子ID：%@）", _circleEntity.circleId];
        
        UILabel* lbBrief = (UILabel *)[header viewWithTag:103];
        lbBrief.text = [NSString stringWithFormat:@"简介：%@", _circleEntity.brief];

        UILabel* lbReviewState = (UILabel *)[header viewWithTag:104];
        if (_circleEntity.reviewState == 2) {
            lbReviewState.text = @"审核不通过";
        } else if (_circleEntity.reviewState == 0) {
            lbReviewState.text = NSLocalizedStringForKey(@"审核中");
        } else {
            lbReviewState.text = @"";
        }
        
        UIButton *btnBack = (UIButton *)[header viewWithTag:50];
        [btnBack addTarget:self action:@selector(buttonBackClicked:) forControlEvents:UIControlEventTouchUpInside];

        return header;
    }else if (section == 1) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleJoinOptHeaderView" owner:self options:nil] lastObject];
        
        RZWebImageView *ivCircleLogo = (RZWebImageView *)[header viewWithTag:100];
        [ivCircleLogo showImageWithUrl:_circleEntity.createUserHeadurl];
        
        UILabel* lbUserName = (UILabel *)[header viewWithTag:101];
        lbUserName.text = _circleEntity.createUserName;
        
        UILabel* lbMemberAmount = (UILabel *)[header viewWithTag:102];
        lbMemberAmount.text = [NSString stringWithFormat:@"共%@名成员",_circleEntity.memberAmount];
        
        return header;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleJoinHeaderView" owner:self options:nil] lastObject];
        CGFloat height = header.frame.size.height;
        CGSize size = [CommonUtil getPerfectSizeByText:_circleEntity.brief andFontSize:15.0f andWidth:phoneRectScreen.size.width - 50];
        height = height + size.height - 18;
        if (CURRENT_DEVICE_VERSION < 11.0) height += STATUS_BAR_HEIGHT;
        return height;
    }else if (section == 1) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleJoinOptHeaderView" owner:self options:nil] lastObject];
        return header.frame.size.height;
    }
    return 0.00001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 0;
    }
    return 2.50001f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)buttonBackClicked:(id)sender{
    [self goBack];
}

- (IBAction)buttonJoinClicked:(id)sender{
    if (TTIsStringWithAnyText(_circleId)) {
        if (_circleEntity.joinMode == 0) {
            [self putValueToParamDictionary:CircleDict value:_circleId forKey:@"circleId"];
            [self pageToOrBackWithName:@"CircleJoinReasonController"];
        }else{
            [self requestData:@""];
        }
        
    }
}


#pragma mark - observeValue
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _tableView && [keyPath isEqualToString:@"contentOffset"]) {
        
        CGFloat offset = self.tableView.contentOffset.y;
        
        if(offset < 0){
            _layoutHeaderBGHeight.constant = HEADER_BG_HEIGHT + STATUS_BAR_HEIGHT - offset;
            _statusBarView.alpha = 0;
            bIsStateBarWhite = YES;
            
        }else if(offset == 0){
            _layoutHeaderBGHeight.constant = HEADER_BG_HEIGHT + STATUS_BAR_HEIGHT;
            _statusBarView.alpha = 0;
            bIsStateBarWhite = YES;
            
        }else{
            
            if(offset > (HEADER_BG_HEIGHT + 6)){
                
                CGFloat percentage;
                if(offset > HEADER_BG_HEIGHT + STATUS_BAR_HEIGHT){
                    percentage = 1;
                }else{
                    percentage = (offset - (HEADER_BG_HEIGHT + 6))/NAVIGATION_BAR_HEIGHT;
                }
                _statusBarView.alpha = percentage;
                bIsStateBarWhite = NO;
            }else{
                
                _statusBarView.alpha = 0;
                bIsStateBarWhite = YES;
            }
            
            if(HEADER_BG_HEIGHT + STATUS_BAR_HEIGHT - offset <= 0){
                _layoutHeaderBGHeight.constant = 0.0;
            }else{
                _layoutHeaderBGHeight.constant = HEADER_BG_HEIGHT + STATUS_BAR_HEIGHT - offset;
            }
            [self setNeedsStatusBarAppearanceUpdate];
            
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)dealloc {
    [_tableView removeObserver:self forKeyPath:@"contentOffset"];
    [_circleEntity release];
    [_articleAmount release];
    [tableData release];
    [_tableView release];
    [_circleId release];
    [_memberAmount release];
    [_showAmount release];
    [_statusBarView release];
    [_layoutHeaderBGHeight release];
    [_ivCircleBG release];
    [_btnSend release];
    [super dealloc];
}


@end
