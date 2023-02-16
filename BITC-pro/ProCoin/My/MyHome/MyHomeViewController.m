//
//  MyHomeViewController.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-11.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "MyHomeViewController.h"
#import "UIImage+Size.h"
#import "LoginSQLModel.h"
#import "HomeViewController.h"
#import "TTCacheManager.h"
#import "UserParser.h"
#import "NetWorkManage+Security.h"
#import "NetWorkManage+User.h"
#import "TJRBaseParserJson.h"
#import "CommonUtil.h"
#import "UIScrollView+AllowPanGestureEventPass.h"
#import "VeDateUtil.h"
#import "NetWorkManage+file.h"

#define kASTagSex                       104
#define kASTagHeadImage                 105

@interface MyHomeViewController () {
    BOOL bReqFinished;
}

@property (retain, nonatomic) IBOutlet UIButton *leftBtn;
@property (retain, nonatomic) IBOutlet UIDatePicker *myDatePicker;
@property (retain, nonatomic) IBOutlet UIView *maskView;
@property (retain, nonatomic) IBOutlet UIView *pickerView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutPickerViewBottom;

@end

@implementation MyHomeViewController
@synthesize mhTableView;
@synthesize compeleteBtn;
@synthesize headImage;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userInfo = [[TJRUser alloc]init];
    TJRUser *user = ROOTCONTROLLER_USER;
    userInfo.userId = user.userId;
    userInfo.name = user.name;
    userInfo.selfDescription = user.selfDescription;
    userInfo.headurl = user.headurl;
    userInfo.sex = user.sex;
    userInfo.userLevel = user.userLevel;
    userInfo.maxHeadUrl = user.maxHeadUrl;
    userInfo.birthday = user.birthday;
    userInfo.idCertify = user.idCertify;
    userInfo.userRealName = user.userRealName;
    userInfo.otcCertify = user.otcCertify;
    userInfo.ethAddress = user.ethAddress;
    userInfo.payPass = user.payPass;
    
    [self putValueToParamDictionary:MyHomeDict value:@"0" forKey:@"isRefresh"];
    [self putValueToParamDictionary:MyHomeDict value:userInfo forKey:@"User"];

    mhTableView.mhDelegate = self;
    mhTableView.user = userInfo;
    [mhTableView setScreenEdgePanGestureRecognizerPriority];

    bReqFinished = YES;
}

- (void)viewDidUnload {
    [self setHeadImage:nil];
    TT_RELEASE_SAFELY(userInfo);
    [self setMhTableView:nil];
    [self setCompeleteBtn:nil];
    [super viewDidUnload];
}

- (void)dealloc {

    [_maskView release];
    [_pickerView release];
    [_myDatePicker release];
    [headImage release];
    [self removeModelDictionaryFromParamDictionary:MyHomeDict];
    [userInfo release];
    [mhTableView release];
    [compeleteBtn release];
    [_leftBtn release];
    [_layoutPickerViewBottom release];
    [super dealloc];
}
- (IBAction)gobackPressed:(id)sender
{
    if (isChanged) {
        //显示提示窗口
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"您的资料已修改，是否要保存？") delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"不要") otherButtonTitles:NSLocalizedStringForKey(@"保存"), nil];
        [alert show];
        [alert release];
    }else
        [self goBack];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSString *s = [self getValueFromModelDictionary:MyHomeDict forKey:@"isRefresh"];
    if ([s isEqualToString:@"1"]) {
        [self putValueToParamDictionary:MyHomeDict value:@"0" forKey:@"isRefresh"];
        [self setIsChanged:YES];
        //刷新tableview
        [mhTableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - 从相册获取照片
- (void)getInAlbum{
    if (!imagePicker) {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
    }
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - 从相机获取照片
- (void)getInCamera{
    if (!imagePicker) {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
    }
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [self setIsChanged:YES];
    self.headImage = image;
    mhTableView.headImageView.image = image;
    userInfo.maxHeadUrl = @"";
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 点击picker的确定按键
- (IBAction)pickerSure:(id)sender {
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString;
    destDateString = [dateFormatter stringFromDate:_myDatePicker.date];
    
    if (![userInfo.birthday isEqualToString:destDateString]) {
        [self setIsChanged:YES];
        userInfo.birthday = destDateString;
    }
    
    [mhTableView reloadData];
    
    [self hidePickerView];
}

- (IBAction)pickerCancel:(id)sender {
    [self hidePickerView];
}

- (void)hidePickerView{

    [UIView animateWithDuration:0.3 animations:^{
        _maskView.alpha = 0;
        _layoutPickerViewBottom.constant = -260;
        [self.view layoutIfNeeded];
        
    }];
}

- (void)showPickerViewIfShowDatePicker:(BOOL)isDatePicker{
    _myDatePicker.hidden = !isDatePicker;

    [UIView animateWithDuration:0.3 animations:^{
        _layoutPickerViewBottom.constant = 0;
        _maskView.alpha = 0.5;
        [self.view layoutIfNeeded];
        
    }];
}

#pragma mark - MyHomeTableView Delegate Methods
- (void)nameTextFieldShouldBeginEditing
{
    //开始编辑时屏蔽滑动返回
    self.canDragBack = NO;
}

- (void)nameTextFieldShouldEditingDidEnd
{
    //编辑结束后启动
    self.canDragBack = YES;
}


- (void)MHTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == 0) {
        switch (row) {
            case 0:{        //更换头像
                UIActionSheet *imageActionSheet = [[UIActionSheet alloc]initWithTitle:@"选择个人头像" delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"取消")  destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringForKey(@"从手机相册选择"),NSLocalizedStringForKey(@"拍照"),nil];
                [imageActionSheet showInView:self.view];
                imageActionSheet.tag = kASTagHeadImage;
                [imageActionSheet release];
            }
                break;
            case 1:        //姓名
                break;
            case 2:        //ID
                break;
            case 3:{        //性别
                UIActionSheet *as = [[UIActionSheet alloc]initWithTitle:NSLocalizedStringForKey(@"性别") delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"取消")  destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringForKey(@"男"),NSLocalizedStringForKey(@"女"),nil];
                [as showInView:self.view];
                as.tag = kASTagSex;
                [as release];
            }
                break;
            case 4:{            //生日
                NSDateFormatter *dateformat = [[[NSDateFormatter alloc] init] autorelease];
                [dateformat setDateFormat:@"yyyy-MM-dd"];
                NSDate *beginDate = [dateformat dateFromString:userInfo.birthday];

                if (userInfo.birthday.length == 0 || [RAJudgement isContainNull:userInfo.birthday] || !beginDate) {
                    beginDate = [NSDate date];
                }
                _myDatePicker.date = beginDate;

                [self showPickerViewIfShowDatePicker:YES];
            }
                break;
        }
    }else if (section == 1) {
        
        switch (row) {
            case 0:            //个性签名
                [self pageToViewControllerForName:@"MyHomeSelfDescribtionViewController"];
                break;
            
            default:
                break;
        }
    }

}

#pragma mark -
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (actionSheet.tag) {
        case kASTagSex:{
            if (buttonIndex != [actionSheet cancelButtonIndex]) {
                if (buttonIndex == 0){
                    //男
                    if (![userInfo.sex isEqualToString:@"1"]){
                        [self setIsChanged:YES];
                        userInfo.sex = @"1";
                        [mhTableView reloadData];
                    }
                    
                }else if (buttonIndex == 1){
                    //女
                    if (![userInfo.sex isEqualToString:@"0"]){
                        [self setIsChanged:YES];
                        userInfo.sex = @"0";
                        [mhTableView reloadData];
                    }
                }
            }
        }
            break;
        
        case kASTagHeadImage:{
            if (buttonIndex != [actionSheet cancelButtonIndex]){
                switch (buttonIndex) {
                    case 0:
                        [self getInAlbum];
                        break;
                    case 1:
                        [self getInCamera];
                        break;
                }
            }
        }
            break;
    }
    [mhTableView reloadData];
}

- (void)MHIsChanged:(BOOL)_changed{
    isChanged = _changed;
    if (isChanged)[self setIsChanged:YES];
}

#pragma mark - RAJudgement Delegate Methods
- (void)RAShowToast:(NSString *)message{
    [self showToastCenter:message inView:self.view];
}
#pragma mark - 完成
- (IBAction)completePressed:(id)sender {
    if ([mhTableView.myNameTextField isFirstResponder])
        [mhTableView.myNameTextField resignFirstResponder];
    
    if (isChanged) {

        NSInteger len = [CommonUtil getChineseLength:userInfo.name];
        if (len <= 1) {
            [self showToastCenter:NSLocalizedStringForKey(@"昵称过于简短") inView:self.view];
            return;
        }else if (len > 6) {
            [self showToastCenter:NSLocalizedStringForKey(@"昵称长度太长") inView:self.view];
            return;
        }
        
        //保存个人信息
        compeleteBtn.enabled = NO;
        [self showProgressDefaultText];
        
        NSString* fileName = @"";
        if (headImage) {
            //如果有图片上传,把图片压缩然后存到本地
            fileName = [UIImage createThumbImage:headImage userId:userInfo.userId size:HEAD_ICON_SIZE];
            [[NetWorkManage shareSingleNetWork] reqUploadUserHeadUrlFile:self imageFile:fileName finishedCallback:@selector(reqUploadHeadFinished:) failedCallback:@selector(uploadpMyInfoFailed:)];
        }else{
            [[NetWorkManage shareSingleNetWork] reqMyHomeUploadMyInfo:self name:userInfo.name selfDescription:userInfo.selfDescription sex:userInfo.sex birthday:userInfo.birthday headFileName:userInfo.headurl finishedCallback:@selector(uploadpMyInfoFinished:) failedCallback:@selector(uploadpMyInfoFailed:)];
        }

    }else{
        [self showToastCenter:NSLocalizedStringForKey(@"资料并没有任何修改哦~") inView:self.view];
    }
}

- (void)uploadpMyInfoFinished:(NSDictionary*)result{
    [self dismissProgress];
    compeleteBtn.enabled = YES;
    bReqFinished = YES;
    
    UserParser *userParser = [[[UserParser alloc] init]autorelease];
    
    NSDictionary* json = [result objectForKey:@"data"];
    
    if ([userParser parseBaseIsOk:result]) {
        
        
        self.headImage = nil;
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:NSLocalizedStringForKey(@"资料修改成功") imageName:HUD_SUCCEED];
        [self setIsChanged:NO];
        
        ROOTCONTROLLER.user.name = [userParser stringParser:json name:@"userName"];
        ROOTCONTROLLER.user.sex = [userParser stringParser:json name:@"sex"];
        ROOTCONTROLLER.user.selfDescription = [userParser stringParser:json name:@"describes"];
        ROOTCONTROLLER.user.birthday = [userParser stringParser:json name:@"birthday"];
        
        [LoginSQLModel updateLoginInfo:ROOTCONTROLLER.user];

    }else{
        NSString* str = NSLocalizedStringForKey(@"资料修改失败");
        if ([result objectForKey:@"msg"]) {
            str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
        }
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_ERROR];
    }
    
}

- (void)uploadpMyInfoFailed:(NSDictionary*)jsonDic{
    [self dismissProgress];
    compeleteBtn.enabled = YES;
    bReqFinished = YES;
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提交信息失败") detailsMessage:NSLocalizedStringForKey(@"请稍后重试") imageName:HUD_ERROR];
}

- (void)reqUploadHeadFinished:(id)result{
    bReqFinished = YES;
    UserParser *userParser = [[[UserParser alloc] init]autorelease];
    
    if ([userParser parseBaseIsOk:result]) {
        
        NSDictionary* dic = [result objectForKey:@"data"];
        NSArray* fileUrlArr = ((NSArray*)[dic objectForKey:@"imageUrlList"]);
        if (fileUrlArr.count>0) {
            NSString *headurl = [fileUrlArr firstObject];
            headurl = headurl.length>0?headurl:@"";
            ROOTCONTROLLER_USER.headurl = headurl;
            userInfo.headurl = headurl;
        }
        if (TTIsStringWithAnyText(userInfo.headurl)) {
            [[NetWorkManage shareSingleNetWork] reqMyHomeUploadMyInfo:self name:userInfo.name selfDescription:userInfo.selfDescription sex:userInfo.sex birthday:userInfo.birthday headFileName:userInfo.headurl finishedCallback:@selector(uploadpMyInfoFinished:) failedCallback:@selector(uploadpMyInfoFailed:)];
        }
        
    }else{
        NSString* str = @"";
        if ([result objectForKey:@"msg"]) {
            str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
        }
        _leftBtn.enabled = YES;
        [self dismissProgress];
        [self showToastCenter:str inView:self.view];
    }
    
}

- (void)setIsChanged:(BOOL)_changed{
    isChanged = _changed;
    if (isChanged) {
        [compeleteBtn setTitleColor:RGBA(254, 84, 0, 1.0) forState:UIControlStateNormal];
    }else{
        [compeleteBtn setTitleColor:RGBA(188, 188, 188, 1.0) forState:UIControlStateNormal];
    }
}

#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        [self goBack];
    }else{
        [self completePressed:nil];
    }
}


@end
