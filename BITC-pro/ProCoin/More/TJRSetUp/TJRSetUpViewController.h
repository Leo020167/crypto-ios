//
//  TJRSetUpViewController.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-9-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "TJRHeadView.h"
#import "PicScalingFocus.h"

@interface TJRSetUpViewController : TJRBaseViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate> {
    CGFloat folderSize;
    NSMutableArray *dataArray;
    BOOL isLoadFolderSize;
}
@property (retain, nonatomic) IBOutlet UITableView *tvSetUp;
@end
