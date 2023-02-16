//
//  ModifyPasswordController.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "RAJudgement.h"

@interface ModifyPasswordController : TJRBaseViewController<UITextFieldDelegate,UIAlertViewDelegate,RAJudgementDelegate>

@property (retain, nonatomic) IBOutlet UITextField *oldPassword;
@property (retain, nonatomic) IBOutlet UITextField *textFieldNewPassword;
@property (retain, nonatomic) IBOutlet UITextField *textFieldNewPassword2;
@property (retain, nonatomic) IBOutlet UIControl *textBackgroundView;
@property (retain, nonatomic) IBOutlet UIButton *commitBtn;

@end
