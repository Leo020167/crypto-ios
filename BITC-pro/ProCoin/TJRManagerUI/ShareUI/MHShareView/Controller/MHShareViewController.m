//
//  MHShareViewController.m
//  Cropyme
//
//  Created by Hay on 2019/7/11.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "MHShareViewController.h"
#import "RZWebImageView.h"
#import "UIImage+Size.h"
#import "CommonUtil.h"

@interface MHShareViewController ()
{

}

@property (assign, nonatomic) MHShareViewShareType shareType;
@property (copy, nonatomic) NSDictionary *infoDic;
@property (copy, nonatomic) NSString *shareUrl;
@property (retain, nonatomic) UIView *shareViewContent;

@end

@implementation MHShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)dealloc
{
    [self.view.layer removeAllAnimations];
    [_infoDic release];
    [_shareUrl release];
    [_shareViewContent release];
    [super dealloc];
}

#pragma mark - 显示与消失
- (void)controllerShowInController:(UIViewController *)controller withShareUrl:(NSString *)shareUrl withShareType:(MHShareViewShareType)shareType withInfo:(NSDictionary *)infoDic;
{
    self.infoDic = infoDic;
    self.shareUrl = shareUrl;
    self.shareType = shareType;
    
    [self.view setFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    
    CGFloat shareViewContentY = (SCREEN_HEIGHT - STATUS_BAR_HEIGHT - ((SCREEN_WIDTH - 70) * 525 / 335.0f) - 20 - 35 ) / 2.0f;
    [self.shareViewContent setFrame:CGRectMake(35, shareViewContentY, SCREEN_WIDTH - 70, (SCREEN_WIDTH - 70) * 525 / 335.0f)];
    UIButton *saveShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveShareButton setFrame:CGRectMake(SCREEN_WIDTH / 2.0f - 50, _shareViewContent.frame.origin.y + _shareViewContent.frame.size.height + 20, 100, 35)];
    [saveShareButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [saveShareButton setTitle:@"保存并分享" forState:UIControlStateNormal];
    [saveShareButton setTitleColor:RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
    saveShareButton.layer.masksToBounds = YES;
    saveShareButton.layer.cornerRadius = 3;
    saveShareButton.layer.borderWidth = 1.0;
    saveShareButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [saveShareButton addTarget:self action:@selector(saveShareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //添加增加的动画
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.5];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[self.view layer] addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    [self.view addSubview:self.shareViewContent];
    [self.view addSubview:saveShareButton];

}

- (void)dismissController
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
}

#pragma mark - 懒加载
- (UIView *)shareViewContent
{
    if(!_shareViewContent){
        _shareViewContent = [[[[NSBundle mainBundle] loadNibNamed:@"MHShareViewContent" owner:nil options:nil] lastObject] retain];
        RZWebImageView *logo = (RZWebImageView *)[_shareViewContent viewWithTag:100];
        UILabel *idLabel = (UILabel *)[_shareViewContent viewWithTag:101];
        UILabel *nameLabel = (UILabel *)[_shareViewContent viewWithTag:102];
        UILabel *nameTitleLabel = (UILabel *)[_shareViewContent viewWithTag:103];
        UILabel *firstContentLabel = (UILabel *)[_shareViewContent viewWithTag:104];
        UILabel *secondContentLabel = (UILabel *)[_shareViewContent viewWithTag:105];
        UIImageView *qrCode = (UIImageView *)[self.shareViewContent viewWithTag:200];
        qrCode.image = [UIImage createQRForString:_shareUrl withSize:65];
        if(self.infoDic == nil){
            [logo showImageWithUrl:ROOTCONTROLLER_USER.headurl];
            idLabel.text = [NSString stringWithFormat:@"ID:%@",ROOTCONTROLLER_USER.userId];
            nameLabel.text = ROOTCONTROLLER_USER.name;
        }else{
            [logo showImageWithUrl:_infoDic[MHShareViewUserHeadLogoKey]];
            idLabel.text = _infoDic[MHShareViewUserIdKey];
            nameLabel.text = _infoDic[MHShareViewUserNameKey];
        }
        
        if(self.shareType == MHShareViewShareTypePersonalInvite){
            nameTitleLabel.text = @"我是";
            firstContentLabel.text = @"邀请好友，开启环球数字资产交易";
            secondContentLabel.text = @"";
        }else if(self.shareType == MHShareViewShareTypeOthers){
            nameTitleLabel.text = @"TA是";
            firstContentLabel.text = @"我已在W.W.C.T一键跟上了TA的实盘交易";
            secondContentLabel.text = @"TA赚了多少  我就赚多少";
        }
        
        
    }
    return _shareViewContent;
}

#pragma mark - 按钮点击事件
- (void)saveShareButtonPressed:(UIButton *)sender
{
    UIImage *image = [self makeImageWithView:self.shareViewContent andWithSize:_shareViewContent.frame.size];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    [self shareToOtherAPP:image];
}

- (IBAction)backgroundTouchDownEvent:(id)sender
{
    [self dismissController];
}

#pragma mark - 根据view生成图片
- (UIImage *)makeImageWithView:(UIView *)view andWithSize:(CGSize)size
{
    //下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数 [UIScreen mainScreen].scale。
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [self.shareViewContent.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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


- (void)shareToOtherAPP:(UIImage *)image
{
    NSArray *arr1 = @[image];
    UIActivityViewController *ctrl = [[[UIActivityViewController alloc]initWithActivityItems:arr1 applicationActivities:nil] autorelease];
    ctrl.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        [self dismissController];
    };
    [self presentViewController:ctrl animated:YES completion:nil];
    
}
@end
