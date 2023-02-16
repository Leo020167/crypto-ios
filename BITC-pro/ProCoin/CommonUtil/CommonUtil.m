//
//  CommonUtil.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-27.
//  Copyright (c) 2012年 Taojinroad. All rights reserved.
//

#import "CommonUtil.h"
#import "TTGlobalCore.h"
#import "pinyin.h"
#import <mach/mach_time.h>
#import "ZipArchive.h"
#import "TTURLCache.h"

#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>
#import "Encryption.h"
#import "TTCacheManager.h"
#import "RSA.h"
#import "TJRBaseViewController.h"
#import "HomeViewController.h"
#import <UserNotifications/UserNotifications.h>

#define NUMBER @"0123456789"

@implementation CommonUtil

#pragma mark - 把字符串json格式化NSDictionary
+ (id)jsonValue:(NSString *)json {
	if (TTIsStringWithAnyText(json)) {
		@try {
			NSError *error;
            json = [json stringByReplacingOccurrencesOfString:@"\r" withString:@""];
			NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
			id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
			return dic;
		}
		@catch(NSException *exception) {
			NSLog(@"%@", exception.description);
		}
	}

	return nil;
}

#pragma mark - 把NSDictionary 或 NSArray 转换成Json
+ (NSString *)jsonToString:(id)jsonDic {
	if (!jsonDic || ![NSJSONSerialization isValidJSONObject:jsonDic] || ([jsonDic isKindOfClass:[NSString class]] && !TTIsStringWithAnyText(jsonDic))) return nil;

	@try {
		NSError *error = nil;
        NSString *json = @"";
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:0 error:&error];
        if ([jsonData length] > 0 &&error == nil){
            NSString *temp = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            json = [NSString stringWithString:temp];
            RELEASE(temp);
        }
        else if ([jsonData length] == 0 &&error == nil){
            NSLog(@"No data was returned after serialization.");
        }
        else if (error != nil){
            NSLog(@"An error happened = %@", error);
        }
		return json;
	}
	@catch(NSException *exception) {
		NSLog(@"%@", exception.description);
	}
	return nil;
}

#pragma mark - 格式化数据,保留两位小数(字符串型的)
+ (NSString *)formatNumberForString:(NSString *)value {
	if (!value || (value.length <= 0)) {
		return @"0.00";
	}

	return [NSString stringWithFormat:@"%.2f", [value floatValue]];
}

#pragma mark - 格式化整形(超过一千用K显示)
+ (NSString *)formatIntegerWithK:(NSInteger)number
{
    if(number >= 1000){
        CGFloat value = number / 1000.0f;
        return [NSString stringWithFormat:@"%.1fK",value];
    }else{
        return [NSString stringWithFormat:@"%@",@(number)];
    }
}

#pragma mark - 获取涨幅颜色(涨红,跌绿,0白)
+ (UIColor *)getRateColor:(float)rate {
	if (rate > 0) {
		return QuotationRedColor;
	} else if (rate == 0.0f) {
		return QuotationGrayColor;
	} else {
		return rate < -99.0f ? QuotationGrayColor : QuotationGreenColor;
	}
}

#pragma mark - 获取颜色(正红,负绿,0白)
+ (UIColor *)getDataColorWithTodayOpen:(double)open Yesterday:(double)yesterday {
	return [self getDataColor:open - yesterday];
}

#pragma mark - 获取颜色(正红,负绿,0白)
+ (UIColor *)getDataColor:(float)data {
	if (data > 0) {
		return QuotationRedColor;
	} else if (data == 0.0f) {
		return QuotationWhiteColor;
	} else {
		return QuotationGreenColor;
	}
}

#pragma mark - 获取颜色(正红,负绿,0自定义)
+ (UIColor *)getDataColor:(float)data withZeroColor:(UIColor *)color {
	if (data > 0) {
		return QuotationRedColor;
	} else if (data == 0.0f) {
		return color;
	} else {
		return QuotationGreenColor;
	}
}

#pragma mark - 获取涨幅颜色(涨红,跌绿,0白)  涨幅为字符串型
+ (UIColor *)getRateColorForString:(NSString *)rateString {
	float rate = [[NSString stringWithString:rateString] floatValue];

	return [self getRateColor:rate];
}

#pragma mark - 获取涨幅颜色(通过今日开盘和昨日收盘)
+ (UIColor *)getRateColorWithTodayOpen:(double)open Yesterday:(double)yesterday {
	return [self getRateColor:open - yesterday];
}

#pragma mark - 获取涨幅颜色(涨红,跌绿,0白)获取涨幅颜色,自带为0的颜色 (涨红,跌绿)
+ (UIColor *)getRateColor:(float)rate withZeroColor:(UIColor *)zeroColor {
    return [self getRateColor:rate minimum:-99 withZeroColor:zeroColor];
}

#pragma mark - 获取涨幅颜色(涨红,跌绿,0白)获取涨幅颜色,自带为0的颜色 (涨红,跌绿)
+ (UIColor *)getRateColor:(float)rate minimum:(CGFloat)minimum withZeroColor:(UIColor *)zeroColor {
	if (rate > 0) {
		return QuotationRedColor;
	} else if (rate == 0.0f) {
		return zeroColor;
	} else {
		return rate < minimum ? zeroColor : QuotationGreenColor;
	}
}

#pragma mark - 获取涨幅颜色(涨红,跌绿,0白)获取涨幅颜色,自带为0的颜色 (涨红,跌绿)  涨幅为字符串型
+ (UIColor *)getRateColorForString:(NSString *)rateString withZeroColor:(UIColor *)zeroColor {
	float rate = [[NSString stringWithString:rateString] floatValue];

	return [self getRateColor:rate withZeroColor:zeroColor];
}

#pragma mark - 获取买卖性质颜色(S为绿,B为红,其他为白)
+ (UIColor *)getNatureColor:(NSString *)nature {
	if ([@"B" isEqualToString:nature]) {
		return QuotationRedColor;
	} else {
		return [@"S" isEqualToString:nature] ? QuotationGreenColor : QuotationWhiteColor;
	}
}

#pragma mark - 我的自选股视图里列表右边的涨跌颜色图片
+ (NSString *)getMyStockRateImageName:(float)rate {
	if (rate >= 0) {
		return @"quotation_btn_rate_red@2x.png";
	} else {
		return @"quotation_btn_rate_green@2x.png";
	}
}

#pragma mark - 格式化成交量
+ (NSString *)formatVolume:(long long)volume {
	if (volume >= 1E10) {
		return [NSString stringWithFormat:@"%.2f亿", (volume / 1E10)];
	} else if (volume >= 1E6) {
		return [NSString stringWithFormat:@"%.2f万", (volume / 1E6)];
	} else {
		return [NSString stringWithFormat:@"%lld", (volume / 100)];
	}
}

#pragma mark - 格式化数据(字符串)
+ (NSString *)formatDataForString:(NSString *)assets {
	if (!assets) {
		return 0;
	}

	return [self formatDateForLong:[assets integerValue]];
}

#pragma mark - 格式化数据(长整型)
+ (NSString *)formatDateForLong:(NSUInteger)assets {
	if (assets >= 1E12) {
		return [NSString stringWithFormat:@"%.2f万亿", (CGFloat)assets / 1E12];
	} else if (assets >= 1E8) {
		return [NSString stringWithFormat:@"%.2f亿", (CGFloat)assets / 1E8];
	} else if (assets >= 1E4) {
        CGFloat result = assets / 10000.0f;
        if (result < 10) {
            return [NSString stringWithFormat:@"%.2f万", result];
        } else if (result < 100) {
            return [NSString stringWithFormat:@"%.1f万", result];
        } else {
            return [NSString stringWithFormat:@"%.0f万", result];
        }
	} else {
		return [NSString stringWithFormat:@"%@", @(assets)];
	}
}

#pragma mark - 格式化数据(double型)
+ (NSString *)formatDateForDouble:(double)assets {
	if (assets >= 1E8 || assets <= -1E8) {
		return [NSString stringWithFormat:@"%.2f亿", (float)assets / 1E8];
    } else if (assets >= 1E4 || assets <= -1E4) {
        return [NSString stringWithFormat:@"%.2f万", (float)assets / 1E4];
	} else {
		return [NSString stringWithFormat:@"%.2f", assets];
	}
}

#pragma mark - 格式化数据(double型)不保留小数
+ (NSString *)formatDateForDoubleNoMedian:(double)assets {
	if (assets >= 1E8) {
		return [NSString stringWithFormat:@"%.0f亿", (float)assets / 1E8];
	} else if (assets >= 1E4) {
		return [NSString stringWithFormat:@"%.0f万", (float)assets / 1E4];
	} else {
		return [NSString stringWithFormat:@"%.0f", assets];
	}
}

#pragma mark - 格式化数据,显示加减符号
+ (NSString *)formatDataForStringComplete:(float)assets format:(NSString *)format {
	NSString *f = assets > 0 ? @"+" : @"";
	return [NSString stringWithFormat:[NSString stringWithFormat:@"%@%@", f, format], assets];
}

#pragma mark - 计算纵坐标
+ (double)getCharPixelY:(double)max spanY:(double)spanY value:(double)value {
	if (spanY == 0.0) {
		return 0.0f;
	}

	if (value <= 0.0) {
		return max / spanY;
	}

	if (value == max) {
		return 0.1f;
	}

	return (double)((max - value) / spanY);
}

#pragma mark - 计算纵坐标(值可以为负)
+ (float)getCharPixelYCanNegative:(float)max spanY:(float)spanY value:(float)value {
	if (spanY == 0.0) {
		return 0.0f;
	}

	return (float)((max - value) / spanY);
}

#pragma mark - 计算成交量纵坐标
+ (float)getVolumeY:(float)max spanY:(float)spanY value:(long long)value {
	double result = 0.0f;

	if (spanY <= 0.0) {
		return 2.0f;
	}

	if (value <= 0.0) {
		return max / spanY;	/* 成交量为0,柱状图就为空 */
	}

	if (value == max) {
		return 0.1f;/* 涨停线 */
	}

	result = (max - value) / spanY;

	if (result >= max / spanY) {
		result = max / spanY - 2;	/* 跌停线 */
	}

	return (float)result;
}

#pragma mark - 以正则表达式判断字符串是否符合
+ (BOOL)isMatched:(NSString *)value byRegex:(NSString *)regex {
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

	return [pred evaluateWithObject:value];
}

#pragma mark - tableView cell 的背景图
+ (void)setCellBackground:(UITableViewCell *)cell {
	[self setCellBackground:cell imageName:@"CellBackground"];
}

#pragma mark - tableView cell 的背景图 ,imageName:图片路径
+ (void)setCellBackground:(UITableViewCell *)cell imageName:(NSString *)imageName {
	NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
	UIImage *backgroundImage = [UIImage imageWithContentsOfFile:backgroundImagePath];

	if (backgroundImage) {
		backgroundImage = [self stretchableImageWithImage:backgroundImage edgeInsets:UIEdgeInsetsMake(1.35, 0, backgroundImage.size.height - 1.0, backgroundImage.size.width)];
	}

	UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
	cell.backgroundView = imageView;
	cell.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	cell.backgroundView.frame = cell.bounds;
	cell.backgroundView.userInteractionEnabled = YES;
	RELEASE(imageView);
}

#pragma 从fullcode里截取到dm
+ (NSString *)getDMFromFullcode:(NSString *)fullcode {
	if (TTIsStringWithAnyText(fullcode)) {
		return [[fullcode componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:NUMBER] invertedSet]] componentsJoinedByString:@""];
	}

	return @"";
}

/**
 *	@brief	按文件名获取文件路径
 *
 *	@param  fileName    文件名
 *
 *	@return	文件路径
 */
+ (NSString *)TTPathForDocumentsResource:(NSString *)fileName {
	static NSString *documentsPath = nil;

	if (nil == documentsPath) {
		NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentsPath = [[dirs firstObject] retain];
	}
	return [documentsPath stringByAppendingPathComponent:fileName];
}

/**
 *	@brief	按文件名获取文件路径(包含tjr的二级目录)
 *
 *	@param  fileName    文件名
 *
 *	@return	文件路径
 */
+ (NSString *)TTPathForDocumentsResourceEtag:(NSString *)fileName {
	static NSString *documentsPath = nil;

	if (nil == documentsPath) {
		NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentsPath = [[dirs firstObject] retain];
	}
	NSString *filePath = [[documentsPath stringByAppendingPathComponent:kDefaultCacheName] stringByAppendingPathComponent:fileName];
	return filePath;
}

/**
 *  按文件名获取项目的文件路径
 *
 *  @param relativePath 文件路径
 *
 *  @return 整个文件路径
 */
+ (NSString *)TTPathForBundleResource:(NSString* )relativePath{
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    return [resourcePath stringByAppendingPathComponent:relativePath];
}

#pragma mark - 设置tableview的分隔线(默认)
+ (void)setTableViewCellSeparatorLineDefaultWithCell:(UITableViewCell *)cell {
	[self setTableViewCellSeparatorLineWithCell:cell lineImageName:@"quotation_mystockview_cell_bg" imageType:@"png"];
}

#pragma mark - 设置tableview的分隔线
+ (void)setTableViewCellSeparatorLineWithCell:(UITableViewCell *)cell lineImageName:(NSString *)name imageType:(NSString *)type {
	if (!name || !TTIsStringWithAnyText(name) || !type || !TTIsStringWithAnyText(type)) {
		return;
	}

	NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
	UIImage *backgroundImage = [UIImage imageWithContentsOfFile:backgroundImagePath];

	if (backgroundImage) {
		backgroundImage = [self stretchableImageWithImage:backgroundImage edgeInsets:UIEdgeInsetsMake(1.0, 0, backgroundImage.size.height - 1.0, backgroundImage.size.width)];
	}

	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
	cell.backgroundView = backgroundView;
	cell.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	cell.backgroundView.frame = cell.bounds;
	[backgroundView release];
}

#pragma mark - cell的选择时的颜色
+ (void)cellSelectedColorWichCell:(UITableViewCell *)cell color:(UIColor *)color {
	if (!cell) return;

	UIView *view = [[UIView alloc] initWithFrame:cell.frame];

	view.backgroundColor = color;
	cell.selectedBackgroundView = view;
	RELEASE(view);
}

+ (NSString *)getRateImageName:(float)rate {
	BOOL isHD = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] > 1.5);

	if (rate >= 0) {
		return isHD ? @"arrow_up@2X" : @"arrow_up";
	} else {
		return isHD ? @"arrow_down@2X" : @"arrow_down";
	}
}

#pragma mark - 生成中文的拼音首字母(可以是多个中文,返回就是一串字母)
+ (NSString *)createNamePinYin:(NSString *)name {
	if (name == nil) {
		name = @"";
	}

	if (![name isEqualToString:@""]) {
		NSString *pinYinResult = [NSString string];

		for (int j = 0; j < name.length; j++) {	/* 生成名字拼音 */
			NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c", pinyinWithName([name characterAtIndex:j], j)] uppercaseString];
			pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
		}

		return pinYinResult;
	} else {
		return @"";
	}
}

#pragma mark - 将颜色生成为UIImage 
+ (UIImage *)createImageWithColor:(UIColor *)color {
	return [self createImageWithColor:color withSize:CGSizeMake(1, 1)];
}

#pragma mark - 将颜色生成为UIImage 输入生成Image的大小
+ (UIImage *)createImageWithColor:(UIColor *)color withSize:(CGSize)size {
	CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);

	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

#pragma mark - 将颜色生成为UIImage 做控件的背景之类的  直接控件大小
+ (UIImage *)createImageWithColor:(UIColor *)color withViewForSize:(UIView *)view {
	return [self createImageWithColor:color withSize:view.frame.size];
}

#pragma mark - 计算一段代码的运行时间
CGFloat BNRTimeBlock(void (^block)(void)) {
	mach_timebase_info_data_t info;

	if (mach_timebase_info(&info) != KERN_SUCCESS) {
		return -1.0;
	}

	uint64_t start = mach_absolute_time();
	block();
	uint64_t end = mach_absolute_time();
	uint64_t elapsed = end - start;

	uint64_t nanos = elapsed * info.numer / info.denom;
	return (CGFloat)nanos / NSEC_PER_SEC;
}

#pragma mark - 拉伸图片(ios7不能再用以前的了)
+ (UIImage *)stretchableImageWithName:(NSString *)imageName edgeInsets:(UIEdgeInsets)capInsets {
	if (!TTIsStringWithAnyText(imageName)) return nil;

	return [self stretchableImageWithImage:[UIImage imageNamed:imageName] edgeInsets:capInsets];
}

#pragma mark - 拉伸图片(ios7不能再用以前的了)
+ (UIImage *)stretchableImageWithImage:(UIImage *)image edgeInsets:(UIEdgeInsets)capInsets {
    return image ? [image resizableImageWithCapInsets:capInsets] : nil;
}


#pragma mark - 行情保留小数位数
+ (NSInteger)quotationKeepDecimalPlacesWithFullcode:(NSString *)fullcode {
	NSString *dm = [self getDMFromFullcode:fullcode];

	if (dm && (dm.length == 6)) {
		NSString *one = [dm substringToIndex:1];
		NSString *two = [dm substringToIndex:2];

		if ([@"9" isEqualToString:one] ||
			[@"51" isEqualToString:two] ||
			[@"15" isEqualToString:two]) {
			return 3;
		}
	}

	return 2;
}

#pragma mark - 创建Zip文件(删除本地源文件)

/**
 *    创建Zip文件(默认不删除本地源文件)
 *    @param zipName 要创建的Zip的名字
 *    @param fileArray  压缩文件的文件名列表(文件存在Documents)
 *    @returns 成功与否
 */
+ (BOOL)createZipWithZipName:(NSString *)zipName fileArray:(NSArray *)fileArray {
	return [self createZipWithZipName:zipName fileArray:fileArray deleteFile:NO];
}

/**
 *    创建Zip文件
 *    @param zipName 要创建的Zip的名字
 *    @param fileArray 压缩文件的文件名列表(文件存在Documents)
 *    @param isDelete  是否删除源文件
 *    @returns 成功与否
 */
+ (BOOL)createZipWithZipName:(NSString *)zipName fileArray:(NSArray *)fileArray deleteFile:(BOOL)isDeleteFile {
	if (!TTIsStringWithAnyText(zipName) || !fileArray || (fileArray.count == 0)) {
		return NO;
	}

	ZipArchive *zip = [[ZipArchive alloc] init];

	NSString *zipPath = [CommonUtil TTPathForDocumentsResourceEtag:zipName];
	BOOL bRet = [zip CreateZipFile2:zipPath];

	if (bRet) {
		for (NSString *fileName in fileArray) {
			if (TTIsStringWithAnyText(fileName)) {
				NSString *filePath = [CommonUtil TTPathForDocumentsResourceEtag:fileName];
				[zip addFileToZip:filePath newname:fileName];
			}
		}

		[zip CloseZipFile2];
		[zip release];

		if (isDeleteFile) {
			NSFileManager *fileMgr = [[NSFileManager alloc] init];
			NSError *error;

			for (NSString *fileName in fileArray) {
				if (TTIsStringWithAnyText(fileName)) {
					NSString *filePath = [NSHomeDirectory () stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", fileName]];

					if ([fileMgr removeItemAtPath:filePath error:&error] != YES) {
						NSLog(@"删除图片出错......");
					}
				}
			}

			RELEASE(fileMgr);
		}
		return YES;
	}

	[zip release];
	return NO;
}

#pragma mark - 创建Zip文件(是否删除源文件,自己设定文件压缩顺序)

/**
 *    创建Zip文件(默认不删除本地源文件)
 *    @param zipName 要创建的Zip的名字
 *    @param fileDic  压缩文件的文件名列表(文件存在Documents)---主要用来自己设定里面文件的压缩顺序,key为NSNumber从0开始
 *    @returns 成功与否
 */
+ (BOOL)createZipWithZipName:(NSString *)zipName fileDic:(NSDictionary *)fileDic {
	return [self createZipWithZipName:zipName fileDic:fileDic deleteFile:NO];
}

/**
 *   创建Zip文件
 *   @param zipName 要创建的Zip的名字
 *   @param fileDic 压缩文件的文件名列表(文件存在Documents)---主要用来自己设定里面文件的压缩顺序,key为NSNumber从0开始
 *   @param isDelete  是否删除源文件
 *   @returns 成功与否
 */
+ (BOOL)createZipWithZipName:(NSString *)zipName fileDic:(NSDictionary *)fileDic deleteFile:(BOOL)isDeleteFile {
	if (!TTIsStringWithAnyText(zipName) || !fileDic || (fileDic.count == 0)) return NO;

	ZipArchive *zip = [[ZipArchive alloc] init];
	NSString *zipPath = [CommonUtil TTPathForDocumentsResourceEtag:zipName];
	BOOL bRet = [zip CreateZipFile2:zipPath];

	if (bRet) {
		for (int i = 0; i < fileDic.count; i++) {
			NSString *fileName = [fileDic objectForKey:[NSNumber numberWithInt:i]];

			if (TTIsStringWithAnyText(fileName)) {
				NSString *filePath = [NSHomeDirectory () stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", fileName]];
				[zip addFileToZip:filePath newname:fileName];
			}
		}

		[zip CloseZipFile2];
		[zip release];

		if (isDeleteFile) {
			NSFileManager *fileMgr = [[NSFileManager alloc] init];
			NSError *error;

			for (NSString *fileName in fileDic.allValues) {
				if (TTIsStringWithAnyText(fileName)) {
					NSString *filePath = [NSHomeDirectory () stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", fileName]];

					if ([fileMgr removeItemAtPath:filePath error:&error] != YES) {
						NSLog(@"删除图片出错......");
					}
				}
			}

			RELEASE(fileMgr);
		}
		return YES;
	}

	[zip release];
	return NO;
}

#pragma mark - 解压文件

/**
 *    解压文件(没测试过)
 *    @param zipPath  压缩包路径
 *    @returns 解压成功与否
 */
+ (BOOL)unZipToFileWithZipPath:(NSString *)zipPath {
	if (!TTIsStringWithAnyText(zipPath)) {
		return NO;
	}

	ZipArchive *zip = [[ZipArchive alloc] init];

	NSString *sZipPath = [NSHomeDirectory () stringByAppendingPathComponent:zipPath];

	NSString *unZipTo = [NSHomeDirectory () stringByAppendingPathComponent:@"Documents"];

	if ([zip UnzipOpenFile:sZipPath]) {
		[zip UnzipFileTo:unZipTo overWrite:YES];

		[zip UnzipCloseFile];
		[zip release];
		return YES;
	}

	[zip release];
	return NO;
}

#pragma mark - 获取delegate的Isa,用于判断delegate是否release
+ (int)getDelegateIsa:(id)delegate {
	NSString *delegateDescription = [[delegate class] description];
	int classIsa = (int)objc_getClass([delegateDescription UTF8String]);

	return classIsa;
}

#pragma mark - 判断delegate是否没被释放
+ (BOOL)cheackDelegateIsNotRelease:(id)delegate oldClassIsa:(int)oldClassIsa {
	if (!delegate) return NO;

	int classIsa = (int)object_getClass(delegate);

	return classIsa * oldClassIsa != 0 && classIsa == oldClassIsa;
}

#pragma mark - 当前设备是否wifi或者grps
+ (NSString *)getNetWorkType {
	BOOL success;
	struct ifaddrs *addrs;
	const struct ifaddrs *cursor;

	NSString *name = nil;

	NSString *str = @"";

	success = getifaddrs(&addrs) == 0;

	if (success) {
		cursor = addrs;

		while (cursor != NULL) {
			name = [NSString stringWithFormat:@"%s", cursor->ifa_name];
			NSLog(@"ifa_name %s == %@n", cursor->ifa_name, name);

			// names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
			if (cursor->ifa_addr->sa_family == AF_LINK) {
				if ([name hasPrefix:@"en"]) {
					str = @"WIFI";
				}

				if ([name hasPrefix:@"pdp_ip"]) {
					str = @"3G/GPRS";
				}
			}
			cursor = cursor->ifa_next;
		}

		freeifaddrs(addrs);
	}
	return str;
}

#pragma mark - 判断手机是否越狱
+ (BOOL)isJailbroken {
	BOOL jailbroken = NO;
	NSString *cydiaPath = @"/Applications/Cydia.app";
	NSString *aptPath = @"/private/var/lib/apt/";

	if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
		jailbroken = YES;
	}

	if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
		jailbroken = YES;
	}
	return jailbroken;
}

#pragma mark - 判断目前设备是否ipad
+ (BOOL)isPadDevice {
	NSRange range = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	BOOL isPad = range.location != NSNotFound;

	return isPad;
}


#pragma mark - 获取Label粗体文本size
+ (CGSize)getPerfectSizeByBoldText:(NSString *)aText andFontSize:(CGFloat)aFontSize andWidth:(CGFloat)aWidth {
    CGSize constraint = CGSizeMake(aWidth, 20000.0f);
    CGSize size = [aText boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:aFontSize]} context:nil].size;
    return CGSizeMake(size.width, ceil(size.height));
}

#pragma mark - 获取label文本的宽度
+ (CGSize)getPerfectLabelTextWidth:(NSString *)aText andFontSize:(CGFloat)aFontSize andHeight:(CGFloat)aHeight
{
    CGSize constraint = CGSizeMake(20000.0f, aHeight);
    CGSize size = [aText boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:aFontSize]} context:nil].size;
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

#pragma mark - 获取Label文本size
+ (CGSize)getPerfectSizeByText:(NSString *)aText andFontSize:(CGFloat)aFontSize andWidth:(CGFloat)aWidth {
	CGSize constraint = CGSizeMake(aWidth, 20000.0f);
    CGSize size = [aText boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:aFontSize]} context:nil].size;
    
//    CGSize size = [aText boundingRectWithSize:constraint options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:aFontSize]} context:nil].size;
    
	return CGSizeMake(ceil(size.width), ceil(size.height));
}

/**
 *  字符串类型的十六进制颜色转换成UIColor
 *
 *  @param stringToConvert 十六进制颜色字符串
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    if (!TTIsStringWithAnyText(stringToConvert)) return [UIColor whiteColor];
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) return [UIColor whiteColor];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor whiteColor];
    
    NSRange range = NSMakeRange(0, 2);
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return RGBA(r, g, b, 1);
//    return [UIColor colorWithRed:((float) r / 255.0f)
//                           green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

#pragma mark - 将一个UIColor转换成16进制的字符串,格式#FFFFFF
+ (NSString *)hexFromUIColor:(UIColor *)color {
	if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
		const CGFloat *components = CGColorGetComponents(color.CGColor);
		color = [UIColor colorWithRed:components[0]
								green:components[0]
								 blue:components[0]
								alpha:components[1]];
	}

	if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
		return [NSString stringWithFormat:@"#FFFFFF"];
	}

	return [NSString stringWithFormat:@"#%X%X%X", (int)((CGColorGetComponents(color.CGColor))[0] * 255.0),
		(int)((CGColorGetComponents(color.CGColor))[1] * 255.0),
		(int)((CGColorGetComponents(color.CGColor))[2] * 255.0)];
}

#pragma mark - 将RGB颜色转换成16进制的字符串,格式#FFFFFF
+ (NSString *)hexFromR:(NSInteger)red G:(NSInteger)green B:(NSInteger)blue {
	red = MAX(0, red);
	red = MIN(255.0, red);
	green = MAX(0, green);
	green = MIN(255.0, green);
	blue = MAX(0, blue);
	blue = MIN(255.0, blue);
	return [NSString stringWithFormat:@"#%lX%lX%lX", (long)red, (long)green, (long)blue];
}

+ (void)setUITextFieldPlaceholderColor:(UITextField *)textField color:(UIColor *)color {
	if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
		textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@ {NSForegroundColorAttributeName:color}];
	} else {
		NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
	}
}

#pragma mark - 产生随机 kNumber 位字符串
+ (NSString *)getRandomDefault:(int)kNumber
{
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[[NSMutableString alloc] init] autorelease];
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

/**
 *   返回MD5加密后的字符串
 *   @param code 原始密码
 *   @returns 加密后的密码
 */
+ (NSString *)getMD5:(NSString *)code {
	if (code.length > 0) {
		NSString *password = [NSString stringWithString:code];
		Encryption *encryption = [[Encryption alloc] init];
		password = [encryption toMd5Str:password];
		TT_RELEASE_SAFELY(encryption);
		return password;
	}
	NSAssert(code.length <= 0, @"加密的字符为空"); 
	return @"";
}


/**
 *  截取html中<img src ="" />的字符数组
 *
 *  @param sHtmlText html字符
 *
 *  @return 包含<img src ="" />字符数组
 */
+ (NSMutableArray *)getHtmlImgTagList:(NSString *)sHtmlText {
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];

	if (!TTIsStringWithAnyText(sHtmlText)) return array;

	NSString *format = @"(<img.*?src=[\'\"](.*?)[\'\"].*?>)";	// 截取html中<img src ="" />的字符数组

	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:format options:NSRegularExpressionCaseInsensitive error:nil];

	NSArray *arr = [regex matchesInString:sHtmlText options:0 range:NSMakeRange(0, [sHtmlText length])];

	for (NSTextCheckingResult *b in arr) {
		NSString *str = [sHtmlText substringWithRange:b.range];	// 是每个和表达式匹配好的字符串。
		[array addObject:str];
	}

	return array;
}

/**
 *  获取<img src ="" />中src属性
 *
 *  @param sHtmlText html字符
 *
 *  @return src的字符数组
 */
+ (NSMutableArray *)getHtmlImgSrcList:(NSString *)sHtmlText {
	NSMutableArray *TagArr = [CommonUtil getHtmlImgTagList:sHtmlText];

	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];

	for (NSString *tagStr in TagArr) {
		NSString *urlFormat = @"(?<=src=[\'\"])[^\'\"]+";	// 获取<img src ="" />中src属性
		NSRegularExpression *utlRegex = [NSRegularExpression regularExpressionWithPattern:urlFormat options:NSRegularExpressionCaseInsensitive error:nil];

		NSTextCheckingResult *b = [[utlRegex matchesInString:tagStr options:0 range:NSMakeRange(0, [tagStr length])] firstObject];
		NSString *strUrl = [tagStr substringWithRange:b.range];
		[array addObject:strUrl];
	}

	return array;
}

/**
 *  获取<img src ="" width ="" height =""/>中width,height属性
 *
 *  @param imgTag img标签
 *
 *  @return x=0,y=0 的 CGRect (0,0,width,height)
 */
+ (CGRect)getImgWidthHeightValue:(NSString *)imgTag {
	__block float width = 0;
	__block float height = 0;

	/*获取<img src ="" width ="" height =""/>中height属性*/
	NSRegularExpression *heightRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=height=[\'\"])[^\'\"]+" options:0 error:NULL] autorelease];

	[heightRegex enumerateMatchesInString:imgTag options:0 range:NSMakeRange(0, [imgTag length]) usingBlock:^(NSTextCheckingResult * match, NSMatchingFlags flags, BOOL * stop) {
			height = [[imgTag substringWithRange:match.range] floatValue];
		}];

	/*获取<img src ="" width ="" height =""/>中width属性*/
	NSRegularExpression *widthRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=width=[\'\"])[^\'\"]+" options:0 error:NULL] autorelease];

	[widthRegex enumerateMatchesInString:imgTag options:0 range:NSMakeRange (0, [imgTag length]) usingBlock:^(NSTextCheckingResult * match, NSMatchingFlags flags, BOOL * stop) {
			width = [[imgTag substringWithRange:match.range] floatValue];
		}];
	return CGRectMake (0, 0, width, height);
}

/**
 *    按钮单击时的稍微放大动画效果
 *    @param sender  要设置动画的按钮
 */
+ (void)buttonOnClickAnimation:(UIView *)sender {
	if (!sender) return;

	CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	theAnimation.duration = 0.05;
	theAnimation.repeatCount = 1;	// HUGE_VALF;
	theAnimation.autoreverses = YES;
	theAnimation.fromValue = [NSNumber numberWithFloat:1.0];
	theAnimation.toValue = [NSNumber numberWithFloat:1.5];
	[sender.layer addAnimation:theAnimation forKey:@"scale-layer"];
}

/**
 *    设置View的圆角
 *    @param view 要设置圆角的view
 *    @param radius 圆角半径
 *    @param borderColor  描边颜色,没有就不描边
 */
+ (void)viewMasksToBounds:(UIView *)view cornerRadius:(CGFloat)radius borderColor:(UIColor *)borderColor {
    [CommonUtil viewMasksToBounds:view cornerRadius:radius borderColor:borderColor borderWidth:0.5f];
}

/**
 *  设置View的圆角
 *
 *  @param view        要设置圆角的view
 *  @param radius      圆角半径
 *  @param borderColor 描边颜色,没有就不描边
 *  @param borderWidth 描边线宽度
 */
+ (void)viewMasksToBounds:(UIView *)view cornerRadius:(CGFloat)radius borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
	if (!view) return;

	view.layer.borderColor = borderColor ?[borderColor CGColor] : UIColor.clearColor.CGColor;
	view.layer.borderWidth = borderWidth;
	view.layer.cornerRadius = radius;
	view.layer.masksToBounds = YES;
}

#pragma mark - 传入UICollectionViewCell包含的某个控件，返回该控件的UICollectionViewCell

/**
 *  传入CollectionViewCell包含的某个控件，返回该控件的CollectionViewCell
 *  @param containView
 *  @return cell
 */
+ (UICollectionViewCell *)getCollectionViewCellWithContainView:(UIView *)containView {
    UICollectionViewCell *cell = nil;
    UIView *superView = containView;
    
    while (![superView isKindOfClass:[UICollectionViewCell class]]) {
        superView = superView.superview;
        
        if ([superView isKindOfClass:[UIWindow class]]) {
            return nil;
        }
    }
    
    cell = (UICollectionViewCell *)superView;
    
    return cell;
}


#pragma mark - 传入TableViewCell包含的某个控件，返回该控件的TableViewCell

/**
 *  传入TableViewCell包含的某个控件，返回该控件的TableViewCell
 *  @param containView
 *  @return cell
 */
+ (UITableViewCell *)getTableViewCellWithContainView:(UIView *)containView {
	UITableViewCell *cell = nil;
	UIView *superView = containView;

	while (![superView isKindOfClass:[UITableViewCell class]]) {
		superView = superView.superview;

		if ([superView isKindOfClass:[UIWindow class]]) {
			return nil;
		}
	}

	cell = (UITableViewCell *)superView;

	return cell;
}


#pragma mark - 传入TableViewCell，返回该TableView
+ (UITableView *)getTableViewWithTableViewCell:(UITableViewCell *)cell
{
    if(cell == nil)
        return nil;
    UIView *superView = cell;
    while (![superView isKindOfClass:[UITableView class]]) {
        superView = superView.superview;
        
        if ([superView isKindOfClass:[UIWindow class]]) {
            return nil;
        }
    }
    UITableView *tableView = (UITableView *)superView;
    return tableView;
    
}

/**
 *  传入TableViewCell包含的某个控件，返回该控件所在的NSIndexPath
 *  @param containView
 *  @param tableView
 *  @return cell
 */
+ (NSIndexPath *)getIndexPathWithView:(UIView *)view tableView:(UITableView *)tableView {
    if (!view || !tableView) return nil;
    UITableViewCell *cell = [CommonUtil getTableViewCellWithContainView:view];
    if (cell) {
        return [tableView indexPathForCell:cell];
    }
    return nil;
}

/**
 *    得到中英文混合字符串以中文来算的长度
 *    @param strtemp 目标文字串
 *    @returns 中文长度
 */
+ (NSUInteger)getChineseLength:(NSString *)strtemp {
	NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
	NSData *da = [strtemp dataUsingEncoding:enc];

	return ceilf([da length] / 2.0f);
}

/**
 *    获取字符串的字节长度
 *    @param text 字符串
 *    @returns 字节长度
 */
+ (int)getStringByteNum:(NSString *)text{
    int strlength = 0;
    char* p = (char*)[text cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[text lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

/**
 *   从字符串中截取指定字节数
 *    @param string 原始字符串
 *    @param index 字节数
 *    @returns 截取后的字符串
 */
+ (NSString *)subStringByByteWithString:(NSString *)string  WithIndex:(NSInteger)index{
    
    NSInteger sum = 0;
    
    NSString *subStr = @"";
    
    for(int i = 0; i<[string length]; i++){
        
        unichar strChar = [string characterAtIndex:i];
        
        if(strChar < 256){
            sum += 1;
        }
        else {
            sum += 2;
        }
        
        if (sum >= index) {
            
            subStr = [string substringToIndex:i+1];
            return subStr;
        }
    }
    return string;
}

/**
 *    autoLayout情况下,设置一个View的高度,如果View没有高度这个约束,就代码加上
 *    @param view 目标View
 *    @param height 目标高度
 *    @returns 中文长度
 */
+ (void)viewHeightForAutoLayout:(UIView *)view height:(CGFloat)height {
    NSParameterAssert(!view.translatesAutoresizingMaskIntoConstraints);
    for (NSLayoutConstraint *l in view.constraints) {
        if (l.firstAttribute == NSLayoutAttributeHeight) {
            l.constant = height;
            return;
        }
    }
    NSLayoutConstraint *l = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1 constant:height];
    [view addConstraint:l];
}

/**
 *    autoLayout情况下,设置一个View的宽度,如果View没有宽度这个约束,就代码加上
 *    @param view 目标View
 *    @param width 目标宽度
 *    @returns 中文长度
 */
+ (void)viewWidthForAutoLayout:(UIView *)view width:(CGFloat)width {
    NSParameterAssert(!view.translatesAutoresizingMaskIntoConstraints);
    for (NSLayoutConstraint *l in view.constraints) {
        if (l.firstAttribute == NSLayoutAttributeWidth) {
            l.constant = width;
            return;
        }
    }
    NSLayoutConstraint *l = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1 constant:width];
    [view addConstraint:l];
}


/**
	跳转到后台管理程序
	@param userId  广告号用户的ID
 */
+ (void)openTJRManageWithUserId:(NSString *)userId {
    if (TTIsStringWithAnyText(userId)) {
        NSString *urlString = [NSString stringWithFormat:@"TJRManager://UserId=%@", userId];
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

/**
 *  只在debug模式下执行的代码
 *
 *  @param debugSome
 */
+ (void)doSomeOnlyDebug:(void (^)(void))debugSome {
    [CommonUtil doSomeForDebug:debugSome else:nil];
}

/**
 *  宏定义Debug下执行和发布模式下执行
 *  (不用每次都拷贝if)
 *
 *  @param debugSome debug模式下执行的代码
 *  @param elseSome  发布模式下执行的代码
 */
+ (void)doSomeForDebug:(void (^)(void))debugSome else:(void (^)(void))elseSome {
#ifdef DEBUG
    if (debugSome) debugSome();
#else
    if (elseSome) elseSome();
#endif
}

/**
 *  把文本通过64位RSA加密。
 *
 *  @param str 明文
 *  @return sign  密文
 */
+ (NSString*)getRSA64SignString:(NSString *)str{
    RSA *rsa = [[RSA alloc] initWithKeyFile:@"ios_rsa_beebar_public_key"];
    NSString* sign = [NSString stringWithFormat:@"%@",[[rsa encryptWithString:str] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
    [rsa release];
    return sign;
}

/**
 *  生成X位随机码。
 *
 *  @param lenght 长度
 *  @return str  随机码
 */
+ (NSString *)generateRandomCode:(int)length {
    
    NSString *sourceStr = @"abcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    
    srand((unsigned int)time(0));
    for (int i = 0; i < length; i++) {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

/**
 *  通过View获取View所在的ViewController
 *
 *  @param containView
 *
 *  @return
 */
+ (TJRBaseViewController *)getControllerWithContainView:(UIView *)containView {
    TJRBaseViewController *ctr= nil;
    UIResponder *responder = containView.nextResponder;
    
    while (![responder isKindOfClass:[TJRBaseViewController class]]) {
        responder = responder.nextResponder;
        if([responder isKindOfClass:[UIWindow class]]){
            return nil;
        }
    }
    ctr = (TJRBaseViewController *)responder;
    
    return ctr;
}

#pragma mark - 设置本地通知
/**
 *  设置本地通知
 *
 *  @param alertTime   延迟执行时间
 *  @param alertBody   通知内容
 *  @param badgeNumber 消息提示数
 *  @param userInfo    通知参数
 */
+ (void)registerLocalNotification:(CGFloat)alertTime alertBody:(NSString *)alertBody badgeNumber:(NSUInteger) badgeNumber userInfo:(NSDictionary *)userInfo {
    //当应用不是处于后台时,不推送本地通知
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) return;
    
    if (CURRENT_DEVICE_VERSION>=10) {
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
        
        //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
        UNMutableNotificationContent* content = [[[UNMutableNotificationContent alloc] init] autorelease];
        content.body = [NSString localizedUserNotificationStringForKey:alertBody arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.badge = [NSNumber numberWithUnsignedInteger:badgeNumber];
        if (userInfo) content.userInfo = userInfo;// 通知参数
        
        // 在 alertTime 后推送本地推送;
        UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alertTime repeats:NO];
        UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"LocalNotification" content:content trigger:trigger];
        
        //添加推送成功后的处理！
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            
        }];

    }else{
        
        UILocalNotification *notification = [[[UILocalNotification alloc] init] autorelease];
        // 设置触发通知的时间
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:alertTime];
        
        notification.fireDate = fireDate;
        notification.timeZone = [NSTimeZone defaultTimeZone];// 时区
        notification.repeatInterval = kCFCalendarUnitSecond;// 设置重复的间隔
        
        notification.alertBody =  alertBody;// 通知内容
        notification.applicationIconBadgeNumber = badgeNumber;//消息提示数
        notification.soundName = UILocalNotificationDefaultSoundName;// 通知被触发时播放的声音
        if (userInfo) notification.userInfo = userInfo;// 通知参数
        
        // ios8后，需要添加这个注册，才能得到授权
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            // 通知重复提示的单位，可以是天、周、月
            notification.repeatInterval = NSCalendarUnitDay;
        } else {
            // 通知重复提示的单位，可以是天、周、月
            notification.repeatInterval = NSCalendarUnitDay;
        }
        
        // 执行通知注册
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
}

#pragma mark - 取消某个本地推送通知(IOS8)
/**
 *  取消本地推送通知
 *
 *  @param key 本地推送通知的Key
 */
+ (void)cancelLocalNotificationWithKey:(NSString *)key {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            NSString *info = userInfo[key];// 根据设置通知参数时指定的key来获取通知参数
            if (info != nil) {// 如果找到需要取消的通知，则取消
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}

#pragma mark - 设置本机的推送声音跟振动
/**
 *  设置本机的推送声音跟振动
 *
 *  @param noice 是否有声音
 *  @param vibration 是否有振动
 */
+ (void)callNotificationWithNoice:(BOOL)noice vibration:(BOOL)vibration{
    
    if (noice) {
        //声音
        NSError* error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (error != nil) {
            SystemSoundID myAlertSound;
            NSURL *url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/sms-received1.caf"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &myAlertSound);
            AudioServicesPlaySystemSound(myAlertSound);
        }else{
            AudioServicesPlaySystemSound(1012);
        }
    }
    
    if (vibration) {
        AudioServicesPlaySystemSound(4095);//震动
    }
}

#pragma mark - 设置隐藏UITableView多余cell的分割线
+ (void)setExtraCellLineHidden:(UITableView *)tView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tView setTableFooterView:view];
    [view release];
}

#pragma mark - 页面过度效果（淡出）
+ (void)setPageToAnimation{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    transition.fillMode = kCAFillModeForwards;
    transition.type = kCATransitionFade; //过度效果
    transition.removedOnCompletion = YES;
    [ROOTCONTROLLER.navigationController.view.layer addAnimation:transition forKey:@"animation"];
}

#pragma mark - 页面过度效果（从下往上弹出）
+ (void)setPushToAnimation{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.subtype = kCATransitionFromTop; //转场动画将去的方向
    transition.type = kCATransitionMoveIn; //过度效果(新视图移动到旧视图上)
    transition.removedOnCompletion = YES;
    [ROOTCONTROLLER.navigationController.view.layer addAnimation:transition forKey:@"animation"];
}

#pragma mark - 页面过度效果（从上往下pop）
+ (void)setPopToAnimation {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.subtype = kCATransitionFromBottom; //转场动画将去的方向
    transition.type = kCATransitionPush; //过度效果
    transition.removedOnCompletion = YES;
    [ROOTCONTROLLER.navigationController.view.layer addAnimation:transition forKey:@"animation"];
}

#pragma mark - 设置主页的TabBar位置
+ (void)setHomeViewTabBarIndex:(NSInteger)index{
    
    for (id object in [ROOTCONTROLLER.navigationController.viewControllers objectEnumerator]) {
        if ([object isKindOfClass:[HomeViewController class]]) {
            HomeViewController* ctr = ((HomeViewController *)object);
            [ctr setSelectedIndex:index];
            break;
        }
    }
}

#pragma mark - 获取主页的TabBar位置
+ (NSUInteger)getHomeViewTabBarIndex{
    
    NSUInteger index = -1;
    for (id object in [ROOTCONTROLLER.navigationController.viewControllers objectEnumerator]) {
        if ([object isKindOfClass:[HomeViewController class]]) {
            HomeViewController* ctr = ((HomeViewController *)object);
            index = ctr.selectedIndex;
            break;
        }
    }
    return index;
}

#pragma mark - 判断当前是否有录音权限
+ (BOOL)canRecord {
    __block BOOL bCanRecord = YES;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_x_Max) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    return bCanRecord;
}

#pragma mark - 判断网络连接状态
+ (BOOL)networkingStatesFromStatebarIsWifi {
    // 状态栏是由当前app控制的，首先获取当前app
    UIApplication *app = [UIApplication sharedApplication];
    
    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    
    int type = 0;
    
    for (id child in children) {
        if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
        }
    }
    BOOL isWifi = NO;
    
    switch (type) {
        case 5:
            isWifi = YES;
            break;
            
        default:
            isWifi = NO;
            break;
    }
    
    return isWifi;
}
/**
 *  @brief  将一个浮点数保留两位小数
 *
 *  @param value  目标小数
 *
 *  @return 最终结果
 */
+ (NSString *)retainTwoDecimalPointOfAFloatVale:(CGFloat)value {
    return [CommonUtil newFloat:value withNumber:2 isAddSign:false];
}

#pragma mark - 通过变量来控制数值保留的小数点位数
/**
 *  @brief  通过变量来控制数值保留的小数点位数
 *          以往用@"%.2f"来指定保留2位小数位，现在可通过一个变量来控制保留的位数
 *
 *  @param value          目标小数
 *  @param numberOfPlace  小数位数
 *
 *  @return 最终结果
 */ 
+ (NSString *)newFloat:(CGFloat)value withNumber:(NSUInteger)numberOfPlace {
    return [CommonUtil newFloat:value withNumber:numberOfPlace isAddSign:false];
}

/**
 *  @brief  通过变量来控制数值保留的小数点位数
 *          以往用@"%.2f"来指定保留2位小数位，现在可通过一个变量来控制保留的位数
 *
 *  @param value          目标小数
 *  @param numberOfPlace  小数位数
 *  @param isAddSign      是否添加正负号(当为正时,添加＂+＂号)
 *
 *  @return 最终结果
 */ 
+ (NSString *)newFloat:(CGFloat)value withNumber:(NSUInteger)numberOfPlace isAddSign:(BOOL)isAddSign {
    NSString *format = nil;
    if (isAddSign && value >= 0) {
        format = [NSString stringWithFormat:@"+%%.%@f",@(numberOfPlace)];
    } else {
        format = [NSString stringWithFormat:@"%%.%@f",@(numberOfPlace)];
    }
    return [NSString stringWithFormat:format,value];
}

/**
 *  付款金额限制代码
 *
 *  @param textField    当前textField
 *  @param range        range
 *  @param string       string
 *  @param dotPreBits   小数点前整数位数
 *  @param dotAfterBits 小数点后位数
 *
 *  @return shouldChangeCharactersInRange 代理方法中 可以限制金额格式
 */
+ (BOOL)limitPayMoneyDot:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string dotPreBits:(int)dotPreBits dotAfterBits:(NSInteger)dotAfterBits {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""]) {    //按下return
        return YES;
    }
    NSInteger nDotLoc = [textField.text rangeOfString:@"."].location;
    if([textField.text hasPrefix:@"0"] && ![string isEqualToString:@"."] && nDotLoc == NSNotFound){
        textField.text = string;
        return false;
    }
    
    
    if ([string hasPrefix:@"0"]) {
        if (range.location == 0 && nDotLoc != 0 && TTIsStringWithAnyText(textField.text)) {
            return false;
        } else if ([textField.text hasPrefix:@"0"] && nDotLoc == NSNotFound) {
            return false;
        }
    } else if ([textField.text hasPrefix:@"0"] && range.location ==1) {
        return [string isEqualToString:@"."];
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]invertedSet];;
    if ((NSNotFound == nDotLoc) && (0 != range.location)) {
        if ([string isEqualToString:@"."]) {
            return YES;
        }
        if (textField.text.length >= dotPreBits) {    // 小数点前面6位
            return NO;
        }
    } else {
        if (textField.text.length >= dotPreBits + dotAfterBits + 1) {
            return NO;
        }
    }
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [string isEqualToString:filtered];
    if (!basicTest) return NO;
    if ((NSNotFound != nDotLoc) && (range.location > nDotLoc)) {// 小数点后面n位
        NSArray *ary =  [textField.text componentsSeparatedByString:@"."];
        if (ary.count == 2) {
            if ([ary[1] length] >= dotAfterBits) {
                return NO;
            }
        }
        return true;
    }
    return YES;
}

#pragma mark - 身份证号码验证
+ (BOOL)judgeIdentityStringValid:(NSString *)identityString
{
    
    if (identityString.length != 18) return NO;
    // 正则表达式判断基本 身份证号是否满足格式
    NSString *regex = @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X)$";
    //  NSString *regex = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
    NSPredicate *identityStringPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    //如果通过该验证，说明身份证格式正确，但准确性还需计算
    if(![identityStringPredicate evaluateWithObject:identityString]) return NO;
    
    //** 开始进行校验 *//
    
    //将前17位加权因子保存在数组里
    NSArray *idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
    
    //这是除以11后，可能产生的11位余数、验证码，也保存成数组
    NSArray *idCardYArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
    
    //用来保存前17位各自乖以加权因子后的总和
    NSInteger idCardWiSum = 0;
    for(int i = 0;i < 17;i++) {
        NSInteger subStrIndex = [[identityString substringWithRange:NSMakeRange(i, 1)] integerValue];
        NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
        idCardWiSum+= subStrIndex * idCardWiIndex;
    }
    
    //计算出校验码所在数组的位置
    NSInteger idCardMod=idCardWiSum%11;
    //得到最后一位身份证号码
    NSString *idCardLast= [identityString substringWithRange:NSMakeRange(17, 1)];
    //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
    if(idCardMod==2) {
        if(![idCardLast isEqualToString:@"X"]||[idCardLast isEqualToString:@"x"]) {
            return NO;
        }
    }
    else{
        //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
        if(![idCardLast isEqualToString: [idCardYArray objectAtIndex:idCardMod]]) {
            return NO;
        }
    }
    return YES;
}


/**
 *  @brief  输入金额大写
 *
 *  @param money
 *
 *  @return
 */ 
+ (NSString *)toCapitalLetters:(NSString *)money {
    // 首先转化成标准格式 200.23
    NSMutableString *tempStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%.2f", [money doubleValue]]];
    // 位
    NSArray *carryArr1 = @[@"元", @"拾", @"佰", @"仟", @"万", @"拾", @"佰", @"仟", @"亿", @"拾", @"佰", @"仟", @"兆", @"拾", @"佰", @"仟"];
    NSArray *carryArr2 = @[@"分", @"角"];
    // 数字
    NSArray *numArr = @[@"零", @"壹", @"贰", @"叁", @"肆", @"伍", @"陆", @"柒", @"捌", @"玖"];
    NSArray *temarr = [tempStr componentsSeparatedByString:@"."];
    // 小数点前的数值字符串
    NSString *firstStr = [NSString stringWithFormat:@"%@", temarr[0]];
    // 小数点后的数值字符串
    NSString *secondStr = [NSString stringWithFormat:@"%@", temarr[1]];
    // 是否拼接了“零”，做标记
    bool zero = NO;
    // 拼接数据的可变字符串
    NSMutableString *endStr = [[NSMutableString alloc] init];
    for (int i = (int)firstStr.length; i > 0; i--) {// 首先遍历firstStr，从最高位往个位遍历    高位----->个位
        NSInteger MyData = [[firstStr substringWithRange:NSMakeRange(firstStr.length - i, 1)] integerValue];// 取最高位数
        if ([numArr[MyData] isEqualToString:@"零"]) {
            if ([carryArr1[i - 1] isEqualToString:@"万"] || [carryArr1[i - 1] isEqualToString:@"亿"] || [carryArr1[i - 1] isEqualToString:@"元"] || [carryArr1[i - 1] isEqualToString:@"兆"]) {
                // 去除有“零万”
                if (zero) {
                    endStr = [NSMutableString stringWithFormat:@"%@", [endStr substringToIndex:(endStr.length - 1)]];
                    [endStr appendString:carryArr1[i - 1]];
                    zero = NO;
                } else {
                    if (endStr.length == 0) [endStr appendString:numArr[MyData]];
                    [endStr appendString:carryArr1[i - 1]];
                    zero = NO;
                }
                
                // 去除有“亿万”、"兆万"的情况
                if ([carryArr1[i - 1] isEqualToString:@"万"]) {
                    if ([[endStr substringWithRange:NSMakeRange(endStr.length - 2, 1)] isEqualToString:@"亿"]) {
                        endStr = [NSMutableString stringWithFormat:@"%@", [endStr substringToIndex:endStr.length - 1]];
                    }
                    
                    if ([[endStr substringWithRange:NSMakeRange(endStr.length - 2, 1)] isEqualToString:@"兆"]) {
                        endStr = [NSMutableString stringWithFormat:@"%@", [endStr substringToIndex:endStr.length - 1]];
                    }
                }
                // 去除“兆亿”
                if ([carryArr1[i - 1] isEqualToString:@"亿"]) {
                    if ([[endStr substringWithRange:NSMakeRange(endStr.length - 2, 1)] isEqualToString:@"兆"]) {
                        endStr = [NSMutableString stringWithFormat:@"%@", [endStr substringToIndex:endStr.length - 1]];
                    }
                }
            } else {
                if (!zero) {
                    [endStr appendString:numArr[MyData]];
                    zero = YES;
                }
            }
        } else {
            // 拼接数字
            [endStr appendString:numArr[MyData]];
            // 拼接位
            [endStr appendString:carryArr1[i - 1]];
            //不为“零”
            zero = NO;
        }
    }
    
    if ([secondStr isEqualToString:@"00"]) {//再遍历secondStr    角位----->分位
        [endStr appendString:@"整"];
    } else {
        for (int i = (int)secondStr.length; i > 0; i--) {
            // 取最高位数
            NSInteger MyData = [[secondStr substringWithRange:NSMakeRange(secondStr.length - i, 1)] integerValue];
            [endStr appendString:numArr[MyData]];
            [endStr appendString:carryArr2[i - 1]];
        }
    }
    return endStr;
}

/**
 *  @brief  输入数字，1万以上转化成w，1w以下显示完整数字
 *
 *  @return
 */
+ (NSString *)translateIntoTenThousand:(NSInteger)num {

    NSString *str = nil;
    if (num < 10000) {
        str = [NSString stringWithFormat:@"%ld",num];
    }else {
        str =  [NSString stringWithFormat:@"%.2fw",num/10000.0];
    }
    return str;
}


/*** 检查邮箱 */
+ (BOOL)checkEmail:(NSString *)emailStr {
    return [emailStr containsString:@"@"];
}

/*** 隐藏邮箱 */
+ (NSString *)hidenEmailStr:(NSString *)emailStr {
    NSArray *subArr = [emailStr componentsSeparatedByString:@"@"];
    NSString *begin = [subArr.firstObject substringToIndex:2];
    NSString *email = [NSString stringWithFormat:@"%@****@%@", begin, subArr.lastObject];
    return email;
}

/*** 隐藏手机号码 */
+ (NSString *)hidenPhoneStr:(NSString *)phoneStr {
    NSString *begin = [phoneStr substringToIndex:3];
    NSString *end = [phoneStr substringWithRange:(NSMakeRange(phoneStr.length-4, 4))];
    NSString *phone = [NSString stringWithFormat:@"%@****%@", begin, end];
    return phone;
}


@end

