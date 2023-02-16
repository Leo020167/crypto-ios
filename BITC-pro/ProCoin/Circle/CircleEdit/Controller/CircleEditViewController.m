//
//  CircleEditViewController.m
//  Tjrv
//
//  Created by taojinroad on 2019/3/1.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CircleEditViewController.h"
#import "RZWebImageView.h"
#import "HPGrowingTextView.h"
#import "NetWorkManage+Circle.h"
#import "NetWorkManage+File.h"
#import "CommonUtil.h"
#import "CircleEntity.h"
#import "TJRBaseParserJson.h"
#import "TZImagePickerController.h"
#import "UIImage+Size.h"

#define TAG_CIRCLE_BG      200
#define TAG_CIRCLE_LOGO    201

#define kUpOfHeight 40

@interface CircleEditViewController ()<TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,HPGrowingTextViewDelegate>{
    
    BOOL bReqFinished;
}

@property (retain, nonatomic) IBOutlet RZWebImageView *ivCircleBG;
@property (retain, nonatomic) IBOutlet RZWebImageView *ivHead;
@property (retain, nonatomic) IBOutlet UITextField *tfCircleName;
@property (retain, nonatomic) IBOutlet HPGrowingTextView *growingTextView;
@property (retain, nonatomic) IBOutlet UILabel *lbTextCount;
@property (retain, nonatomic) IBOutlet UIButton *btnLeft;
@property (retain, nonatomic) IBOutlet UIButton *btnRight;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@property (copy, nonatomic) NSString *circleId;
@property (retain, nonatomic) CircleEntity* circleEntity;
@property (retain, nonatomic) UIImage *imgCircleBG;
@property (retain, nonatomic) UIImage *imgCircleLogo;

@end

@implementation CircleEditViewController

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
    
    if([self getValueFromModelDictionary:CircleDict  forKey:@"circleId"]){
        self.circleId = [self getValueFromModelDictionary:CircleDict  forKey:@"circleId"];
        if (TTIsStringWithAnyText(_circleId)) {
            [self reqCircleData:_circleId];
        }
        [self removeParamFromModelDictionary:CircleDict forKey:@"circleId"];
    }
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

    if (_imgCircleLogo || _imgCircleBG) {
        NSMutableArray* imgArr = [[[NSMutableArray alloc]init]autorelease];
        if (_imgCircleBG) {
            NSString* fileName = [UIImage createOriginalImage:_imgCircleBG userId:ROOTCONTROLLER_USER.userId];
            if (TTIsStringWithAnyText(fileName)) {
                [imgArr addObject:fileName];
            }
        }
        if (_imgCircleLogo) {
            NSString* fileName = [UIImage createOriginalImage:_imgCircleLogo userId:ROOTCONTROLLER_USER.userId];
            if (TTIsStringWithAnyText(fileName)) {
                [imgArr addObject:fileName];
            }
        }
        if (imgArr.count>0) {
            [self reqUploadCircleFileData:imgArr];
        }
        
    }else{
        [self reqUploadCircleData:_circleId circleName:_tfCircleName.text brief:_growingTextView.text circleBg:_circleEntity.circleBg circleLogo:_circleEntity.circleLogo];
    }
}

- (IBAction)circleBGBtnClicked:(id)sender {
    [self takePicture:TAG_CIRCLE_BG];
}

- (IBAction)headButtonClicked:(id)sender {
    [self takePicture:TAG_CIRCLE_LOGO];
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
        }
        
        [_ivCircleBG showImageWithUrl:_circleEntity.circleBg];
        [_ivHead showImageWithUrl:_circleEntity.circleLogo];
        _tfCircleName.text = _circleEntity.circleName;
        _growingTextView.text = _circleEntity.brief;
    }
}

- (void)requestCircleFalid:(NSError *)error {
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

- (void)reqUploadCircleFileData:(NSMutableArray*)array{
    
    if (bReqFinished) {
        bReqFinished = NO;
        [[NetWorkManage shareSingleNetWork] reqUploadCircleBackground:self imageFiles:array finishedCallback:@selector(reqUploadFileFinished:) failedCallback:@selector(reqUploadCircleFailed:)];
    }
    
}

- (void)reqUploadCircleData:(NSString*)circleId circleName:(NSString*)circleName brief:(NSString*)brief circleBg:(NSString*)circleBg circleLogo:(NSString*)circleLogo{
    
    if (bReqFinished) {
        bReqFinished = NO;
        [[NetWorkManage shareSingleNetWork] reqCircleOppUpdate:self circleId:circleId circleName:circleName brief:brief circleLogo:circleLogo circleBg:circleBg finishedCallback:@selector(reqUploadCircleFinished:) failedCallback:@selector(reqUploadCircleFailed:)];
    }
    
}

- (void)reqUploadFileFinished:(id)result{
    bReqFinished = YES;
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init] autorelease];
    
    if ([jsonParser parseBaseIsOk:result]) {
        NSDictionary *dataDic = [result objectForKey:@"data"];
        NSArray* fileUrlArr = ((NSArray*)[dataDic objectForKey:@"imageUrlList"]);
        
        NSString* circleBg = @"";
        NSString* circleLogo = @"";
        if (_imgCircleBG && !_imgCircleLogo) {
            
            circleBg = fileUrlArr.count>0?[fileUrlArr firstObject]:_circleEntity.circleBg;
            circleLogo = _circleEntity.circleLogo;
            
        }else if (!_imgCircleBG && _imgCircleLogo) {
            
            circleBg = _circleEntity.circleBg;
            circleLogo = fileUrlArr.count>0?[fileUrlArr firstObject]:_circleEntity.circleLogo;
            
        }else if (_imgCircleBG && _imgCircleLogo) {
            circleBg = fileUrlArr.count>0?[fileUrlArr firstObject]:_circleEntity.circleBg;
            circleLogo = fileUrlArr.count>1?[fileUrlArr objectAtIndex:1]:_circleEntity.circleLogo;
        }

        NSString* fileBG = TTIsStringWithAnyText(circleBg)?circleBg:_circleEntity.circleBg;
        NSString* fileLogo = TTIsStringWithAnyText(circleLogo)?circleLogo:_circleEntity.circleLogo;
        NSLog(@"fileBG:%@",fileBG);
        NSLog(@"fileLogo:%@",fileLogo);
        [self reqUploadCircleData:_circleId circleName:_tfCircleName.text brief:_growingTextView.text circleBg:fileBG circleLogo:fileLogo];
        
    }else{
        NSString* str = @"发送失败";
        if ([result objectForKey:@"msg"]) {
            str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
        }
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_ERROR];
    }
}

- (void)reqUploadCircleFinished:(id)result{
    bReqFinished = YES;
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init] autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    if ([jsonParser parseBaseIsOk:result]) {
        [self putValueToParamDictionary:CircleDict value:[NSNumber numberWithBool:YES] forKey:RELOADDATA_DIC_KEY];
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_SUCCEED];
        _btnRight.enabled = NO;
        _btnLeft.enabled = NO;
        [self performSelector:@selector(goBack) withObject:nil afterDelay:1];
    }else{
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_ERROR];
    }
}

- (void)reqUploadCircleFailed:(id)result{
    bReqFinished = YES;
    [self showProgressHUDCompleteMessage:@"W.W.C.T提示" detailsMessage:@"发送失败" imageName:HUD_ERROR];
}

- (IBAction)backgroundClicked:(id)sender {

    if (_tfCircleName.isFirstResponder) {
        
        [_tfCircleName resignFirstResponder];
        [_scrollView setContentOffset:CGPointMake(0.0, 4.5 * kUpOfHeight) animated:YES];
        
    }else if (_growingTextView.isFirstResponder) {
        
        [_growingTextView resignFirstResponder];
        //滚动至底部
        [_scrollView setContentOffset:CGPointMake(0.0, MAX(0, _scrollView.contentSize.height + NAVIGATION_BAR_HEIGHT - phoneRectScreen.size.height)) animated:YES];
    }
}

#pragma mark - Text Field Delegate
- (IBAction)textFieldChange:(UITextField *)sender {
    if ((TTIsStringWithAnyText(_tfCircleName.text) && ![_tfCircleName.text isEqualToString:_circleEntity.circleName]) || (TTIsStringWithAnyText(_growingTextView.text) && ![_growingTextView.text isEqualToString:_circleEntity.brief]) || _imgCircleBG || _imgCircleLogo ) {
        _btnRight.enabled = YES;
    }else{
        _btnRight.enabled = NO;
    }
}

- (IBAction)textFieldDidEndOnExit:(id)sender {
    [self backgroundClicked:nil];
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField{
    [_scrollView setContentOffset:CGPointMake(0.0, 4.5 * kUpOfHeight) animated:YES];
}

#pragma mark - GrowingTextViewr Delegate Methods
- (void)growingTextViewClickFinish:(HPGrowingTextView *)growingTextView{
    [self backgroundClicked:nil];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    [self textFieldChange:nil];
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView{
    [_scrollView setContentOffset:CGPointMake(0.0, 4.5 * kUpOfHeight) animated:YES];
}

#pragma mark - takePicture
- (void)takePicture:(NSUInteger)tag{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __block typeof(self) weakSelf = self;
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"从手机相册选择") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf getInAlbum:tag];
    }];
    [alertController addAction:alertAction1];
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"拍照") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf getInCamera:tag];
    }];
    [alertController addAction:alertAction2];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:alertController completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 从相册获取照片
- (void)getInAlbum:(NSUInteger)tag{
    TZImagePickerController* imagePicker = [[[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES] autorelease];
    /**设置属性*/
    imagePicker.allowTakeVideo = NO;          //不允许内部视频
    imagePicker.allowTakePicture = YES;       //允许内部拍照
    imagePicker.allowPickingImage = YES;      //允许选择图片
    imagePicker.allowPickingVideo = NO;       //不允许选择视频
    imagePicker.showSelectedIndex = YES;
    imagePicker.showSelectBtn = NO;
    imagePicker.allowCrop = (tag == TAG_CIRCLE_LOGO);
    imagePicker.view.tag = tag;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - TZImagePickerController delegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    
    switch (picker.view.tag) {
        case TAG_CIRCLE_BG:
        {
            self.imgCircleBG = [photos firstObject];
            _ivCircleBG.image = [photos firstObject];
            break;
        }
        case TAG_CIRCLE_LOGO:
        {
            self.imgCircleLogo = [photos firstObject];
            _ivHead.image = [photos firstObject];
            break;
        }
        default:
            break;
    }
    [self textFieldChange:nil];
    [picker dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - 从相机获取照片
- (void)getInCamera:(NSUInteger)tag{
    UIImagePickerController* imagePicker = [[[UIImagePickerController alloc] init]autorelease];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.view.tag = tag;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    switch (picker.view.tag) {
        case TAG_CIRCLE_BG:
        {
            self.imgCircleBG = image;
            _ivCircleBG.image = image;
            break;
        }
        case TAG_CIRCLE_LOGO:
        {
            self.imgCircleLogo = image;
            _ivHead.image = image;
            break;
        }
        default:
            break;
    }
    [self textFieldChange:nil];
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (void)dealloc {
    [_imgCircleBG release];
    [_imgCircleLogo release];
    [_circleEntity release];
    [_circleId release];
    [_ivCircleBG release];
    [_ivHead release];
    [_tfCircleName release];
    [_growingTextView release];
    [_lbTextCount release];
    [_btnRight release];
    [_btnLeft release];
    [_scrollView release];
    [super dealloc];
}
@end
