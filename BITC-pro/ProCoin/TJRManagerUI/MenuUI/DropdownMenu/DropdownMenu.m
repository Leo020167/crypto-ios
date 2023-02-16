//
//  PreviewOperationMenu.m
//  taojinroad
//
//  Created by hh hh on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DropdownMenu.h"

#define cellHeight 36
@implementation DropdownMenu

@synthesize tableView;
@synthesize tableData;
@synthesize selectedIndex;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame style:(enum handleStyle)style
{
    self = [super initWithFrame:frame style:style];
    if(self) 
    {
        selectedIndex = 1;
        
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.frame = CGRectMake(0, roundRectImgVwRect.origin.y, roundRectImgVwRect.size.width - 1, roundRectImgVwRect.size.height - 12);
        [tableView setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
        tableView.separatorColor = [UIColor colorWithRed:0.267 green:0.263 blue:0.310 alpha:1.0];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self addSubview:tableView];
        
    }
    
    return self; 
}

- (void)dealloc
{
    
    
    [tableView release];
    [tableData release];
    [super dealloc];
}

- (void)setTableData:(NSArray *)data
{
    if (data.count<5) {
         tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, cellHeight*[data count]);
    }
   
    tableData=[data retain];
}

// 设定行高
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

// 返回行数
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

// 返回行
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.212 green:0.212 blue:0.239 alpha:1.0];
    }
    
    
    cell.textLabel.text = (NSString *)[tableData objectAtIndex:indexPath.row];
    
    
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    
    self.hidden = YES;

    if ([delegate respondsToSelector:@selector(menuClicked:menuId:)]) 
    {
        [delegate menuClicked:self menuId:indexPath.row];
    }
}


@end
