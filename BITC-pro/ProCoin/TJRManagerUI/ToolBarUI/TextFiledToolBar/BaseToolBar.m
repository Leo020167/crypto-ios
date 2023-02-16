//
//  BaseToolBar.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-8.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "BaseToolBar.h"

@implementation BaseToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


/**
 文本框toolBar
 @param delegate 接收事件的delegate
 @param titleArray 按钮的标题
 @param selArr selector数组，以nil结束
 @returns 返回toolbar实例
 */
- (id)initWithDelegate:(id)delegate TitleArray:(NSArray*)titleArray selectorArray:(SEL)selArr,...
{
    self = [self initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
    if (self) {
        self.barStyle = UIBarStyleDefault;
        NSMutableArray *items = [[NSMutableArray alloc]init];
        
        int i = 0;
        
        va_list argList;
        va_start(argList, selArr);
        SEL selector = nil;
        
        NSString *title = [titleArray objectAtIndex:i++];
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithTitle:title
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:delegate
                                                                  action:selArr];
        [items addObject:barItem];
        [barItem release];
        
        
        while ((selector = va_arg(argList, SEL))) {
            UIBarButtonItemStyle itemStyle = UIBarButtonItemStylePlain;
            if (i == [titleArray count] - 1) itemStyle = UIBarButtonItemStyleDone;
            
            NSString *title = [titleArray objectAtIndex:i++];
            UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithTitle:title
                                                                       style:itemStyle
                                                                      target:delegate
                                                                      action:selector];
            [items addObject:barItem];
            [barItem release];
        }
        va_end(argList);
        
        UIBarButtonItem *spaceBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
        [items insertObject:spaceBarItem atIndex:i-1];
        [spaceBarItem release];
        
        [self setItems:items];
        [items release];
    }
    
    return self;
}


@end
