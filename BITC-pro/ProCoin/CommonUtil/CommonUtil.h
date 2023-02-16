//
//  CommonUtil.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-27.
//  Copyright (c) 2012年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@class TJRBaseViewController;

//获取状态栏、标题栏、导航栏高度

#define  MoneyMaxIntegerCount      7                       //最大整数位数

#define QuotationRedColor               RGBA(217, 38, 0, 1)                  //代表上涨颜色，不一定是红色
#define QuotationGreenColor             RGBA(0, 173, 136, 1)                 //代表下跌颜色，不一定是绿色
#define QuotationBlueColor              RGBA(0, 161, 242, 1)
#define QuotationYellowColor            RGBA(255, 196, 62, 1)
#define QuotationPurpleColor            RGBA(176, 128, 206, 1)
#define QuotationWhiteColor             RGBA(166, 166, 166, 1)
#define QuotationBlackColor             [UIColor blackColor]
#define QuotationGrayColor              RGBA(166, 166, 166, 1)
#define QuotationNewGray                RGBA(85, 85, 85, 1)

@interface CommonUtil : NSObject

#pragma mark - 把字符串json格式化NSDictionary
+ (id)jsonValue:(NSString *)json;

#pragma mark - 把NSDictionary 或 NSArray 转换成Json
+ (NSString *)jsonToString:(id)jsonDic;

#pragma mark - 格式化数据,保留两位小数(字符串型的)
+ (NSString *)formatNumberForString:(NSString *)value;

#pragma mark - 获取涨幅颜色(涨红,跌绿,0白)
+ (UIColor *)getRateColor:(float)rate;

#pragma mark - 获取颜色(正红,负绿,0白)
+ (UIColor *)getDataColorWithTodayOpen:(double)open Yesterday:(double)yesterday;

#pragma mark - 获取颜色(正红,负绿,0白)
+ (UIColor *)getDataColor:(float)data;

#pragma mark - 获取颜色(正红,负绿,0自定义)
+ (UIColor *)getDataColor:(float)data withZeroColor:(UIColor *)color;

#pragma mark - 获取涨幅颜色(涨红,跌绿,0白)  涨幅为字符串型
+ (UIColor *)getRateColorForString:(NSString *)rateString;

#pragma mark - 获取涨幅颜色(通过今日开盘和昨日收盘)
+ (UIColor *)getRateColorWithTodayOpen:(double)open Yesterday:(double)yesterday;

#pragma mark - 获取涨幅颜色(涨红,跌绿,0白)获取涨幅颜色,自带为0的颜色 (涨红,跌绿)
+ (UIColor *)getRateColor:(float)rate withZeroColor:(UIColor *)zeroColor;

#pragma mark - 获取涨幅颜色(涨红,跌绿,0白)获取涨幅颜色,自带为0的颜色 (涨红,跌绿)
+ (UIColor *)getRateColor:(float)rate minimum:(CGFloat)minimum withZeroColor:(UIColor *)zeroColor;

#pragma mark - 获取涨幅颜色(涨红,跌绿,0白)获取涨幅颜色,自带为0的颜色 (涨红,跌绿)  涨幅为字符串型
+ (UIColor *)getRateColorForString:(NSString *)rateString withZeroColor:(UIColor *)zeroColor;

#pragma mark - 获取买卖性质颜色(S为绿,B为红,其他为白)
+ (UIColor *)getNatureColor:(NSString *)nature;

#pragma mark - 我的自选股视图里列表右边的涨跌颜色图片
+ (NSString *)getMyStockRateImageName:(float)rate;

#pragma mark - 格式化成交量
+ (NSString *)formatVolume:(long long)volume;

#pragma mark - 格式化数据(长整型)
+ (NSString *)formatDateForLong:(NSUInteger)assets;

#pragma mark - 格式化数据(double型)
+ (NSString *)formatDateForDouble:(double)assets;

#pragma mark - 格式化数据(double型)不保留小数
+ (NSString *)formatDateForDoubleNoMedian:(double)assets;

#pragma mark - 格式化数据,显示加减符号
+ (NSString *)formatDataForStringComplete:(float)assets format:(NSString*)format;

#pragma mark - 格式化数据(字符串)
+ (NSString *)formatDataForString:(NSString *)assets;

#pragma mark - 格式化整形(超过一千用K显示)
+ (NSString *)formatIntegerWithK:(NSInteger)number;

#pragma mark - 计算纵坐标
+ (double)getCharPixelY:(double)max spanY:(double)spanY value:(double)value;

#pragma mark - 计算纵坐标(值可以为负)
+ (float)getCharPixelYCanNegative:(float)max spanY:(float)spanY value:(float)value;

#pragma mark - 计算成交量纵坐标
+ (float)getVolumeY:(float)max spanY:(float)spanY value:(long long)value;

#pragma mark - 以正则表达式判断字符串是否符合
+ (BOOL)isMatched:(NSString *)value byRegex:(NSString *)regex;

#pragma mark - tableView cell 的背景图
+ (void)setCellBackground:(UITableViewCell *)cell;

#pragma mark - tableView cell 的背景图 ,imageName:图片路径
+ (void)setCellBackground:(UITableViewCell *)cell imageName:(NSString *)imageName;

#pragma 从fullcode里截取到dm
+ (NSString *)getDMFromFullcode:(NSString *)fullcode;

#pragma 按文件名获取文件路径
+ (NSString *)TTPathForDocumentsResource:(NSString *)fileName;
+ (NSString *)TTPathForDocumentsResourceEtag:(NSString *)fileName;

#pragma 按文件名获取项目的文件路径
+ (NSString *)TTPathForBundleResource:(NSString* )relativePath;

#pragma mark - 设置tableview的分隔线(默认)
+ (void)setTableViewCellSeparatorLineDefaultWithCell:(UITableViewCell *)cell;

#pragma mark - 设置tableview的分隔线
+ (void)setTableViewCellSeparatorLineWithCell:(UITableViewCell *)cell lineImageName:(NSString *)name imageType:(NSString *)type;

#pragma mark - cell的选择时的颜色
+ (void)cellSelectedColorWichCell:(UITableViewCell *)cell color:(UIColor *)color;

+ (NSString *)getRateImageName:(float)rate;

#pragma mark - 生成中文的拼音首字母(可以是多个中文,返回就是一串字母)
+ (NSString *)createNamePinYin:(NSString *)name;

#pragma mark - 将颜色生成为UIImage
+ (UIImage *)createImageWithColor:(UIColor *)color;

#pragma mark - 将颜色生成为UIImage
+ (UIImage *)createImageWithColor:(UIColor *)color withSize:(CGSize)size;

#pragma mark - 将颜色生成为UIImage 做控件的背景之类的  直接控件大小
+ (UIImage *)createImageWithColor:(UIColor *)color withViewForSize:(UIView *)view;

#pragma mark - 计算一段代码的运行时间
CGFloat BNRTimeBlock(void (^block)(void));

#pragma mark - 拉伸图片(ios7不能再用以前的了)
+ (UIImage *)stretchableImageWithName:(NSString *)imageName edgeInsets:(UIEdgeInsets)capInsets;

#pragma mark - 拉伸图片(ios7不能再用以前的了)
+ (UIImage *)stretchableImageWithImage:(UIImage *)image edgeInsets:(UIEdgeInsets)capInsets;

#pragma mark - 行情保留小数位数
+ (NSInteger)quotationKeepDecimalPlacesWithFullcode:(NSString *)fullcode;

#pragma mark - 创建Zip文件(不删除本地源文件)
+ (BOOL)createZipWithZipName:(NSString *)zipName fileArray:(NSArray *)fileArray;

#pragma mark - 创建Zip文件(是否删除源文件)
+ (BOOL)createZipWithZipName:(NSString *)zipName fileArray:(NSArray *)fileArray deleteFile:(BOOL)isDeleteFile;

#pragma mark - 创建Zip文件(不删除源文件,自己设定文件压缩顺序)
+ (BOOL)createZipWithZipName:(NSString *)zipName fileDic:(NSDictionary *)fileDic;

#pragma mark - 创建Zip文件(删除源文件,自己设定文件压缩顺序)
+ (BOOL)createZipWithZipName:(NSString *)zipName fileDic:(NSDictionary *)fileDic deleteFile:(BOOL)isDeleteFile;

#pragma mark - 解压文件
+ (BOOL)unZipToFileWithZipPath:(NSString *)zipPath;

#pragma mark - 获取delegate的Isa,用于判断delegate是否release
+ (int)getDelegateIsa:(id)delegate;

#pragma mark - 判断delegate是否没被释放
+ (BOOL)cheackDelegateIsNotRelease:(id)delegate oldClassIsa:(int)oldClassIsa;

#pragma mark - 当前设备是否wifi或者grps
+ (NSString *)getNetWorkType;

#pragma mark - 判断手机是否越狱
+ (BOOL)isJailbroken;

#pragma mark - 判断目前设备是否ipad
+ (BOOL)isPadDevice;

#pragma mark - 获取Label粗体文本size
+ (CGSize)getPerfectSizeByBoldText:(NSString *)aText andFontSize:(CGFloat)aFontSize andWidth:(CGFloat)aWidth;


#pragma mark - 获取label文本的宽度
+ (CGSize)getPerfectLabelTextWidth:(NSString *)aText andFontSize:(CGFloat)aFontSize andHeight:(CGFloat)aHeight;

#pragma mark - 获取Label文本size
+ (CGSize)getPerfectSizeByText:(NSString *)aText andFontSize:(CGFloat)aFontSize andWidth:(CGFloat)aWidth;

/**
 *  字符串类型的十六进制颜色转换成UIColor
 *
 *  @param stringToConvert 十六进制颜色字符串
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

/**
 将一个UIColor转换成16进制的字符串,格式#FFFFFF
 @param color
 @returns 16进制颜色,格式#FFFFFF
 */
+ (NSString *)hexFromUIColor:(UIColor *)color;

/**
 将RGB颜色转换成16进制的字符串,格式#FFFFFF
 @param red
 @param green
 @param blue
 @returns 16进制颜色,格式#FFFFFF
 */
+ (NSString *)hexFromR:(NSInteger)red G:(NSInteger)green B:(NSInteger)blue;

#pragma mark - 设置UITextField中Placeholder的颜色
+ (void)setUITextFieldPlaceholderColor:(UITextField*)textField color:(UIColor*)color;

#pragma mark - 产生随机 kNumber 位字符串
+ (NSString *)getRandomDefault:(int)kNumber;

#pragma mark - MD5加密字符串
+ (NSString *)getMD5:(NSString*)code;

#pragma mark - 截取html中<img src ="" />的字符数组
+ (NSMutableArray*)getHtmlImgTagList:(NSString*)sHtmlText;

+ (NSMutableArray*)getHtmlImgSrcList:(NSString*)sHtmlText;

+ (CGRect)getImgWidthHeightValue:(NSString*)imgTag;

#pragma mark - 按钮单击时的稍微放大动画效果
/**
 *    按钮单击时的稍微放大动画效果
 *    @param sender  要设置动画的按钮
 */
+ (void)buttonOnClickAnimation:(UIView *)sender;


/**
 *    设置View的圆角
 *    @param view 要设置圆角的view
 *    @param radius 圆角半径
 *    @param borderColor  描边颜色,没有就不描边
 */
+ (void)viewMasksToBounds:(UIView *)view cornerRadius:(CGFloat)radius borderColor:(UIColor *)borderColor;

/**
 *  设置View的圆角
 *
 *  @param view        要设置圆角的view
 *  @param radius      圆角半径
 *  @param borderColor 描边颜色,没有就不描边
 *  @param borderWidth 描边线宽度
 */
+ (void)viewMasksToBounds:(UIView *)view cornerRadius:(CGFloat)radius borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

/**
 *  传入CollectionViewCell包含的某个控件，返回该控件的CollectionViewCell
 *  @param containView
 *  @return cell
 */
+ (UICollectionViewCell *)getCollectionViewCellWithContainView:(UIView *)containView;

/**
 *  传入TableViewCell包含的某个控件，返回该控件的TableViewCell
 *  @param containView
 *  @return cell
 */
+ (UITableViewCell *)getTableViewCellWithContainView:(UIView *)containView;

/**
 *  传入TableViewCell，返回该TableView
 *  @param cell
 *  @return UITableView
 */
+ (UITableView *)getTableViewWithTableViewCell:(UITableViewCell *)cell;

/**
 *  传入TableViewCell包含的某个控件，返回该控件所在的NSIndexPath
 *  @param containView
 *  @param tableView
 *  @return cell
 */
+ (NSIndexPath *)getIndexPathWithView:(UIView *)view tableView:(UITableView *)tableView;


/**
 *    得到中英文混合字符串以中文来算的长度
 *    @param strtemp 目标文字串
 *    @returns 中文长度
 */
+ (NSUInteger)getChineseLength:(NSString *)strtemp;

/**
 *    获取字符串的字节长度
 *    @param text 字符串
 *    @returns 字节长度
 */
+ (int)getStringByteNum:(NSString *)text;

/**
 *   从字符串中截取指定字节数
 *    @param string 原始字符串
 *    @param index 字节数
 *    @returns 截取后的字符串
 */
+ (NSString *)subStringByByteWithString:(NSString *)string  WithIndex:(NSInteger)index;

/**
 *    autoLayout情况下,设置一个View的高度
 *    @param view 目标View
 *    @param height 目标高度
 *    @returns 中文长度
 */
+ (void)viewHeightForAutoLayout:(UIView *)view height:(CGFloat)height;

/**
 *    autoLayout情况下,设置一个View的宽度,如果View没有宽度这个约束,就代码加上
 *    @param view 目标View
 *    @param width 目标宽度
 *    @returns 中文长度
 */
+ (void)viewWidthForAutoLayout:(UIView *)view width:(CGFloat)width;


/**
	跳转到后台管理程序
	@param userId  广告号用户的ID
 */
+ (void)openTJRManageWithUserId:(NSString *)userId;

/**
 *  只在debug模式下执行的代码
 *
 *  @param debugSome
 */
+ (void)doSomeOnlyDebug:(void (^)(void))debugSome;

/**
 *  宏定义Debug下执行和发布模式下执行
 *  (不用每次都拷贝if)
 *
 *  @param debugSome debug模式下执行的代码
 *  @param elseSome  发布模式下执行的代码
 */
+ (void)doSomeForDebug:(void (^)(void))debugSome else:(void (^)(void))elseSome;

/**
 *  把文本通过64位RSA加密。
 *
 *  @param str 明文
 *  @return sign  密文
 */
+ (NSString*)getRSA64SignString:(NSString *)str;

/**
 *  生成X位随机码。
 *
 *  @param lenght 长度
 *  @return str  随机码
 */
+ (NSString *)generateRandomCode:(int)length;

/**
 *  通过View获取View所在的ViewController
 *
 *  @param containView
 *
 *  @return
 */
+ (TJRBaseViewController *)getControllerWithContainView:(UIView *)containView;

/**
 *  设置本地通知
 *
 *  @param alertTime   延迟执行时间
 *  @param alertBody   通知内容
 *  @param badgeNumber 消息提示数
 *  @param userInfo    通知参数
 */
+ (void)registerLocalNotification:(CGFloat)alertTime alertBody:(NSString *)alertBody badgeNumber:(NSUInteger) badgeNumber userInfo:(NSDictionary *)userInfo;

/**
 *  取消本地推送通知
 *
 *  @param key 本地推送通知的Key
 */
+ (void)cancelLocalNotificationWithKey:(NSString *)key;

#pragma mark - 设置本机的推送声音跟振动
/**
 *  设置本机的推送声音跟振动
 *
 *  @param noice 是否有声音
 *  @param vibration 是否有振动
 */
+ (void)callNotificationWithNoice:(BOOL)noice vibration:(BOOL)vibration;

#pragma mark - 设置隐藏UITableView多余cell的分割线
+ (void)setExtraCellLineHidden:(UITableView *)tView;

#pragma mark - 页面过度效果 （淡出）
+ (void)setPageToAnimation;

#pragma mark - 页面过度效果（从下往上弹出）
+ (void)setPushToAnimation;

#pragma mark - 页面过度效果（从上往下pop）
+ (void)setPopToAnimation;

#pragma mark - 设置主页的TabBar位置
+ (void)setHomeViewTabBarIndex:(NSInteger)index;

#pragma mark - 获取主页的TabBar位置
+ (NSUInteger)getHomeViewTabBarIndex;

#pragma mark - 判断当前是否有录音权限
+ (BOOL)canRecord;

#pragma mark - 判断网络连接状态
+ (BOOL)networkingStatesFromStatebarIsWifi;

/**
 *  @brief  将一个浮点数保留两位小数
 *
 *  @param value  目标小数
 *
 *  @return 最终结果
 */ 
+ (NSString *)retainTwoDecimalPointOfAFloatVale:(CGFloat)value;

/**
 *  @brief  通过一个整型的变量来控制数值保留的小数点位数
 *          以往用@"%.2f"来指定保留2位小数位，现在可通过一个变量来控制保留的位数
 *
 *  @param value          目标小数
 *  @param numberOfPlace  小数位数
 *
 *  @return 最终结果
 */
+ (NSString *)newFloat:(CGFloat)value withNumber:(NSUInteger)numberOfPlace;

/**
 *  @brief  通过一个整型的变量来控制数值保留的小数点位数
 *          以往用@"%.2f"来指定保留2位小数位，现在可通过一个变量来控制保留的位数
 *
 *  @param value          目标小数
 *  @param numberOfPlace  小数位数
 *  @param isAddSign      是否添加正负号(当为正时,添加＂+＂号)
 *
 *  @return 最终结果
 */
+ (NSString *)newFloat:(CGFloat)value withNumber:(NSUInteger)numberOfPlace isAddSign:(BOOL)isAddSign;

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
+ (BOOL)limitPayMoneyDot:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string dotPreBits:(int)dotPreBits dotAfterBits:(NSInteger)dotAfterBits;


#pragma mark - 身份证号码验证
+ (BOOL)judgeIdentityStringValid:(NSString *)identityString;


/**
 *  @brief  输入金额大写
 *
 *  @param money
 *
 *  @return
 */
+ (NSString *)toCapitalLetters:(NSString *)money;

/**
 *  @brief  输入数字，1万以上转化成w，1w以下显示完整数字
 *
 *  @return
 */
+ (NSString *)translateIntoTenThousand:(NSInteger)num;


/*** 检查邮箱 */
+ (BOOL)checkEmail:(NSString *)emailStr;

/*** 隐藏邮箱 */
+ (NSString *)hidenEmailStr:(NSString *)emailStr;

/*** 隐藏手机号码 */
+ (NSString *)hidenPhoneStr:(NSString *)phoneStr;


@end

