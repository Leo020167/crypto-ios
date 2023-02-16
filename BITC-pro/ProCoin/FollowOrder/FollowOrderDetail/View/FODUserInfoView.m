//
//  FODUserInfoView.m
//  Cropyme
//
//  Created by Hay on 2019/8/27.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "FODUserInfoView.h"
#import "RZWebImageView.h"

#define UserInfoViewIsDotHidden           @"UserInfoViewIsDotHidden"

@interface FODUserInfoView()

@property (retain, nonatomic) IBOutlet RZWebImageView *headLogo;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *userIdLabel;
@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;
@property (retain, nonatomic) IBOutlet UIView *starView;
@property (retain, nonatomic) IBOutlet UILabel *perMaxAmountLabel;
@property (retain, nonatomic) IBOutlet UILabel *stopWinLabel;
@property (retain, nonatomic) IBOutlet UILabel *stopLoseLabel;
@property (retain, nonatomic) IBOutlet UIView *settingView;
@property (retain, nonatomic) IBOutlet UIImageView *dotIV;

@end

@implementation FODUserInfoView


- (void)dealloc
{
    [_headLogo release];
    [_nameLabel release];
    [_userIdLabel release];
    [_scoreLabel release];
    [_starView release];
    [_perMaxAmountLabel release];
    [_stopWinLabel release];
    [_stopLoseLabel release];
    [_settingView release];
    [_dotIV release];
    [super dealloc];
}

- (IBAction)followOrderSettingButtonPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:UserInfoViewIsDotHidden];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _dotIV.hidden = YES;
    if([_delegate respondsToSelector:@selector(userInfoViewFollowOrderSettingDidSelected)]){
        [_delegate userInfoViewFollowOrderSettingDidSelected];
    }
}

- (void)reloadUserInfoData:(FollowOrderDetailEntity *)detailEntity isLimitFunction:(BOOL)isLimitFunction
{
    __block typeof(self) weakSelf = self;
    [_headLogo showImageWithUrl:detailEntity.followHeadUrl imageCanTouch:YES imageDidTouchEvent:^{
        if([weakSelf.delegate respondsToSelector:@selector(userInfoViewUserHeadLogoDidSelected:)]){
            [weakSelf.delegate userInfoViewUserHeadLogoDidSelected:detailEntity.followUid];
        }
    }];
    _nameLabel.text = detailEntity.followName;
    _userIdLabel.text = [NSString stringWithFormat:@"ID：%@",detailEntity.followUid];
    _scoreLabel.text = detailEntity.score;
    
    NSInteger scorePercentage = floorf([detailEntity.score floatValue] / 20.0f);
    if(scorePercentage == 0 && [detailEntity.score floatValue]> 0){
        scorePercentage = 1;
    }else if([detailEntity.score floatValue] == 0){
        scorePercentage = 0;
    }
    
    for(int i = 0; i < 5; i++){
        UIImageView *starIV = (UIImageView *)[self viewWithTag:300 + i];
        if(i < scorePercentage){
            starIV.image = [UIImage imageNamed:@"home_mine_icon_star_SL"];
        }else{
            starIV.image = [UIImage imageNamed:@"home_mine_icon_star"];
        }
    }
    _settingView.hidden = isLimitFunction;
    _perMaxAmountLabel.text = detailEntity.maxFollowBalance;
    if(detailEntity.stopWin == 0){
        _stopWinLabel.text = NSLocalizedStringForKey(@"暂无设置");
    }else{
        _stopWinLabel.text = detailEntity.stopWinValue;
    }
    
    if(detailEntity.stopLoss == 0){
        _stopLoseLabel.text = NSLocalizedStringForKey(@"暂无设置");
    }else{
        _stopLoseLabel.text = detailEntity.stopLossValue;
    }
    BOOL isDotViewHidden = NO;
    if([[NSUserDefaults standardUserDefaults] objectForKey:UserInfoViewIsDotHidden]){
        isDotViewHidden = [[[NSUserDefaults standardUserDefaults] objectForKey:UserInfoViewIsDotHidden] boolValue];
    }
    _dotIV.hidden = isDotViewHidden;
    
}
@end
