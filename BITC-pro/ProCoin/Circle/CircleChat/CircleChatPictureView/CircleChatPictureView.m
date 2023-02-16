//
//  ChatPictureController.m
//  TJRtaojinroad
//
//  Created by road taojin on 12-10-12.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "CircleChatPictureView.h"
#import "TTCacheManager.h"
#import "TJRBaseViewController.h"
#import "MLPhotoBrowserViewController.h"

@interface CircleChatPictureView () <MLPhotoBrowserViewControllerDataSource,MLPhotoBrowserViewControllerDelegate>{

}

@end

@implementation CircleChatPictureView

- (id)init {
	self = [super init];

	if (self) {
		photos = [[NSMutableArray alloc] init];
		dic = [[NSMutableDictionary alloc] init];
		fatherCtr = (TJRBaseViewController *)ROOTCONTROLLER.navigationController.topViewController;
	}
	return self;
}



- (void)showPicView:(NSMutableArray *)arrUrl pageIndex:(NSUInteger)pageIndex touchViews:(NSMutableDictionary*)touchViews{
    
    // 图片游览器
    MLPhotoBrowserViewController* photoBrowser = [[[MLPhotoBrowserViewController alloc] init]autorelease];
    // 淡入淡出效果
    photoBrowser.status = UIViewAnimationAnimationStatusZoom;
    // 数据源/delegate
    photoBrowser.delegate = self;
    photoBrowser.dataSource = self;

    [photos removeAllObjects];
    [dic removeAllObjects];
    
    for (NSString* key in [touchViews allKeys]) {
        id obj = [touchViews objectForKey:key];
        if (obj) {
            [dic setObject:obj forKey:key];
        }
    }
    
    for (int i = 0; i < arrUrl.count; i++) {
        NSString *URL = [arrUrl objectAtIndex:i];
        [photos addObject:URL];
    }

    // 当前选中的值
    photoBrowser.currentIndexPath = [NSIndexPath indexPathForItem:pageIndex inSection:0];
    // 展示控制器
    [photoBrowser showPickerVc:fatherCtr];

    [photoBrowser reloadData];
}

- (void)dealloc {

	[dic release];
	[photos release];
	[super dealloc];
}

#pragma mark - <MLPhotoBrowserViewControllerDataSource>
- (NSInteger)photoBrowser:(MLPhotoBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    return photos.count;
}

#pragma mark - 每个组展示什么图片,需要包装下MLPhotoBrowserPhoto
- (MLPhotoBrowserPhoto *) photoBrowser:(MLPhotoBrowserViewController *)browser photoAtIndexPath:(NSIndexPath *)indexPath{
    // 包装下imageObj 成 ZLPhotoPickerBrowserPhoto 传给数据源
    MLPhotoBrowserPhoto *photo = [[[MLPhotoBrowserPhoto alloc] init]autorelease];
    photo.photoObj = [photos objectAtIndex:indexPath.row];
    // 缩略图
    UIImageView* iV= [dic objectForKey:[photos objectAtIndex:indexPath.row]];
    photo.toView = iV;
    photo.thumbImage = iV.image;
    return photo;
}

@end

