//
//  TJRCustomPushBar.h
//  
//
//  Created by Jason Lee on 12-3-12.
//  Copyright (c) 2012年 Taobao. All rights reserved.

#import <UIKit/UIKit.h>

@interface TJRCustomPushBar : UIView
{

}

+ (TJRCustomPushBar *)shareStatusBar;
- (void)showStatusMessage:(NSString *)message head:(NSString *)head didClicked:(void (^)(void))didClicked;

@end
