//
//  PersonalInfoHeaderView.m
//  Cropyme
//
//  Created by Hay on 2019/6/10.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "PersonalInfoHeaderView.h"
#import "CommonUtil.h"
#import "RZWebImageView.h"
#import "JHRadarChart.h"
#import "VeDateUtil.h"

#define FollowOrderHeadLogoWidth  30

@interface PersonalInfoHeaderView()
{
    CGFloat originHeaderViewHeight;             //该view初始高度
}

@property (retain, nonatomic) PCPersonalInfoModel *infoEntity;          //信息对象
@property (retain, nonatomic) JHRadarChart *radarChart;                 //雷达图

/** UI*/
@property (retain, nonatomic) IBOutlet UIView *radarContainView;        //包含雷达图的view
@property (retain, nonatomic) IBOutlet UIView *topInfoView;                 //顶部信息view
@property (retain, nonatomic) IBOutlet RZWebImageView *headLogo;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;                  //姓名
@property (retain, nonatomic) IBOutlet UIButton *subButton;                 //订阅按钮
@property (retain, nonatomic) IBOutlet UILabel *userIdLabel;                //id
@property (retain, nonatomic) IBOutlet UILabel *subCountLabel;              //订阅人数
@property (retain, nonatomic) IBOutlet UILabel *followOrderCountLabel;      //跟单人数
@property (retain, nonatomic) IBOutlet UILabel *descLabel;                  //个人简介
@property (retain, nonatomic) IBOutlet UIButton *followOrderButton;         //跟单按钮
@property (retain, nonatomic) IBOutlet UILabel *subTimeTipsLabel;           //订阅时间提示
//交易收益
@property (retain, nonatomic) IBOutlet UILabel *correctRateLabel;           //准确率
@property (retain, nonatomic) IBOutlet UILabel *totalProfitLabel;           //总收益
@property (retain, nonatomic) IBOutlet UILabel *monthProfitLabel;           //上月收益



@end

@implementation PersonalInfoHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_subButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 1.0)] forState:UIControlStateNormal];
    [_followOrderButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 1.0)] forState:UIControlStateNormal];
    [CommonUtil viewHeightForAutoLayout:_topInfoView height:200];
    originHeaderViewHeight = self.frame.size.height;
}

- (void)dealloc
{
    [_infoEntity release];
    [_radarChart release];
    [_subButton release];
    [_followOrderButton release];
    [_headLogo release];
    [_nameLabel release];
    [_userIdLabel release];
    [_radarContainView release];
    [_subCountLabel release];
    [_followOrderCountLabel release];
    [_topInfoView release];
    [_descLabel release];
    [_correctRateLabel release];
    [_totalProfitLabel release];
    [_monthProfitLabel release];
    [_subTimeTipsLabel release];
    [super dealloc];
}

#pragma mark - 获取headerView高度
- (CGFloat)infoHeaderViewCurrentHeight
{
    CGFloat currentHeight = originHeaderViewHeight;
    if(![ROOTCONTROLLER_USER.userId isEqualToString:_infoEntity.userId]){     //如果不是自己id，则需要显示跟单和关注按钮
        currentHeight = currentHeight + 65;         //自己跟别人就少了关注和跟单按钮，为65
    }
    CGSize size;
    if(checkIsStringWithAnyText(_infoEntity.describes)){
        size = [CommonUtil getPerfectSizeByText:_infoEntity.describes andFontSize:12.0f andWidth:SCREEN_WIDTH - 30];
    }else{
        size = [CommonUtil getPerfectSizeByText:NSLocalizedStringForKey(@"这个人很懒，未留下任何东西 ......") andFontSize:12.0f andWidth:SCREEN_WIDTH - 30];
    }
    size.height = MAX(18, size.height);
    currentHeight = currentHeight + (size.height - 18);
    return currentHeight;
}

#pragma mark - 设置数据
- (void)reloadInfoHeaderView:(PCPersonalInfoModel *)infoEntity
{
    self.infoEntity = infoEntity;
    [_headLogo showHeaderImageViewWithUrl:infoEntity.headUrl];
    _nameLabel.text = infoEntity.userName;
    if(checkIsStringWithAnyText(_infoEntity.describes)){
        _descLabel.text = infoEntity.describes;
    }else{
        _descLabel.text = NSLocalizedStringForKey(@"这个人很懒，未留下任何东西 ......");
    }

    _userIdLabel.text = [NSString stringWithFormat:@"ID:%@ %@%@%@",infoEntity.userId, NSLocalizedStringForKey(@"已入驻"), infoEntity.days, NSLocalizedStringForKey(@"天")];
    _subCountLabel.text = [NSString stringWithFormat:@"%@",infoEntity.attentionNum];
    _followOrderCountLabel.text = [NSString stringWithFormat:@"%@",infoEntity.radarFollowNum];
    _correctRateLabel.text = [NSString stringWithFormat:@"%@%%",infoEntity.correctRate];
    _totalProfitLabel.text = infoEntity.totalProfit;
    _monthProfitLabel.text = infoEntity.monthProfit;

    if([ROOTCONTROLLER_USER.userId isEqualToString:infoEntity.userId]){     //如果是自己id，则不需要显示跟单和关注按钮
        _subButton.hidden = YES;
        _followOrderButton.hidden = YES;
        [CommonUtil viewHeightForAutoLayout:_topInfoView height:200];
    }else{
        _subButton.hidden = NO;
        _followOrderButton.hidden = NO;
        [CommonUtil viewHeightForAutoLayout:_topInfoView height:265];
    }
    
    if(infoEntity.subIsFee){           //收费订阅
        _subTimeTipsLabel.hidden = NO;
        if(!infoEntity.myIsAttention){      //之前没订阅
            [_subButton setTitle:NSLocalizedStringForKey(@"订阅") forState:UIControlStateNormal];
            _subTimeTipsLabel.text = @"";
        }else if(infoEntity.isExpireTime){  //已订阅，但过期
            [_subButton setTitle:NSLocalizedStringForKey(@"续费") forState:UIControlStateNormal];
            _subTimeTipsLabel.text = NSLocalizedStringForKey(@"订阅已过期");
            _subTimeTipsLabel.textColor = [UIColor redColor];
        }else{          //已订阅但未过期
            [_subButton setTitle:NSLocalizedStringForKey(@"续费") forState:UIControlStateNormal];
            _subTimeTipsLabel.text = [VeDateUtil formatterDate:infoEntity.expireTime inStytle:nil outStytle:[NSString stringWithFormat:@"%@:yyyy-MM-dd", NSLocalizedStringForKey(@"到期")] isTimestamp:YES];
            _subTimeTipsLabel.textColor = RGBA(29, 49, 85, 1.0);
        }
    }else{
        _subTimeTipsLabel.hidden = YES;
        if(!infoEntity.myIsAttention){      //之前没订阅
            [_subButton setTitle:NSLocalizedStringForKey(@"订阅") forState:UIControlStateNormal];
        }else{
            [_subButton setTitle:NSLocalizedStringForKey(@"已订阅") forState:UIControlStateNormal];
        }
    }
    
    
    
    
    if(infoEntity.myIsFollow){      //是否已绑定跟单
        [_followOrderButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(61, 58, 80, 0.05)] forState:UIControlStateNormal];
        [_followOrderButton setTitle:NSLocalizedStringForKey(@"解除绑定") forState:UIControlStateNormal];
        [_followOrderButton setTitleColor:RGBA(61, 58, 80, 0.4) forState:UIControlStateNormal];
    }else{
        [_followOrderButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 1.0)] forState:UIControlStateNormal];
        [_followOrderButton setTitle:NSLocalizedStringForKey(@"申请绑定") forState:UIControlStateNormal];
        [_followOrderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }

    /** 设置雷达图*/
    [self reloadRadarChart];
}


/** 设置雷达图数据*/
- (void)reloadRadarChart
{
    if(self.radarChart){
        [self.radarChart removeFromSuperview];
    }
    self.radarChart = [[[JHRadarChart alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH - 30, _radarContainView.frame.size.height)] autorelease];
    _radarChart.backgroundColor = RGBA(250, 250, 250, 1.0);
    _radarChart.valueDescArray = @[[NSString stringWithFormat:@"%@\n%@", NSLocalizedStringForKey(@"跟单盈利额"), _infoEntity.radarFollowBalance],
                                   [NSString stringWithFormat:@"%@\n%@%%", NSLocalizedStringForKey(@"盈利能力"), _infoEntity.radarProfitRate],
                                   [NSString stringWithFormat:@"%@\n%@%%", NSLocalizedStringForKey(@"跟单收益率"), _infoEntity.radarFollowProfitRate],
                                   [NSString stringWithFormat:@"%@\n%@%%", NSLocalizedStringForKey(@"跟单胜率"), _infoEntity.radarFollowWinRate],
                                   [NSString stringWithFormat:@"%@\n%@", NSLocalizedStringForKey(@"人气指数"), _infoEntity.radarFollowNum],
                                   ];
    _radarChart.descTextFont = [UIFont systemFontOfSize:12.0f];
    _radarChart.layerCount = 5;
    _radarChart.perfectNumber = _infoEntity.tolRadarWeight;
    /** 为了能看到最小分数的雷达图，所以暂时保证最小不低分10分*/
    _radarChart.valueDataArray = @[
                                   @[[NSString stringWithFormat:@"%@", _infoEntity.radarFollowBalanceWeight <= 10 ? @"10": @(_infoEntity.radarFollowBalanceWeight)],
                                     [NSString stringWithFormat:@"%@", _infoEntity.radarProfitRateWeight <= 10 ? @"10" : @(_infoEntity.radarProfitRateWeight)],
                                     [NSString stringWithFormat:@"%@", _infoEntity.radarFollowProfitRateWeight <= 10 ? @"10": @(_infoEntity.radarFollowProfitRateWeight)],
                                     [NSString stringWithFormat:@"%@", _infoEntity.radarFollowWinRateWeight <= 10 ? @"10" : @(_infoEntity.radarFollowWinRateWeight)],
                                     [NSString stringWithFormat:@"%@", _infoEntity.radarFollowNumWeight <= 10 ? @"10" : @(_infoEntity.radarFollowNumWeight)]
                                     ]
                                  ];
    _radarChart.layerFillColor = RGBA(61, 58, 80, 0.05);
    _radarChart.speraLineColor = RGBA(244, 245, 244,1.0);
    _radarChart.layerBoardColor = RGBA(244, 245, 244,1.0);;
    _radarChart.valueDrawFillColorArray = @[RGBA(97, 117, 174, 0.55)];
    [_radarChart showAnimation];
    [_radarContainView addSubview:_radarChart];
    [_radarContainView sendSubviewToBack:_radarChart];
}


#pragma mark - 按钮点击事件
- (IBAction)followOrderButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(infoHeaderViewFollowOrderDidSelected)]){
        [_delegate infoHeaderViewFollowOrderDidSelected];
    }
}

- (IBAction)subscribeUserButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(infoHeaderViewSubscribeUserDidSelected)]){
        [_delegate infoHeaderViewSubscribeUserDidSelected];
    }
}
- (IBAction)radarDetailButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(infoHeaderViewRadarInfoDidSelected)]){
        [_delegate infoHeaderViewRadarInfoDidSelected];
    }
}
@end
