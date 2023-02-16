//
//  NPComboxList.m
//  taojinroad
//
//  Created by mac on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TJRComboxList.h"

#define kCBLListMaxHeight               200
#define kCBLListDefaultHeight           60
#define kCBLRateOfWAndH                 1.2
#define kCBLItemDefaultHeight           35
#define kCBLListMargin                  6
#define kCBLTextMargin                  2

@implementation TJRComboxList

@synthesize delegate;
@synthesize selectedIndex;
@synthesize listItemHeight;
@synthesize listData,tableView,textLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        listData = nil;
        listImageView = nil;
        selectedIndex = -1;
        listItemHeight = kCBLItemDefaultHeight;
        
        comboxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - frame.size.height * kCBLRateOfWAndH, frame.size.height)];
        comboxImageView.image = [[UIImage imageNamed:@"date_input_view_left"] stretchableImageWithLeftCapWidth:6 topCapHeight:8];
        [self addSubview:comboxImageView];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kCBLTextMargin, kCBLTextMargin, comboxImageView.frame.size.width - 2 * kCBLTextMargin, comboxImageView.frame.size.height - 3 * kCBLTextMargin)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = @"请选择";
        textLabel.font = [UIFont systemFontOfSize:14];
        [comboxImageView addSubview:textLabel];

        handleButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - frame.size.height * kCBLRateOfWAndH, 0, frame.size.height * kCBLRateOfWAndH, frame.size.height)];
        [self addSubview:handleButton];
        UIImage *image = [[UIImage imageNamed:@"date_input_view_right"] stretchableImageWithLeftCapWidth:16 topCapHeight:29];
        [handleButton setBackgroundImage:image forState:UIControlStateNormal];
        [handleButton setTitle:@"▼" forState:UIControlStateNormal];
        [handleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [handleButton addTarget:self action:@selector(handleButtonClicked:) forControlEvents:UIControlEventTouchDown];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        listData = nil;
        listImageView = nil;
        selectedIndex = -1;
        listItemHeight = kCBLItemDefaultHeight;
        CGRect frame=self.frame;
        comboxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - frame.size.height * kCBLRateOfWAndH, frame.size.height)];
        comboxImageView.image = [[UIImage imageNamed:@"date_input_view_left"] stretchableImageWithLeftCapWidth:6 topCapHeight:8];
        [self addSubview:comboxImageView];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kCBLTextMargin, kCBLTextMargin, comboxImageView.frame.size.width - 2 * kCBLTextMargin, comboxImageView.frame.size.height - 3 * kCBLTextMargin)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = @"请选择";
        textLabel.font = [UIFont systemFontOfSize:14];
        [comboxImageView addSubview:textLabel];
        
        handleButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - frame.size.height * kCBLRateOfWAndH, 0, frame.size.height * kCBLRateOfWAndH, frame.size.height)];
        [self addSubview:handleButton];
        UIImage *image = [[UIImage imageNamed:@"date_input_view_right"] stretchableImageWithLeftCapWidth:16 topCapHeight:29];
        [handleButton setBackgroundImage:image forState:UIControlStateNormal];
        [handleButton setTitle:@"▼" forState:UIControlStateNormal];
        [handleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [handleButton addTarget:self action:@selector(handleButtonClicked:) forControlEvents:UIControlEventTouchDown];
    }
    
    return self;
}

- (void)dealloc
{

    [listData release];
    [comboxImageView release];
    [handleButton release];
    [listImageView release];
    [tableView release];
    [textLabel release];
    [super dealloc];
}

- (void)adjustControls:(CGRect)frame
{
    comboxImageView.frame = CGRectMake(0, 0, frame.size.width - frame.size.height * kCBLRateOfWAndH, frame.size.height);
    
    handleButton.frame = CGRectMake(frame.size.width - frame.size.height * kCBLRateOfWAndH, 0, frame.size.height * kCBLRateOfWAndH, frame.size.height);
    
    NSInteger contentHeight = [listData count] * listItemHeight;
    if(listImageView == nil)
    {
        [self createListView:frame];
    }
    
    NSInteger listHeight = MIN(contentHeight, kCBLListMaxHeight);
    listHeight = MAX(listHeight, kCBLListDefaultHeight);
    listImageView.frame = CGRectMake(0, frame.size.height , frame.size.width, listHeight);
    tableView.frame = CGRectMake(0, frame.size.height, frame.size.width, listImageView.frame.size.height - kCBLListMargin);
    
    tableView.contentSize = CGSizeMake(tableView.frame.size.width, contentHeight);
}

- (void)createListView:(CGRect)frame
{
    UIView *view;
    UIImage *dropdownBorder;
    UIViewController *viewController;
    
    if(listImageView == nil)
    {
        if(delegate != nil)
        {
            viewController = (UIViewController *)delegate;
            view = viewController.view;
        }
        else
        {
            viewController = (UIViewController *)[[self nextResponder] nextResponder];
            view = viewController.view;
        }
        
        listImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];        
        [self addSubview:listImageView];
        listImageView.userInteractionEnabled = YES;
        listImageView.multipleTouchEnabled = YES;
        
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorColor = [UIColor colorWithRed:0.267 green:0.263 blue:0.310 alpha:1.0];
        [self addSubview:tableView];
        dropdownBorder = [[UIImage imageNamed:@"drop_down_border"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
        listImageView.image = dropdownBorder;
        listImageView.hidden = YES;
        tableView.hidden=YES;
    }
}

- (void)setListData:(NSMutableArray *)data
{
    if(listData != data)
    {
        TT_RELEASE_SAFELY(listData);
        listData=data;
        [self adjustControls:self.frame];
        [tableView reloadData];
    }
}

- (void)setListItemHeight:(NSInteger)itemHeight
{
    if(itemHeight != listItemHeight)
    {
        listItemHeight = itemHeight;
        [self adjustControls:self.frame];
    }
}

- (void)handleButtonClicked:(id)sender
{
    [self adjustControls:self.frame];
    listImageView.hidden = !listImageView.hidden;
    tableView.hidden=listImageView.hidden;
    if (tableView.hidden) {
        
        self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, kCBLItemDefaultHeight*2 + self.frame.size.height);
    }
    else {
        self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, kCBLItemDefaultHeight*2);
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [listData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return listItemHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if(listData != nil)
    {
        if(0 < [listData count])
        {
            if ([delegate respondsToSelector:@selector(comboxTableViewForRowAtIndexPath:tableData:indexPath:)]) 
            {
                [delegate comboxTableViewForRowAtIndexPath:cell tableData:listData indexPath:indexPath];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    selectedIndex = indexPath.row;
    listImageView.hidden = YES;
    if ([delegate respondsToSelector:@selector(comboxTableViewForRowAtIndexPath:tableData:indexPath:)]) 
    {
        [delegate comboxTableViewDidSelectRowAtIndexPath:self.tableView tableData:listData indexPath:indexPath];
    }
    
}

@end
