//
//  AboutUsViewController.h
//  TJRtaojinroad
//
//  Created by taojinroad on 13-8-12.
//  Copyright (c) 2017年 币吧. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseViewController.h"
#import "TJRAppInfo.h"

@interface AboutUsViewController : TJRBaseViewController
{
    BOOL bReqFinished;
}
@property (retain, nonatomic) NSTimer* timer;
@property (retain, nonatomic) TJRAppInfo *appInfo;
@property (retain, nonatomic) IBOutlet UILabel *versionLabel;
@property (retain, nonatomic) IBOutlet UIView *updateView;
@end
