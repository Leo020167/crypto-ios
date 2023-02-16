//
//  CMShareTimeBaseData.m
//  Cropyme
//
//  Created by Hay on 2019/7/1.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CMShareTimeBaseData.h"

@implementation CMShareTimeBaseData

- (void)dealloc
{
    [_time release];
    [_last release];
    [_currentVolume release];
    [super dealloc];
}

@end
