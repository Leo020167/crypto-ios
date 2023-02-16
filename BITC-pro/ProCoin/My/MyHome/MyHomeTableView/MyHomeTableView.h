//
//  MyHomeTableView.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-7.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseTableView.h"
#import "TJRUser.h"
#import "PicScalingFocus.h"
#import "TJRBaseViewController.h"
#import "RZWebImageView.h"

@protocol MyHomeTableViewDelegate <NSObject>

@required
- (void)MHTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)MHIsChanged:(BOOL)_changed;
@optional
- (void)nameTextFieldShouldBeginEditing;        //名字textfield编辑开始
- (void)nameTextFieldShouldEditingDidEnd;       //名字textfield编辑结束
@end

@interface MyHomeTableView :TJRBaseTableView <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UITextFieldDelegate>{
    UITextField *myNameTextField;
    PicScalingFocus *imageFocus;                         //头像放大控件
}


@property (retain, nonatomic) TJRBaseViewController *responderController;       //响应的基类
@property (retain, nonatomic) TJRUser *user;
@property (assign, nonatomic) id<MyHomeTableViewDelegate> mhDelegate;
@property (retain, nonatomic) RZWebImageView *headImageView;       //头像
@property (retain, nonatomic) UITextField *myNameTextField;

@end
