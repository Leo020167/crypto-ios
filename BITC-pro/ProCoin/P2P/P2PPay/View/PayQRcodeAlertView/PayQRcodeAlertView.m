//
//  PayQRcodeAlertView.m
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "PayQRcodeAlertView.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "TJRBaseViewController.h"

@interface PayQRcodeAlertView()
{

    
}
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIView *touchView;
@property (retain, nonatomic) IBOutlet RZWebImageView *ivLogo;
@end

@implementation PayQRcodeAlertView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapEvent:)] autorelease];
    [_touchView addGestureRecognizer:recognizer];

}


- (void)dealloc
{
    [_contentView release];
    [_touchView release];
    [_ivLogo release];
    [super dealloc];
}

- (void)reloadUIData:(NSString*)qrcodeUrl{
    [_ivLogo showImageWithUrl:qrcodeUrl];
}

#pragma mark - 按钮点击事件
- (void)backgroundTapEvent:(UIGestureRecognizer *)recognizer
{
    [self dismissView];
}


#pragma mark - 显示与消失
/** 显示动画*/
- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    self.alpha = 0;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        [self layoutIfNeeded];
    }];
    
}

/** 隐藏页面*/
- (void)dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 按钮点击事件
- (IBAction)saveQRCodeButtonPressed:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(_ivLogo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}


#pragma mark -- <保存到相册>
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil ;
    if(error){
        msg = NSLocalizedStringForKey(@"保存图片失败") ;
    }else{
        msg = NSLocalizedStringForKey(@"保存图片成功") ;
    }
    [[CommonUtil getControllerWithContainView:self] showToast:msg inView:ROOTCONTROLLER.view];
}
@end

