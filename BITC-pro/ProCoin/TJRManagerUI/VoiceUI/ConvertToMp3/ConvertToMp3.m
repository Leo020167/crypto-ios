//
//  ConvertToMp3.m
//  LameTestDemo
//
//  Created by Jeans on 3/27/13.
//  Copyright (c) 2013 Jeans. All rights reserved.
//

#import "ConvertToMp3.h"

#include "lame.h"

@interface ConvertToMp3 () {
	NSInteger allCount;
	NSInteger curCount;
}
@property (copy, nonatomic) NSString *tempPath;
@property (copy, nonatomic) NSString *savePath;
@property (retain, nonatomic)   NSMutableDictionary *mDict;
@end

@implementation ConvertToMp3
@synthesize tempPath, mDict, savePath;

+ (void)convertToMp3ByResourePath:(NSString *)_sourcePath savePath:(NSString *)_savePath {
	@try {
		int read, write;

		FILE *pcm = fopen([_sourcePath cStringUsingEncoding:1], "rb");	// source
		fseek(pcm, 4 * 1024, SEEK_CUR);										// skip file header
		FILE *mp3 = fopen([_savePath cStringUsingEncoding:1], "wb");	// output

		const int PCM_SIZE = 8192;
		const int MP3_SIZE = 8192;
		short int pcm_buffer[PCM_SIZE * 2];
		unsigned char mp3_buffer[MP3_SIZE];

		lame_t lame = lame_init();
		lame_set_in_samplerate(lame, kLameSample);		// 设置采样率
		lame_set_VBR_max_bitrate_kbps(lame, kLameKbs);	// 设置码率
		lame_set_VBR(lame, vbr_default);
		lame_set_num_channels(lame, kLameChannels);			// 设置通道
		lame_init_params(lame);

		do {
			read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);

			if (read == 0) write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
			else write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);

			NSLog(@"normal :read:%d write:%d", read, write);
			fwrite(mp3_buffer, write, 1, mp3);
		} while (read != 0);

		lame_close(lame);
		fclose(mp3);
		fclose(pcm);
	}
	@catch(NSException *exception) {
		NSLog(@"%@", [exception description]);
	}
	@finally {
	}
}

- (id)init {
	self = [super init];

	if (self) {}
	return self;
}

- (void)dealloc {
	[savePath release];
	[tempPath release];
	[mDict release];
	[super dealloc];
}

@end

