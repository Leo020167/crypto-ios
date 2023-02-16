//
//  PreviewOperationMenu.h
//  taojinroad
//
//  Created by hh hh on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// 菜单类
#import <Foundation/Foundation.h>
#import "AirBubbleView.h"

@protocol MenuDelegate <NSObject>
@optional
- (void)menuClicked:(id)sender menuId:(NSInteger)menuId;
@end

@interface DropdownMenu : AirBubbleView<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger selectedIndex;
    UITableView *tableView;
    NSArray *tableData;
    id<MenuDelegate> delegate;
}

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *tableData;
@property (nonatomic, assign) id delegate;

- (id)initWithFrame:(CGRect)frame style:(enum handleStyle)style;

@end
