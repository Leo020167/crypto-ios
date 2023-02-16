//
//  TJRCommonNavBar.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-8-30.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRCommonNavBar.h"

@implementation TJRCommonNavBar

- (void)drawRect:(CGRect)rect {
    UIImage *barImage = [UIImage imageNamed:@"light_gray_nav_bar@2x.png"];
    [barImage drawInRect:rect];
    
//    UILabel *t = [[UILabel alloc] initWithFrame:self.frame];
//    t.center = self.center;
//    t.font = [UIFont systemFontOfSize:21];
//    t.textColor = [UIColor colorWithRed:71/255.0f green:71/255.0f blue:71/255.0f alpha:1];
//    t.backgroundColor = [UIColor clearColor];
//    t.textAlignment = UITextAlignmentCenter;
//    t.text = self.topItem.title;
//    t.adjustsFontSizeToFitWidth=YES;
//    self.topItem.titleView = t;
//    [t release];
    
    
}

@end
