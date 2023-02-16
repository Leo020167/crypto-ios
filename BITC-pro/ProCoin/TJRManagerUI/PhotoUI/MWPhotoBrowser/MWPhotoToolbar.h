//
//  MWPhotoToolbar.h
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MWPhotoToolbar : UIView{
    MBProgressHUD *_progressHUD;
}

@property (nonatomic, retain) MBProgressHUD *progressHUD;
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

@property (nonatomic, retain) UIActionSheet *actionsSheet;
@end
