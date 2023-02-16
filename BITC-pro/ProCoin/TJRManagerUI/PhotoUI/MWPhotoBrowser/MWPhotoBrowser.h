//
//  MWPhotoBrowser.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MWPhoto.h"
#import "MWPhotoProtocol.h"
#import "MWCaptionView.h"
#import "MBProgressHUD.h"

// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define MWLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define MWLog(x, ...)
#endif


// Delgate
@class MWPhotoBrowser;
@protocol MWPhotoBrowserDelegate <NSObject>
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
@optional
- (void)editButtonPressed:(MWPhotoBrowser *)photoBrowser;
- (void)backButtonPressed:(MWPhotoBrowser *)photoBrowser;
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (void)didPopViewControllerWithImage:(UIImage *)image index:(NSUInteger)index;
@end

// MWPhotoBrowser
@interface MWPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> 
{
    MBProgressHUD *_progressHUD;
}
// Properties
@property (nonatomic) BOOL displayActionButton;
@property (nonatomic) BOOL displayEditButton;
@property (nonatomic, retain) MBProgressHUD *progressHUD;
@property (nonatomic, assign) BOOL isHideToolBar;
// Init
- (id)initWithPhotos:(NSArray *)photosArray  __attribute__((deprecated)); // Depreciated
- (id)initWithDelegate:(id <MWPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setInitialPageIndex:(NSUInteger)index;

- (NSUInteger)getCurrentPageIndex;

- (void)toggleControls;

#pragma mark - 返回按钮
- (void)backButtonPressed:(id)sender;
#pragma mark - 右边更多操作按钮
- (void)actionButtonPressed:(id)sender;

#pragma mark - 从小到大动画的push
/**
	专为没有返回按钮的情况所用,再次点击消失
	@param disFrame  初始frame和最后消失时的frame
 */
- (void)pushViewControllerWithNoBackButtonWithDismissFrame:(CGRect)disFrame;

#pragma mark - 从大到小动画的pop
/**
	专为没有返回按钮的情况所用->消失
	@param disFrame  初始frame和最后消失时的frame
 */
- (void)popViewControllerWithNoBackButton;
@end


