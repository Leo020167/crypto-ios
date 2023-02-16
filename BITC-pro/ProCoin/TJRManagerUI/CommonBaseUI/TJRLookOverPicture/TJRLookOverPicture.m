//
//  TJRLookOverPicture.m
//  Perval
//
//  Created by taojinroad on 2017/5/24.
//  Copyright © 2017年 Taojinroad. All rights reserved.
//

#import "TJRLookOverPicture.h"
#import "TTCacheManager.h"
#import "TJRBaseViewController.h"
#import "MLPhotoBrowserViewController.h"

@interface TJRLookOverPicture()<MLPhotoBrowserViewControllerDataSource,MLPhotoBrowserViewControllerDelegate> {
    NSMutableArray *photos;
    NSMutableDictionary* dic;
    TJRBaseViewController* fatherCtr;
}

@end

@implementation TJRLookOverPicture
- (id)init {
    self = [super init];
    
    if (self) {
        photos = [NSMutableArray new];
        dic = [NSMutableDictionary new];
        fatherCtr = (TJRBaseViewController *)ROOTCONTROLLER.navigationController.topViewController;
    }
    return self;
}



- (void)showPicView:(NSArray *)arrUrl pageIndex:(NSUInteger)pageIndex touchViews:(NSDictionary *)touchViews {
    // 图片游览器
    MLPhotoBrowserViewController* photoBrowser = [[[MLPhotoBrowserViewController alloc] init]autorelease];
    // 淡入淡出效果
    photoBrowser.status = UIViewAnimationAnimationStatusZoom;
    // 数据源/delegate
    photoBrowser.delegate = self;
    photoBrowser.dataSource = self;
    
    [photos removeAllObjects];
    [dic removeAllObjects];
    
    if (touchViews) [dic setDictionary:touchViews];
    if (arrUrl) [photos addObjectsFromArray:arrUrl];
    
    // 当前选中的值
    photoBrowser.currentIndexPath = [NSIndexPath indexPathForItem:pageIndex inSection:0];
    // 展示控制器
    [photoBrowser showPickerVc:fatherCtr];
    [photoBrowser reloadData];
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

- (void)dealloc {
    [dic removeAllObjects];
    [dic release];
    [photos removeAllObjects];
    [photos release];
    [super dealloc];
}
@end
