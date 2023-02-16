//
//  TJRBaseTableView.h
//  TJRtaojinroad
//
//  Created by linqing lv on 12-9-18.
//  Copyright (c) 2012年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJRBaseTableView : UITableView{
    NSMutableDictionary *ttDelegateDictionary;
}
- (void)recordHttpRequest:(NSString *)cacheKey httpRequest:(id)httpRequest;
- (void)removeHttpRequestFromDictionary:(NSString *)cacheKey;
@end
