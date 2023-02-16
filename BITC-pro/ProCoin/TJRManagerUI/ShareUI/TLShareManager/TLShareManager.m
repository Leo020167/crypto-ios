//
//  TLShareManager.m
//  Tjrv
//
//  Created by Hay on 2019/4/4.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TLShareManager.h"
#import "CHTumblrMenuView.h"
#import "ShareBase.h"

@interface TLShareManager()
{
}
@property (retain, nonatomic) UIView *superView;
@property (retain, nonatomic) CHTumblrMenuView *shareMenuView;
@property (retain, nonatomic) ShareBase *shareBase;
@property (assign, nonatomic) NSInteger shareDestination;
@property (copy, nonatomic) NSString *shareParams;

@end

@implementation TLShareManager

- (instancetype)init
{
    self = [super init];
    if(self){
        
    }
    return self;
}


- (void)dealloc
{
    [_superView release];
    [_shareBase release];
    [_shareMenuView release];
    [_shareParams release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CHTumblrMenuView *)shareMenuView
{
    if(_shareMenuView == nil){
        _shareMenuView = [[CHTumblrMenuView alloc] init];
        NSArray *shareImageNameArray = [NSArray arrayWithObjects:@"share_logo_weixin", @"share_logo_pengyouquan", nil];
        NSArray *shareTitleArray = [NSArray arrayWithObjects:@"微信好友", @"微信朋友圈", nil];
        NSInteger size = (shareImageNameArray.count == shareTitleArray.count) ? [shareImageNameArray count] : 0;
        for (int i = 0; i < size; i++) {
            NSString *title = shareTitleArray[i];
            NSString *imageName = shareImageNameArray[i];
            __block typeof(self) weakSelf = self;
            [_shareMenuView addMenuItemWithTitle:title andIcon:[UIImage imageNamed:imageName] andSelectedBlock:^{
                [weakSelf shareViewMenuClicked:i];
            }];
        }
    }
    return _shareMenuView;
}

- (ShareBase *)shareBase
{
    if(!_shareBase){
        _shareBase = [[ShareBase alloc] init];
    }
    return _shareBase;
}

#pragma mark - 显示分享页面
- (void)showShareViewInView:(UIView *)view shareDestination:(TLShareDestination)shareDestination shareParams:(NSString *)shareParams
{
    self.superView = view;
    self.shareDestination = (NSInteger)shareDestination;
    self.shareParams = shareParams;
    
    [self.shareMenuView showWithBackView:view];
}

#pragma mark - _shareMenuView点击
- (void)shareViewMenuClicked:(NSInteger)menuId
{
    switch (menuId) {
        case 0:         //微信好友
            self.shareBase.isSession = YES;
            break;
        case 1:         //微信朋友圈
            self.shareBase.isSession = NO;
            break;
            
        default:
            break;
    }
    self.shareBase.shareParams = _shareParams;
    self.shareBase.shareType = [NSString stringWithFormat:@"%@",@(_shareDestination)];
    [self.shareBase share:_superView];
}


@end
