//
//  PicScalingFocus.h
//  TJRtaojinroad
//
//  Created by road taojin on 12-10-12.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseObj.h"
#import "ASMediaFocusManager.h"
#import "TJRBaseView.h"

@class PicScalingFocus;

@protocol PicScalingFocusDelegate <NSObject>

- (UIImage *)picScalingFocus:(PicScalingFocus *)focus onTouchPic:(UIView *)view;
- (void)picScalingFocus:(PicScalingFocus *)focus editBtnClicked:(UIImage *)image;
- (void)picScalingFocus:(PicScalingFocus *)focus downloadFile:(UIView *)view;
- (void)focusManagerUninstall;

@end
@interface PicScalingFocus : TJRBaseView<ASMediasFocusDelegate>
{
    ASMediaFocusManager *focusManager;
    id <PicScalingFocusDelegate>delegate;
    NSMutableDictionary* tjrDicRequest;
}
@property (copy, nonatomic) NSString* chatTopicId;
@property (assign, nonatomic) ASMediaFocusManager *focusManager;
@property (assign, nonatomic) id delegate;
@property (copy, nonatomic) NSString* picPath;

- (void)loadImageWithURL:(NSString *)imageUrl;
@end
