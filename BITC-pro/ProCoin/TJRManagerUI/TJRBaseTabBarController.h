//
//  TJRBaseTabBarController.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/3/20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+PublicMethods.h"
#import "HttpBase.h"

@interface TJRBaseTabBarController : UITabBarController{
    NSMutableDictionary *ttDelegateDictionary;
    CGRect phoneRectScreen;
}
@property (nonatomic, assign) BOOL progressLoging;
@property (nonatomic, retain) MBProgressHUD *progressHUD;

- (void)clearTTHttpDelegate;

#pragma mark - tjrDelegate
- (void)recordHttpRequest:(NSString *)cacheKey httpRequest:(id)httpRequest;
- (void)removeHttpRequestFromDictionary:(NSString *)cacheKey;


@end
