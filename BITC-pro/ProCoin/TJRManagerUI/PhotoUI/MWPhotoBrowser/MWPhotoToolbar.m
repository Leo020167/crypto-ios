//
//  MJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MWPhotoToolbar.h"
#import "MWPhoto.h"

@interface MWPhotoToolbar()
{
    // 显示页码
    UILabel *_indexLabel;
    UIButton *_saveImageBtn;
}
@end

@implementation MWPhotoToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    if (_photos.count > 1) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.frame = self.bounds;
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indexLabel];
    }
    
    // 保存图片按钮
    CGFloat btnWidth = self.bounds.size.height;
    _saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveImageBtn.frame = CGRectMake(20, 0, btnWidth, btnWidth);
    _saveImageBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon.png"] forState:UIControlStateNormal];
    [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon_highlighted.png"] forState:UIControlStateHighlighted];
    [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveImageBtn];
}

- (void)saveImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MWPhoto *photo = _photos[_currentPhotoIndex];
        UIImageWriteToSavedPhotosAlbum(photo.underlyingImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [self showProgressHUDWithMessage:@"保存失败"];
    } else {
        _saveImageBtn.enabled = NO;
        [self showProgressHUDWithMessage:@"成功保存到相册"];
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    // 更新页码
    _indexLabel.text = [NSString stringWithFormat:@"%lu / %lu", _currentPhotoIndex + 1, (unsigned long)_photos.count];
    
}

#pragma mark - 右边更多操作按钮
//- (void)actionButtonPressed:(id)sender {
//    if (_actionsSheet) {
//        // Dismiss
//        [_actionsSheet dismissWithClickedButtonIndex:_actionsSheet.cancelButtonIndex animated:YES];
//    } else {
//        id <MWPhoto> photo = [self photoAtIndex:_currentPageIndex];
//        if ([self numberOfPhotos] > 0 && [photo underlyingImage]) {
//            
//            // Keep controls hidden
//            [self setControlsHidden:NO animated:YES permanent:YES];
//            
//            if (_displayEditButton) {
//                _actionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
//                                                   cancelButtonTitle:NSLocalizedString(NSLocalizedStringForKey(@"取消"), nil) destructiveButtonTitle:nil
//                                                   otherButtonTitles:NSLocalizedString(@"保存到手机", nil),NSLocalizedString(@"编辑图片", nil), nil];
//            }else{
//                _actionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
//                                                   cancelButtonTitle:NSLocalizedString(NSLocalizedStringForKey(@"取消"), nil) destructiveButtonTitle:nil
//                                                   otherButtonTitles:NSLocalizedString(@"保存到手机", nil), nil];
//            }
//            // Sheet
//            
//            _actionsSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                [_actionsSheet showFromBarButtonItem:sender animated:YES];
//            } else {
//                [_actionsSheet showInView:self.view];
//            }
//            
//        }
//    }
//}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == _actionsSheet) {
        // Actions
        self.actionsSheet = nil;
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            if (buttonIndex == actionSheet.firstOtherButtonIndex) {
               // [self savePhoto]; return;
            } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
               // [self editPhoto]; return;
            }
        }
    }

}

#pragma mark - MBProgressHUD

- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
        _progressHUD.backgroundRect = _progressHUD.frame;
        _progressHUD.center = [UIApplication sharedApplication].keyWindow.center;
        _progressHUD.minSize = CGSizeMake(120, 120);
        
        self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MWPhotoBrowser.bundle/images/tip_succeed.png"]] autorelease];
        [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
}

- (void)hideProgressHUD:(BOOL)animated {
    [self.progressHUD hide:animated];
}

- (void)showProgressHUDCompleteMessage:(NSString *)message {
    if (message) {
        if (self.progressHUD.isHidden) [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        [self.progressHUD hide:YES afterDelay:1.5];
    } else {
        [self.progressHUD hide:YES];
    }
}


@end
