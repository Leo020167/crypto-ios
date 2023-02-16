//
//  MyHomeViewController.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-11.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "TJRHeadView.h"
#import "MyHomeTableView.h"
#import "RAJudgement.h"

@interface MyHomeViewController : TJRBaseViewController<MyHomeTableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,RAJudgementDelegate,UIAlertViewDelegate>{
    UIImagePickerController     *imagePicker;
    TJRUser                     *userInfo;
    BOOL                        isChanged;
}

@property (retain, nonatomic) UIImage   *headImage;
@property (retain, nonatomic) IBOutlet MyHomeTableView *mhTableView;
@property (retain, nonatomic) IBOutlet UIButton *compeleteBtn;

@end
