//
//  ChatTableView.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-17.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseTableView.h"
#import "TJRPullToLoadTableView.h"
#import <AVFoundation/AVFoundation.h>

@class CircleChatExtendEntity;
@class CircleChatTableView;

typedef enum
{
    ChatTableCircle = 0,
    ChatTablePrivate,
    
} ChatTableType;

@protocol CircleChatTableViewDelegate <NSObject>

- (void)tableView:(CircleChatTableView *)tableView imageViewsTouched:(NSMutableDictionary*)touchViews url:(NSString*)url;
- (void)tableView:(CircleChatTableView *)tableView buttonErrorClicked:(NSString*)key;
- (void)tableView:(CircleChatTableView *)tableView moreNewBottom:(NSInteger)count;
- (void)tableView:(CircleChatTableView *)tableView moreNewTop:(NSInteger)count;
- (void)tableView:(CircleChatTableView *)tableView deleteItem:(NSInteger)index;
- (void)tableView:(CircleChatTableView *)tableView linkClicked:(NSString *)url;
- (void)tableView:(CircleChatTableView *)tableView fullcodeClicked:(NSString *)fullcode;
- (void)tableView:(CircleChatTableView *)tableView atClicked:(NSString *)userId;
- (void)tableView:(CircleChatTableView *)tableView setupAtUser:(NSString *)userId name:(NSString*)name;
- (void)tableView:(CircleChatTableView *)tableView contentClicked:(NSString *)pview params:(NSString*)params;
- (void)tableView:(CircleChatTableView *)tableView headViewClicked:(NSString *)userId name:(NSString*)name;
- (NSString*)tableView:(CircleChatTableView *)tableView paramsContent:(NSString *)content;
- (void)tableView:(CircleChatTableView *)tableView scrollViewDidScroll:(UIScrollView *)scrollView;
@end

@interface CircleChatTableView : TJRPullToLoadTableView<UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate>{
    
}
@property (assign, nonatomic) CGRect tableViewRect;
@property (assign, nonatomic) id<CircleChatTableViewDelegate> circleDelegate;

@property(assign, nonatomic) NSInteger moreTop;
@property(assign, nonatomic) NSInteger moreBottom;
@property(assign, nonatomic) NSInteger newsCount;

- (void)queryDataFromDB:(NSString*)circleId;
- (void)queryPrivateChatDataFromDB:(NSString*)chatTopic;
- (void)clearTableData;
- (void)insertEntity:(CircleChatExtendEntity *)item index:(NSUInteger)index;
- (void)insertEntity:(CircleChatExtendEntity *)item;
- (void)replaceEntity:(CircleChatExtendEntity *)item tmpEntity:(CircleChatExtendEntity *)tmpEntity;

- (float)getTableViewVisibleHeight;
- (void)scrollToBottom:(BOOL)animated;
- (void)scrollToTop:(BOOL)animated;

- (void)hideMenu;
@end
