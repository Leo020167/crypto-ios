//
//  ConvertToMp3.h
//  LameTestDemo
//
//  Created by Jeans on 3/27/13.
//  Copyright (c) 2013 Jeans. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kLameSample         11025             //采样率
#define kLameKbs            16                  //码率
#define kLameChannels       2                   //通道数

    

@interface ConvertToMp3 : NSObject 

+ (void) convertToMp3ByResourePath:(NSString*)_sourcePath  savePath:(NSString*)_savePath;



@end
