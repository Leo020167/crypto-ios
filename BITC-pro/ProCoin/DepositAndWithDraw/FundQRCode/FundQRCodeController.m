//
//  FundQRCodeController.m
//  Cropyme
//
//  Created by Hay on 2019/7/27.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "FundQRCodeController.h"
#import "RZWebImageView.h"

@interface FundQRCodeController ()

@property (copy, nonatomic) NSString *qrCodeURL;
@property (retain, nonatomic) IBOutlet RZWebImageView *qrCodeLogo;


@end

@implementation FundQRCodeController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self getValueFromModelDictionary:FundExchangeDic forKey:@"FundQRCodeImageURL"]){
        self.qrCodeURL = [self getValueFromModelDictionary:FundExchangeDic forKey:@"FundQRCodeImageURL"];
        [self removeParamFromModelDictionary:FundExchangeDic forKey:@"FundQRCodeImageURL"];
    }
    if(checkIsStringWithAnyText(_qrCodeURL)){
        [_qrCodeLogo showImageWithUrl:_qrCodeURL];
    }
}

- (void)dealloc
{
    [_qrCodeURL release];
    [_qrCodeLogo release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}
- (IBAction)saveQRCodeButtonPressed:(id)sender
{
    [self saveImageInPhotosAlbum:_qrCodeLogo.image];
}


#pragma mark - 保存到相册
- (void)saveImageInPhotosAlbum:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

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
