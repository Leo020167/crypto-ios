//
//  TJRAppPurchases.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/7/20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRAppPurchases.h"
#import "PurchasesVerifyTimer.h"
#import "VeDateUtil.h"
#import "AppPurchases.h"


@interface TJRAppPurchases ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>  {
    
    BOOL bReqFinished;
    // 产品字典
    NSMutableDictionary *_productDict;
    
    SKProductsRequest *request;
}

@end

@implementation TJRAppPurchases
@synthesize delegate;

-(id)init{
    
    if ((self = [super init])) {
        //----监听购买结果----
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

        bReqFinished = YES;
        
        if (![SKPaymentQueue canMakePayments]) {
            UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"交易提示" message:@"没允许应用程序内购买" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
            
            [alerView show];
            [alerView release];
            
        }
    }
    return self;
}

- (void)productsRequest:(NSString*)productIDs{
    
    if ([SKPaymentQueue canMakePayments]) {
        //允许程序内付费购买
        
        NSArray* array = [productIDs componentsSeparatedByString:@","];
        if (array.count>0) {
            if (bReqFinished) {
                bReqFinished = NO;
                if (delegate && [delegate respondsToSelector:@selector(productsRequestBegin)]) {
                    [delegate productsRequestBegin];
                }
                //询问苹果的服务器能够销售哪些商品
                NSSet *nsset = [[[NSSet alloc]initWithArray:array]autorelease];

                // "异步"询问苹果能否销售
                request=[[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
                request.delegate=self;
                [request start];
            }
        }
    }
}

#pragma mark - 用户决定购买商品
- (void)appPay:(NSString*)productID{
    
    if ([_productDict objectForKey:productID]) {
        if (bReqFinished && _productDict.count>0) {
            bReqFinished = NO;
            if (delegate && [delegate respondsToSelector:@selector(purchasesBegin)]) {
                [delegate purchasesBegin];
            }
            // 要购买产品(店员给用户开了个小票)
            SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:_productDict[productID]];
            payment.applicationUsername = ROOTCONTROLLER_USER.userId;
            
            // 去收银台排队，准备购买(异步网络)
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    }

}


-(bool)CanMakePay{
    return [SKPaymentQueue canMakePayments];
}

#define mark - <SKProductsRequestDelegate> 请求协议 收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    //收到产品反馈信息;

    NSArray *myProduct = response.products;
    
    if (myProduct.count == 0) {
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"购买失败" message:@"无法获取产品信息" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alerView show];
        [alerView release];
    }else{
        if (_productDict == nil) {
            _productDict = [[NSMutableDictionary alloc]initWithCapacity:response.products.count];
        }
        if (_productArr == nil) {
            _productArr = [[NSMutableArray alloc]init];
        }
        [_productDict removeAllObjects];
        [_productArr removeAllObjects];
        
        NSMutableArray* arr = [[NSMutableArray alloc]init];
        for(SKProduct *product in myProduct){
            
            // 激活了对应的销售操作按钮，相当于商店的商品上架允许销售
            AppPurchases* item = [[[AppPurchases alloc]init]autorelease];
            item.productIdentifier = product.productIdentifier;
            item.localizedDescription = product.localizedDescription;
            item.localizedTitle = product.localizedTitle;
            item.price = product.price;
            [arr addObject:item];
            
            // 填充商品字典
            [_productDict setObject:product forKey:product.productIdentifier];
        }
        
        NSMutableArray* array = (NSMutableArray*)[arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSNumber *number1 = ((AppPurchases*)obj1).price;
            NSNumber *number2 = ((AppPurchases*)obj2).price;
            
            NSComparisonResult result = [number1 compare:number2];
            
            return result == NSOrderedDescending; // 升序
        }];
        
        [_productArr addObjectsFromArray:array];
    }
    
    bReqFinished = YES;
    
    if (delegate && [delegate respondsToSelector:@selector(productsRequestFinished)]) {
        [delegate productsRequestFinished];
    }

}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    //处理交易结果
    
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {

            case SKPaymentTransactionStateDeferred:
            {
                // Do not block your UI. Allow the user to continue using your app.
                break;
            }
            case SKPaymentTransactionStatePurchased:
            {
                //交易完成
                bReqFinished = YES;
                if (delegate && [delegate respondsToSelector:@selector(purchasesFinished)]) {
                    [delegate purchasesFinished];
                }
                
                [self completeTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:
            {
                //交易失败
                bReqFinished = YES;
                if (delegate && [delegate respondsToSelector:@selector(purchasesFalid)]) {
                    [delegate purchasesFalid];
                }
                
                [self failedTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                //已经购买过该商品
                bReqFinished = YES;
                if (delegate && [delegate respondsToSelector:@selector(purchasesFinished)]) {
                    [delegate purchasesFinished];
                }
                [self restoreTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStatePurchasing:
            {
                //商品添加进列表
                if (delegate && [delegate respondsToSelector:@selector(purchasingState)]) {
                    [delegate purchasingState];
                }
                break;
            }
            default:
                break;
        }
    }
}

-(void)paymentQueue:(SKPaymentQueue *)paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions{
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads{
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction{

    // 向自己的服务器验证购买凭证
    NSDateFormatter *dateformat = [[[NSDateFormatter  alloc] init]autorelease];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSString* transactionDate = [dateformat stringFromDate:transaction.transactionDate];
    
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    PurchasesVerifyTimer* vTimer = [PurchasesVerifyTimer shareVerifyTimer];
    [vTimer verifyPruchase:transaction.transactionIdentifier base64EncodedString:encodeStr productIdentifier:transaction.payment.productIdentifier transactionDate:transactionDate times:0];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction: (SKPaymentTransaction *)transaction{
    //交易失败
    if (transaction.error.code != SKErrorPaymentCancelled){
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"购买提示" message:@"购买失败，请重新尝试购买" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        
        [alerView show];
        [alerView release];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark - 恢复商品
- (void)restoreTransaction:(SKPaymentTransaction *)transaction{
    //交易恢复处理
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    [self completeTransaction:transaction];
}

-(void)dealloc{
    [request cancel];
    [request release];
    [_productDict release];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
    [super dealloc];
}

@end



