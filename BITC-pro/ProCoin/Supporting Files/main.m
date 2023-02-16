//
//  main.m
//  TJRtaojinroad
//
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "TJRAppDelegate.h"

typedef int (*PYStdWriter)(void *, const char *, int);
static PYStdWriter oldStdWrite;

int pyStderrWrite(void *inFD, const char *buffer, int size) {
	if (strncmp(buffer, "AssertMacros:", 13) == 0) {
		return 0;
	}

	return oldStdWrite(inFD, buffer, size);
}

int main(int argc, char *argv[]) {
	oldStdWrite = stderr->_write;
	stderr->_write = pyStderrWrite;
	@autoreleasepool {
        
		return UIApplicationMain(argc, argv, nil, NSStringFromClass([TJRAppDelegate class]));
	}
}

