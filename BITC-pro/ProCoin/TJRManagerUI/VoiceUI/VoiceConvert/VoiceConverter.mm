//
//  VoiceConverter.m
//  taojinroad
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VoiceConverter.h"
#import "wav.h"
#import "interf_dec.h"
#import "dec_if.h"
#import "interf_enc.h"
#import "amrFileCodec.h"
#import "CommonUtil.h"

@implementation VoiceConverter

+ (int)amrToWav:(NSString *)fileNameString{
    
    NSString *path = [self getFilePath:fileNameString];
    
    NSString *savePath = [path stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"];
    return [VoiceConverter amrToWav:path savePath:savePath];
}

+ (BOOL)amrToWav:(NSString *)path savePath:(NSString *)savePath {
    BOOL success =DecodeAMRFileToWAVEFile([path cStringUsingEncoding:NSASCIIStringEncoding], [savePath cStringUsingEncoding:NSASCIIStringEncoding]);
    if (!success) {
        NSLog(@"amr转wav失败");
    }
    return success;
}

+ (int)wavToAmr:(NSString *)fileNameString{
    
//    NSString *path = [self getFilePath:fileNameString];
    
    // WAVE音频采样频率是8khz 
    // 音频样本单元数 = 8000*0.02 = 160 (由采样频率决定)
    // 声道数 1 : 160
    //        2 : 160*2 = 320
    // bps决定样本(sample)大小
    // bps = 8 --> 8位 unsigned char
    //       16 --> 16位 unsigned short
    
//    EncodeWAVEFileToAMRFile([docFilePath cStringUsingEncoding:NSASCIIStringEncoding],[docFilePath2 cStringUsingEncoding:NSASCIIStringEncoding],1,16);
    
    NSString *savePath = [fileNameString stringByReplacingOccurrencesOfString:@"wav" withString:@"amr"];
    
    if (EncodeWAVEFileToAMRFile([fileNameString cStringUsingEncoding:NSASCIIStringEncoding], [savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
        return 0;
    
    return 1;
}

//获取文件完整路径
+ (NSString*)getFilePath:(NSString*)fileNameString{
//    return fileNameString;
//    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    
//    NSString* file=[[[[fileNameString componentsSeparatedByString:@"/"]lastObject]componentsSeparatedByString:@"="]lastObject];
//    
//    NSString *soundFilePath= [documentsDirectory
//                              stringByAppendingPathComponent:file];
    
    return [CommonUtil TTPathForDocumentsResourceEtag:fileNameString];
}

+ (BOOL)isFileExistWithFileName:(NSString*)fileName{
    BOOL exist = NO;
    
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    exist = [fileManager fileExistsAtPath:[VoiceConverter getFilePath:fileName]];
    [fileManager release];
    return exist;
}

+ (BOOL)isFileExistWithFilePath:(NSString*)filePath{
    BOOL exist = NO;
    
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    exist = [fileManager fileExistsAtPath:filePath];
    [fileManager release];
    return exist;
}

@end
