//
//  ChatRecorderView.m
//  TJRtaojinroad
//
//  Created by Jeans on 3/24/13.
//  Copyright (c) 2018 Taojinroad. All rights reserved.
//

#import "ChatRecorderView.h"

#define kTrashImage1         [UIImage imageNamed:@"recorder_trash_can0.png"]
#define kTrashImage2         [UIImage imageNamed:@"recorder_trash_can1.png"]
#define kTrashImage3         [UIImage imageNamed:@"recorder_trash_can2.png"]

@interface ChatRecorderView(){
    NSArray         *peakImageAry;
    NSArray         *trashImageAry;
    BOOL            isPrepareDelete;
    BOOL            isTrashCanRocking;
}

@end

@implementation ChatRecorderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initilization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initilization];
    }
    return self;
}

- (void)initilization{
    //初始化音量peak峰值图片数组
    peakImageAry = [[NSArray alloc]initWithObjects:
                    [UIImage imageNamed:@"recorder_mic_0.png"],
                    [UIImage imageNamed:@"recorder_mic_1.png"],
                    [UIImage imageNamed:@"recorder_mic_2.png"],
                    [UIImage imageNamed:@"recorder_mic_3.png"],
                    [UIImage imageNamed:@"recorder_mic_4.png"],nil];
    trashImageAry = [[NSArray alloc]initWithObjects:kTrashImage1,kTrashImage2,kTrashImage3,kTrashImage2, nil];
    _trashCanIV.hidden = YES;
}

- (void)dealloc {
    [peakImageAry release];
    [trashImageAry release];
    [_peakMeterIV release];
    [_trashCanIV release];
    [_countDownLabel release];
    [super dealloc];
}

#pragma mark -还原显示界面
- (void)restoreDisplay{
    //还原录音图
    _peakMeterIV.image = [peakImageAry objectAtIndex:0];
    //停止震动
    [self showTrashCan:NO];
    //还原倒计时文本
    _countDownLabel.text = @"";
}

#pragma mark - 是否准备删除
- (void)prepareToDelete:(BOOL)_preareDelete{
    if (_preareDelete != isPrepareDelete) {
        isPrepareDelete = _preareDelete;
        [self showTrashCan:isPrepareDelete];
    }
}
#pragma mark - 是否摇晃垃圾桶
- (void)rockTrashCan:(BOOL)_isTure{
    if (_isTure != isTrashCanRocking) {
        isTrashCanRocking = _isTure;
        if (isTrashCanRocking) {
            //摇晃
//            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//            animation.fromValue = [NSNumber numberWithFloat:0.95];
//            animation.toValue = [NSNumber numberWithFloat:1.1];
//            animation.duration = 0.14;
//            animation.autoreverses = YES;
//            animation.repeatCount = NSIntegerMax;
//            animation.removedOnCompletion = NO;
//            animation.fillMode = kCAFillModeForwards;
//            [_trashCanIV.layer addAnimation:animation forKey:@"shakeAnimation"];
            
//            _trashCanIV.image = nil;
            _trashCanIV.animationImages = trashImageAry;
            _trashCanIV.animationRepeatCount = 0;
            _trashCanIV.animationDuration = 1;
            [_trashCanIV startAnimating];
        }else{
            //停止
//            [_trashCanIV.layer removeAnimationForKey:@"shakeAnimation"];
            if (_trashCanIV.isAnimating)
                [_trashCanIV stopAnimating];
            _trashCanIV.animationImages = nil;
            _trashCanIV.image = kTrashImage1;
        }
    }
}

- (void)showTrashCan:(BOOL)_isTure{
    if (_isTure != isTrashCanRocking) {
        isTrashCanRocking = _isTure;
        if (isTrashCanRocking) {
            //展示
            _peakMeterIV.hidden = YES;
            _trashCanIV.hidden = NO;
            _trashCanIV.animationImages = trashImageAry;
            _trashCanIV.animationRepeatCount = 0;
            _trashCanIV.animationDuration = 1;
            [_trashCanIV startAnimating];
        }else{
            _peakMeterIV.hidden = NO;
            _trashCanIV.hidden = YES;
            if (_trashCanIV.isAnimating)
                [_trashCanIV stopAnimating];
            _trashCanIV.animationImages = nil;
            _trashCanIV.image = kTrashImage1;
        }
    }
}

//- (void)startShake
//{
//    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    shakeAnimation.duration = 0.08;
//    shakeAnimation.autoreverses = YES;
//    shakeAnimation.repeatCount = MAXFLOAT;
//    shakeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, -0.1, 0, 0, 1)];
//    shakeAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, 0.1, 0, 0, 1)];
//    
//    [self.layer addAnimation:shakeAnimation forKey:@"shakeAnimation"];
//}
//
//- (void)stopShake
//{
//    [self.layer removeAnimationForKey:@"shakeAnimation"];
//}

#pragma mark - 更新音频峰值
- (void)updateMetersByAvgPower:(float)_avgPower{
    //-160表示完全安静，0表示最大输入值
    //

    NSInteger imageIndex = 0;
    if (_avgPower >= -50 && _avgPower < -40)
        imageIndex = 0;
    else if (_avgPower >= -40 && _avgPower < -30)
        imageIndex = 1;
    else if (_avgPower >= -30 && _avgPower < -25)
        imageIndex = 2;
    else if (_avgPower >= -25 && _avgPower < -15)
        imageIndex = 3;
    else if (_avgPower >= -15)
        imageIndex = 4;
    
    
    _peakMeterIV.image = [peakImageAry objectAtIndex:imageIndex];
}

@end
