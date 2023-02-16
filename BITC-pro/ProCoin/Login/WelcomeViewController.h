//
//  WelcomeViewController.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-8-30.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "LoginBase.h"

@interface WelcomeViewController : TJRBaseViewController<LoginBaseDelegate>{
    LoginBase   *loginBase;
    BOOL isShow;
}
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *indicatorImageView;
@end
