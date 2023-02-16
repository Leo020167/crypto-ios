//
//  TJRComboxList.h
//  taojinroad
//
//  Created by mac on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ComboxListDelegate <NSObject>
@optional
- (void)comboxTableViewForRowAtIndexPath:(UITableViewCell *)cell tableData:(NSMutableArray*)tableData indexPath:(NSIndexPath *)indexPath;
- (void)comboxTableViewDidSelectRowAtIndexPath:(UITableView *)tableView tableData:(NSMutableArray*)tableData indexPath:(NSIndexPath *)indexPath;
@end

@interface TJRComboxList : UIView <UITableViewDelegate, UITableViewDataSource>
{
    id <ComboxListDelegate> delegate;
    NSInteger selectedIndex;
    NSInteger listItemHeight;
    NSMutableArray *listData;
    UIImageView *comboxImageView;
    UIButton *handleButton;
    UIImageView *listImageView;
    UITableView *tableView;
    UILabel *textLabel;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger listItemHeight;
@property (nonatomic, retain) NSMutableArray *listData;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UILabel *textLabel;
- (void)adjustControls:(CGRect)frame;
- (void)handleButtonClicked:(id)sender;
- (void)createListView:(CGRect)frame;

@end
