//
//  TJRDefineManage.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-6-19.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRDefineManage.h"

NSString *const DragBackBegan  = @"dragBackBegan";          //滑动返回开始
NSString *const DragBackChange = @"dragBackChange";         //滑动返回改变状态，只执行一次
NSString *const DragBackUp     = @"dragBackUp";             //滑动返回手势结束
NSString *const DragBackEnd    = @"dragBackEnd";            //滑动返回完成并推出页面

#pragma mark - 正式环境

//NSString *const ApiBaseUrl        = @"http://api.bitcglobaltrade.com/procoin/";   // 线上域名
//NSString *const PushSocket        = @"api.bitcglobaltrade.com";
//NSString *const ApiQuoteUrl       = @"http://market.bitcglobaltrade.com/procoin-market/";
//NSString *const QuoteSocket       = @"market.bitcglobaltrade.com";
//NSString *const ApiFilesys        = @"http://upload.bitcglobaltrade.com/procoin-file/";   // 上传文件接口

//#pragma mark - 测试环境procoin
//NSString *const ApiBaseUrl        = @"http://api.usefortest0327.com/procoin/";   // 线上域名
//NSString *const PushSocket        = @"api.usefortest0327.com";
//NSString *const ApiQuoteUrl       = @"http://market.usefortest0327.com/procoin-market/";
//NSString *const QuoteSocket       = @"market.usefortest0327.com";
//NSString *const ApiFilesys        = @"http://upload.usefortest0327.com/procoin-file/";   // 上传文件接口


#pragma mark - 测试环境procoin
//NSString *const ApiBaseUrl        = @"http://api.tradingviewex.com/procoin/";   // 线上域名
//NSString *const PushSocket        = @"api.tradingviewex.com";
//NSString *const ApiQuoteUrl       = @"http://market.tradingviewex.com/procoin-market/";
//NSString *const QuoteSocket       = @"market.tradingviewex.com";
//NSString *const ApiFilesys        = @"http://upload.tradingviewex.com/procoin-file/";   // 上传文件接口

NSString *const ApiBaseUrl        = @"http://api.qbql.cn/procoin/";   // 线上域名
NSString *const PushSocket        = @"api.qbql.cn";
NSString *const ApiQuoteUrl       = @"http://market.qbql.cn/procoin-market/";
NSString *const QuoteSocket       = @"market.qbql.cn";
NSString *const ApiFilesys        = @"http://upload.qbql.cn/procoin-file/";   // 上传文件接口


/** socket端口*/
NSInteger const CIRCLESOCKETPORT                    = 1818;
NSInteger const ApiQuotationPORT                    = 9669;

//#if UseLAN
//
////////////////////////////以下是内网ip///////////////////////////////////////////////////////////
//
////NSString *const CIRCLESOCKETIP                  = @"192.168.1.66";    // 圈子 socket ip
////NSString *const CIRCLESOCKETIP                      = @"192.168.1.40";/* 行情ip */
//NSInteger const CIRCLESOCKETPORT                = 27778;
//
////行情
////NSString *const ApiQuotationIP                      = @"192.168.1.66";/* 行情ip */
////NSString *const ApiQuotationIP                      = @"192.168.1.40";/* 行情ip */
//NSInteger const ApiQuotationPORT                    = 9778;
//
//
//#else
//
////////////////////////////以下是正常ip/////////////////////////////////////////////////////////////////////
//
////NSString *const CIRCLESOCKETIP                  = @"api.cropyme.com";    // 圈子 socket ip
//
//
////行情
////NSString *const ApiQuotationIP                      = @"api.cropyme.com";/* 行情ip */
//
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//#endif

NSString *const QuotationKLineRedFillKey        = @"QuotationKLineRedFillKey";    // 记录K线阳线是否实心

NSString *const SafariPageToHeader              = @"TjrvSafari://";// safari跳转的头
NSString *const OtherAppPageToHeader            = @"Tjrv://";
NSString *const OtherAppPageToParam             = @"OtherAppPageToParam";
NSString *const OtherAppPageToTypeString        = @"OtherAppPageToType";
