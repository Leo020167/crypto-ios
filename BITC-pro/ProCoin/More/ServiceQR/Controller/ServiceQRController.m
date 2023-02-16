//
//  ServiceQRController.m
//  BYY
//
//  Created by Hay on 2019/9/25.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "ServiceQRController.h"
#import "RZWebImageView.h"

@interface ServiceQRController ()

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *contentLabel;
@property (retain, nonatomic) IBOutlet RZWebImageView *qrLogo;

@end

@implementation ServiceQRController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)dealloc
{
    [self.view.layer removeAllAnimations];
    [_titleLabel release];
    [_contentLabel release];
    [_qrLogo release];
    [super dealloc];
}

#pragma mark - 显示与消失
- (void)showServiceQRControllerInController:(UIViewController *)controller title:(NSString *)title content:(NSString *)content qrUrl:(NSString *)qrUrl
{
    self.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);

    
    //添加增加的动画
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.5];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[self.view layer] addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    
    _titleLabel.text = title;
    _contentLabel.text = content;
    [_qrLogo showImageWithUrl:qrUrl];
}

- (void)dimissQRController
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - 按钮点击事件
- (IBAction)saveQRCodeButtonPressed:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(_qrLogo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (IBAction)backgroundViewTouchDownEvent:(id)sender
{
    [self dimissQRController];
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
    [self showToastCenter:msg];
}
@end
