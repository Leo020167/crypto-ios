//
//  CircleCreateViewController.m
//  Tjrv
//
//  Created by taojinroad on 2019/3/1.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CircleCreateViewController.h"
#import "RZWebImageView.h"
#import "HPGrowingTextView.h"
#import "NetWorkManage+Circle.h"
#import "NetWorkManage+File.h"
#import "CommonUtil.h"
#import "CircleEntity.h"
#import "TJRBaseParserJson.h"
#import "TZImagePickerController.h"
#import "UIImage+Size.h"
#import "CircleSQL.h"
#import "CircleSocket.h"
#import "CircleBaseDataEntity.h"

#define kUpOfHeight 40

@interface CircleCreateViewController ()<TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,HPGrowingTextViewDelegate>{
    
    BOOL bReqFinished;
}

@property (retain, nonatomic) IBOutlet RZWebImageView *ivHead;
@property (retain, nonatomic) IBOutlet UITextField *tfCircleName;
@property (retain, nonatomic) IBOutlet HPGrowingTextView *growingTextView;
@property (retain, nonatomic) IBOutlet UILabel *lbTextCount;
@property (retain, nonatomic) IBOutlet UIButton *btnLeft;
@property (retain, nonatomic) IBOutlet UIButton *btnRight;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *headAddView;

@property (retain, nonatomic) UIImage *imgCircleLogo;

@end

@implementation CircleCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _growingTextView.maxTextLimitCount = 500;
    _growingTextView.textCountLabel = _lbTextCount;
    _growingTextView.placeHolder = @"请输入圈子简介";
    [_growingTextView setBorderColor:[UIColor whiteColor] borderWidth:1];
    [_growingTextView setCornerRadius:0];
    _growingTextView.font = [UIFont systemFontOfSize:15];
    _growingTextView.backgroundColor = RGBA(238, 238, 238, 1);
    [_growingTextView setDelegate:self];
    
    bReqFinished = YES;
    
}

- (IBAction)leftButtonClicked:(id)sender {
    [self goBack];
}

- (IBAction)rightButtonClicked:(id)sender {
    
    if (!TTIsStringWithAnyText(_tfCircleName.text)) {
        [self showToastCenter:@"请输入圈子名字"];
        return;
    }
    NSInteger len = [CommonUtil getChineseLength:_tfCircleName.text];
    if (len <= 1) {
        [self showToastCenter:@"圈子名字过于简短"];
        return;
    }else if (len > 12) {
        [self showToastCenter:@"圈子名字长度太长"];
        return;
    }
    
    if (_growingTextView.text==nil||_growingTextView.text.length==0||[_growingTextView.placeHolder isEqualToString:_growingTextView.text]) {
        [self showToastCenter:@"请输入圈子简介内容"];
        return;
    }
    if (_growingTextView.count>500) {
        [self showToastCenter:@"请输入不多于500字符"];
        return;
    }

    NSString* fileName = [UIImage createOriginalImage:_imgCircleLogo userId:ROOTCONTROLLER_USER.userId];
    if (TTIsStringWithAnyText(fileName)) {
        [self reqUploadCircleFileData:fileName];
    }
}

- (IBAction)headButtonClicked:(id)sender {
    [self takePicture];
}

#pragma mark - reqUploadCircleFileData
- (void)reqUploadCircleFileData:(NSString*)flie{
    
    if (bReqFinished) {
        bReqFinished = NO;
        [[NetWorkManage shareSingleNetWork] reqUploadCircleBackground:self imageFile:flie finishedCallback:@selector(reqUploadFileFinished:) failedCallback:@selector(reqCircleCreateFailed:)];
    }
    
}

- (void)reqCircleCreateData:(NSString*)circleName brief:(NSString*)brief circleLogo:(NSString*)circleLogo{
    
    if (bReqFinished) {
        bReqFinished = NO;
        [[NetWorkManage shareSingleNetWork] reqCircleCreate:self circleName:circleName brief:brief circleLogo:circleLogo finishedCallback:@selector(reqCircleCreateFinished:) failedCallback:@selector(reqCircleCreateFailed:)];
    }
    
}

- (void)reqUploadFileFinished:(id)result{
    bReqFinished = YES;
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init] autorelease];
    
    if ([jsonParser parseBaseIsOk:result]) {
        NSDictionary *dataDic = [result objectForKey:@"data"];
        NSArray* fileUrlArr = ((NSArray*)[dataDic objectForKey:@"imageUrlList"]);
        
        NSString* circleLogo = [fileUrlArr firstObject];
        [self reqCircleCreateData:_tfCircleName.text brief:_growingTextView.text circleLogo:circleLogo];
        
    }else{
        NSString* str = @"发送失败";
        if ([result objectForKey:@"msg"]) {
            str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
        }
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_ERROR];
    }
}

- (void)reqCircleCreateFinished:(id)result{
    bReqFinished = YES;
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init] autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    if ([jsonParser parseBaseIsOk:result]) {
        
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_SUCCEED];
        _btnRight.enabled = NO;
        _btnLeft.enabled = NO;
        
        NSDictionary *dataDic = [result objectForKey:@"data"];
        CircleEntity *item = [[[CircleEntity alloc] initWithJson:dataDic[@"circle"]]autorelease];
        [CircleSQL replaceIntoCircleInfo:item];    // 将圈子信息保存到数据库

        if (TTIsStringWithAnyText(item.circleId)) {
            CircleBaseDataEntity *entity = [CircleSocket shareCircleSocket].circleDetail[item.circleId];
            if (entity) {
                [entity updateWithJson:dataDic[@"circle"]];
            } else {
                entity = [[[CircleBaseDataEntity alloc] initWithJson:dataDic[@"circleRole"]]autorelease];
                [[CircleSocket shareCircleSocket].circleDetail setObject:entity forKey:entity.circleId];
            }
        }
        if ([CircleSocket shareCircleSocket].circleDetail && ([CircleSocket shareCircleSocket].circleDetail.count > 0)) {
            [CircleSQL replaceIntoMyCircleWithArray:[CircleSocket shareCircleSocket].circleDetail.allValues];
        }
        
        [self putValueToParamDictionary:CircleDict value:[NSNumber numberWithBool:YES] forKey:RELOADDATA_DIC_KEY];
        [self performSelector:@selector(goBack) withObject:nil afterDelay:1];
    }else{
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_ERROR];
    }
}

- (void)reqCircleCreateFailed:(id)result{
    bReqFinished = YES;
    [self showProgressHUDCompleteMessage:@"W.W.C.T提示" detailsMessage:@"发送失败" imageName:HUD_ERROR];
}

- (IBAction)backgroundClicked:(id)sender {

    if (_tfCircleName.isFirstResponder) {
        
        [_tfCircleName resignFirstResponder];
        [_scrollView setContentOffset:CGPointMake(0.0, 3.8 * kUpOfHeight) animated:YES];
        
    }else if (_growingTextView.isFirstResponder) {
        
        [_growingTextView resignFirstResponder];
        [_scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    }
}

#pragma mark - Text Field Delegate
- (IBAction)textFieldChange:(UITextField *)sender {
    if (TTIsStringWithAnyText(_tfCircleName.text) || TTIsStringWithAnyText(_growingTextView.text) || _imgCircleLogo ) {
        _btnRight.enabled = YES;
    }else{
        _btnRight.enabled = NO;
    }
}

- (IBAction)textFieldDidEndOnExit:(id)sender {
    [self backgroundClicked:nil];
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField{
    [_scrollView setContentOffset:CGPointMake(0.0, 3.8 * kUpOfHeight) animated:YES];
}

#pragma mark - GrowingTextViewr Delegate Methods
- (void)growingTextViewClickFinish:(HPGrowingTextView *)growingTextView{
    [self backgroundClicked:nil];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    [self textFieldChange:nil];
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView{
    [_scrollView setContentOffset:CGPointMake(0.0, 3.8 * kUpOfHeight) animated:YES];
}

#pragma mark - takePicture
- (void)takePicture{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __block typeof(self) weakSelf = self;
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"从手机相册选择") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getInAlbum];
    }];
    [alertController addAction:alertAction1];
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"拍照") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getInCamera];
    }];
    [alertController addAction:alertAction2];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:alertController completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 从相册获取照片
- (void)getInAlbum{
    TZImagePickerController* imagePicker = [[[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES] autorelease];
    /**设置属性*/
    imagePicker.allowTakeVideo = NO;          //不允许内部视频
    imagePicker.allowTakePicture = YES;       //允许内部拍照
    imagePicker.allowPickingImage = YES;      //允许选择图片
    imagePicker.allowPickingVideo = NO;       //不允许选择视频
    imagePicker.showSelectedIndex = YES;
    imagePicker.allowCrop = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - TZImagePickerController delegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    
    self.imgCircleLogo = [photos firstObject];
    _ivHead.image = [photos firstObject];
    [self.headAddView bringSubviewToFront:_ivHead];
    [self textFieldChange:nil];
    [picker dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - 从相机获取照片
- (void)getInCamera{
    UIImagePickerController* imagePicker = [[[UIImagePickerController alloc] init]autorelease];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    self.imgCircleLogo = image;
    _ivHead.image = image;
    [self.headAddView bringSubviewToFront:_ivHead];
    [self textFieldChange:nil];
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (void)dealloc {
    [_imgCircleLogo release];
    [_ivHead release];
    [_tfCircleName release];
    [_growingTextView release];
    [_lbTextCount release];
    [_btnRight release];
    [_btnLeft release];
    [_scrollView release];
    [_headAddView release];
    [super dealloc];
}
@end
