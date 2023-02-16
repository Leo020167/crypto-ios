//
//  TJRDropdownMenu.h
//  TJRtaojinroad
//
//  Created by road taojin on 12-9-8.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPPopoverController.h"
#import "DropdownMenu.h"

@interface TJRDropdownMenu : UITableViewController<FPPopoverControllerDelegate>
{
    NSArray *tableData;
    NSArray *imgTableData;
    id<MenuDelegate> delegate;
    FPPopoverController *popover;
    UIColor* bgColor;
    BOOL isBorder;
}
@property (nonatomic, retain) FPPopoverController *popover;
@property (nonatomic, retain) NSArray *tableData;
@property (nonatomic, retain) NSArray *imgTableData;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) CGSize menuSize;
@property (nonatomic, assign) BOOL isBorder;
#pragma mark - 清空图片和文字
- (void)clearImageAndTableData;
- (void)setMenuBlackgroud:(FPPopoverTint)tint;
- (void)presentPopoverFromView:(UIButton* )sender;
- (void)setMenuContentSize:(CGSize)size;
- (void)dismissPopover;
@end
