//
//  NewFeaturesView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 13-4-27.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "NewFeaturesView.h"

#define AfterDelay          0.8

@implementation NewFeaturesView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        svScroll = [[UIScrollView alloc] initWithFrame:frame];
        svScroll.pagingEnabled = YES;
        svScroll.showsHorizontalScrollIndicator = NO;
        svScroll.bounces = NO;
        [self addSubview:svScroll];
//        imageArray = [[NSArray alloc] initWithObjects:@"NewFeaturesImage_1",@"NewFeaturesImage_2",@"NewFeaturesImage_3",@"NewFeaturesImage_4",@"NewFeaturesImage_5", nil];
//        bottomColorArray = [[NSArray alloc] initWithObjects:RGBA(229.0, 229.0, 229.0, 1),RGBA(229.0, 229.0, 229.0, 1),RGBA(25.0, 25.0, 26.0, 1),RGBA(229.0, 229.0, 229.0, 1),RGBA(229.0, 229.0, 229.0, 1), nil];
//        NSAssert(imageArray.count == bottomColorArray.count, @"图片数目与背景色必须一致");
        [self performSelectorInBackground:@selector(createImageView) withObject:nil];
    }
    return self;
}

#pragma mark - 检查是否显示软件新功能介绍
+ (BOOL)isShowNewFeaturesView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tjrAppVersion = [defaults valueForKey:@"tjrAppVersion"];
    return ISHD && (!tjrAppVersion || [tjrAppVersion intValue] < [TJRAppVersion intValue]);//低清屏不显示
}

- (void)createImageView {
    for (int i=0;i < imageArray.count;i++) {
        NSString *imageName = [imageArray objectAtIndex:i];
        CGRect frame = self.frame;
        frame.origin.x = i*frame.size.width;
        UIImageView *background = [[UIImageView alloc] initWithFrame:frame];
        if (i != 2) background.backgroundColor = [bottomColorArray objectAtIndex:i];
        else background.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NewFeaturesImage_bottom" ofType:@"jpg"]];
        [svScroll addSubview:background];
        RELEASE(background);
        
        frame.size.height = 480;
        frame.origin.y = (self.frame.size.height - 500)/5;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.backgroundColor = [UIColor clearColor];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        imageView.image = image;
        [svScroll addSubview:imageView];
        RELEASE(imageView);
        if (i == imageArray.count - 1) {
            UIButton *btnOk = [UIButton buttonWithType:UIButtonTypeCustom];
            btnOk.frame = CGRectMake(frame.origin.x + 88, frame.origin.y + 400, 144, 47);
            [btnOk setTitle:@"马上体验" forState:UIControlStateNormal];
            [btnOk setBackgroundImage:[UIImage imageNamed:@"NewFeaturesImage_IKnow"] forState:UIControlStateNormal];
            [btnOk setTintColor:[UIColor whiteColor]];
            [btnOk addTarget:self action:@selector(iKnowAction:) forControlEvents:UIControlEventTouchUpInside];
            [svScroll addSubview:btnOk];
            [svScroll bringSubviewToFront:btnOk];
        }
    }
    [svScroll setContentSize:CGSizeMake(imageArray.count*self.frame.size.width, 0)];
    [svScroll setContentOffset:CGPointZero animated:NO];
}

#pragma mark - 显示软件新功能提示
- (void)showNewFeatures:(UIView *)view {
    if (!imageArray || imageArray.count == 0) {
        return;
    }
    self.alpha = 0;
    [view addSubview:self];
    [view bringSubviewToFront:self];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:AfterDelay];
    self.alpha = 1;
    [UIView commitAnimations];
}

- (void)iKnowAction:(id)btn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:TJRAppVersion forKey:@"tjrAppVersion"];
    [defaults synchronize];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:AfterDelay];
    self.alpha = 0;
    [UIView commitAnimations];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:AfterDelay];
}

- (void)dealloc {
    RELEASE(bottomColorArray);
    RELEASE(svScroll);
    RELEASE(imageArray);
    [super dealloc];
}

@end
