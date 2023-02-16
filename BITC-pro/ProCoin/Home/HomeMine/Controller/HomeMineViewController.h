//
//  HomeMineViewController.h
//  TJRtaojinroad
//
//  Created by Hay on 15-3-26.
//  Copyright (c) 2015年 Taojinroad. All rights reserved.
//

#import "TJRBaseViewController.h"

@interface HomeMineEntity : NSObject
@property (nonatomic, retain) UIImage *iconImage;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *toPageName;
@property (nonatomic, assign) NSUInteger msgNumber;
@property (nonatomic, copy) NSString *tips;

+ (HomeMineEntity *)createWithName:(NSString *)name iconName:(NSString *)iconName toPageName:(NSString *)toPageName;
+ (HomeMineEntity *)createWithName:(NSString *)name iconName:(NSString *)iconName toPageName:(NSString *)toPageName tips:(NSString *)tips;
@end

@interface HomeMineViewController : TJRBaseViewController<UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray *dataArray;
    BOOL isShow;
}
@property (retain, nonatomic) IBOutlet UITableView *tvHome;
- (void)updataNewNum;

@end
