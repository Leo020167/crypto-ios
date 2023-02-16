//
//  UncaughtExceptionHandler.h
//  TJRtaojinroad
//
//  Created by road taojin on 12-8-30.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface UncaughtExceptionHandler : NSObject
{
    BOOL dismissed;
}

void InstallUncaughtExceptionHandler();

+ (NSArray *)backtrace;

@end
