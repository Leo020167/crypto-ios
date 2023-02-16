//
//  TJRDropdownMenu.m
//  TJRtaojinroad
//
//  Created by road taojin on 12-9-8.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRDropdownMenu.h"
#import "FPPopoverController.h"
#import "CommonUtil.h"

#define CellIdentifier @"cellIdentifier"

@interface TJRDropdownMenu ()
@end

#define cellHeight 44
#define textWidth  40
#define textFont   [UIFont systemFontOfSize:16.0]

@implementation TJRDropdownMenu

@synthesize popover, tableData, delegate, menuSize, isBorder;
@synthesize imgTableData;

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];

	if (self) {
		popover = [[FPPopoverController alloc] initWithViewController:self];
		popover.arrowDirection = FPPopoverArrowDirectionAny;
		self.tableView.separatorColor = RGBA(255, 255, 255, 0.5);
		[self setMenuBlackgroud:FPPopoverDefaultTint];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dragBackChange) name:DragBackChange object:nil];

		self.tableView.userInteractionEnabled = YES;

		if (CURRENT_DEVICE_VERSION >= 7.0) {
			self.tableView.separatorInset = UIEdgeInsetsZero;
		}

		if (CURRENT_DEVICE_VERSION >= 8.0) {
			self.tableView.separatorInset = UIEdgeInsetsZero;

			if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
				self.tableView.layoutMargins = UIEdgeInsetsZero;
			}
		}
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = nil;
}

- (void)dragBackChange {
	[self dismissPopover];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[imgTableData release];
	[tableData release];
	self.popover = nil;
	[super dealloc];
}

- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController shouldDismissVisiblePopover:(FPPopoverController *)visiblePopoverController {
	[visiblePopoverController dismissPopoverAnimated:YES];
	[visiblePopoverController autorelease];
}

- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController {}

- (void)dismissPopover {
	[popover dismissPopoverAnimated:YES];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.imgTableData = nil;
	self.tableData = nil;
}

- (void)presentPopoverFromView:(UIButton *)sender {
	if (![sender isKindOfClass:[UIButton class]]) {
		NSLog(@"只能为button对象");
		assert([sender isKindOfClass:[UIButton class]]);
		return;
	}
	[popover presentPopoverFromView:sender];
}

- (void)setMenuBlackgroud:(FPPopoverTint)tint {
	switch (tint) {
		case FPPopoverBlueTint:
			bgColor = RGBA(0, 113, 188, 0.95);
			break;

		case FPPopoverRedTint:
			bgColor = [UIColor colorWithRed:0.36 green:0.0 blue:0.09 alpha:1.0];
			break;

		case FPPopoverBlackTint:
			bgColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
			break;

		case FPPopoverGreenTint:
			bgColor = [UIColor colorWithRed:0.18 green:0.30 blue:0.03 alpha:1.0];
			break;

		case FPPopoverLightGrayTint:
			bgColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
			break;
	}

	popover.tint = tint;
	self.tableView.backgroundColor = bgColor;
}

#pragma mark - 设置是否有边框
- (void)setIsBorder:(BOOL)border {
	popover.isBorder = border;
}

#pragma mark - 清空图片和文字
- (void)clearImageAndTableData {
	RELEASE(imgTableData);
	RELEASE(tableData);
}

#pragma mark - 设置菜单文字
- (void)setTableData:(NSArray *)data {
	CGSize size;
	CGFloat width = 0;

	for (NSString *str in [data objectEnumerator]) {
        size = [str sizeWithAttributes:@{NSFontAttributeName:textFont}];
		width = MAX(size.width, width);
	}

	if (imgTableData.count > 0) {
		assert(imgTableData.count == data.count);// 图片个数必须也列表数相同，字符串可以为空，但必须写上
		width = width + 36;
	}
	popover.contentSize = CGSizeMake(width + textWidth + 1, popover.contentSize.height);

	if (data.count <= 5) {
		popover.contentSize = CGSizeMake(width + textWidth + 1, cellHeight *[data count] + 45);
	}
	menuSize = popover.contentSize;
	popover.localSize = menuSize;
	[tableData release];
	tableData = nil;
	tableData = [data retain];
}

#pragma mark - 设置菜单图片
- (void)setImgTableData:(NSArray *)data {
	assert(!tableData);	// 图片个数必须也列表数相同，setImgTableData要在setTableData之前
	TT_RELEASE_SAFELY(imgTableData);
	imgTableData = [data retain];
}

- (void)setMenuContentSize:(CGSize)size {
	popover.contentSize = size;
}

// 设定行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return cellHeight;
}

// 返回行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [tableData count];
}

// 返回行
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	static NSString *cellIdentifier = @"TJRDropdownMenuCell";

	cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"TJRDropdownMenuCell" owner:self options:nil] lastObject];
		cell.backgroundColor = [UIColor clearColor];
		UILabel *text = (UILabel *)[cell viewWithTag:101];
		text.font = textFont;
		text.textColor = [UIColor whiteColor];
	}
	UILabel *text = (UILabel *)[cell viewWithTag:101];
	UIImageView *image = (UIImageView *)[cell viewWithTag:100];
	image.image = nil;
	text.text = (NSString *)[tableData objectAtIndex:indexPath.row];

	if (imgTableData.count > 0) {
		text.textAlignment = NSTextAlignmentLeft;
		image.image = [UIImage imageNamed:(NSString *)[imgTableData objectAtIndex:indexPath.row]];
	}

	if (image.image == nil) {
		text.textAlignment = NSTextAlignmentCenter;
		CGRect frame = text.frame;
		frame.size.width = popover.contentSize.width - 5;
		frame.origin.x = -10;
		text.frame = frame;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[popover dismissPopoverAnimated:YES];

	if ([delegate respondsToSelector:@selector(menuClicked:menuId:)]) {
		[delegate menuClicked:self menuId:indexPath.row];
	}
}

@end
