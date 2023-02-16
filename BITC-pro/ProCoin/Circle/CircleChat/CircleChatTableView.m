//
//  CircleChatTableView.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-17.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "CircleChatTableView.h"
#import "VeDateUtil.h"
#import "VoiceConverter.h"
#import "TTCacheManager.h"
#import "CircleEntity.h"
#import "CircleSQL.h"
#import "CircleChatExtendEntity.h"
#import "CircleChatTextCell.h"
#import "CircleChatVoiceCell.h"
#import "CircleChatImageCell.h"
#import "CircleChatSystemCell.h"
#import "CircleChatJsonCell.h"
#import "CircleChatLocalCell.h"
#import "CircleSocket.h"
#import "TJRImageAndDownFile.h"
#import "TJRVoicePlayView.h"
#import "CommonUtil.h"

#define tagOfVoiceImageView     104

@interface CircleChatTableView ()<CircleChatTextCellDelegate,CircleChatImageCellDelegate,CircleChatVoiceCellDelegate,CircleChatJsonCellDelegate,CircleChatSystemCellDelegate>{
    NSMutableArray *tableData;
    UIMenuController *menuController;
    BOOL bReqFinished;
    NSInteger selectRow;
    NSMutableDictionary* tableDic;
    
    UIView* mark;
    BOOL bMakeVoice;            //是否需要连续播放
    
    ChatTableType tableType;
}
@property(copy, nonatomic) NSString *priorTime;     //前一个时间label
@property(retain, nonatomic) CircleChatExtendEntity *localMsgTmp;
@property(assign, nonatomic) NSString *circleId;
@property(copy, nonatomic) NSString *chatTopic;

@end

@implementation CircleChatTableView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization{
    [super initialization];
    
    self.dataSource = self;
    self.delegate = self;

    bReqFinished = YES;
    tableData = [[NSMutableArray alloc]init];
    tableDic = [[NSMutableDictionary alloc]init];
    selectRow = -1;
    
    menuController = [UIMenuController sharedMenuController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenuController) name:UIMenuControllerWillHideMenuNotification object:menuController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowMenuController) name:UIMenuControllerWillShowMenuNotification object:menuController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceOverNotification:) name:TJRVoicePlayViewOverKey object:nil];
    
}


- (void)queryDataFromDB:(NSString*)circleId {
    NSArray *circleArray = [CircleSQL queryCircleChatWithCircleId:circleId mark:0 greaterOrLessMark:true length:CIRCLESQL_QUERY_MAX];
    if (circleArray) {
        [tableData removeAllObjects];
        for (CircleChatEntity *entity in circleArray) {
            CircleChatExtendEntity *item = [CircleChatExtendEntity toExtendEntity:entity];
            [tableData addObject:item];
            [tableDic setObject:item forKey:[NSString stringWithFormat:@"%@",@(item.mark)]];
        }
        [self reloadData];
    }
    [self scrollToBottom:NO];
    self.circleId = circleId;
    tableType = ChatTableCircle;
    
    if ([circleArray count]>=20) {
        [self footerViewEndDidRefresh];
    }else{
        [self footerViewEndRefreshNoData];
    }
}

- (void)queryPrivateChatDataFromDB:(NSString*)chatTopic {
    NSArray *circleArray = [CircleSQL queryPrivateChatWithChatTopic:chatTopic mark:0 greaterOrLessMark:true length:CIRCLESQL_QUERY_MAX];
    if (circleArray) {
        [tableData removeAllObjects];
        for (CircleChatEntity *entity in circleArray) {
            CircleChatExtendEntity *item = [CircleChatExtendEntity toExtendEntity:entity];
            [tableData addObject:item];
            [tableDic setObject:item forKey:[NSString stringWithFormat:@"%@",@(item.mark)]];
        }
        [self reloadData];
    }
    [self scrollToBottom:NO];
    self.chatTopic = chatTopic;
    tableType = ChatTablePrivate;
    
    if ([circleArray count]>=20) {
        [self footerViewEndDidRefresh];
    }else{
        [self footerViewEndRefreshNoData];
    }
}

- (void)scrollToBottom:(BOOL)animated{
    if ([tableData count]) {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[tableData count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)scrollToTop:(BOOL)animated{
    
    if (tableData.count < self.newsCount) {
        
        //load取news一下的所有数据
        CircleChatExtendEntity *fItem = [self getTableDataFirstObject];
        if (!fItem) return;
        
        NSArray *circleArray = nil;
        
        switch (tableType) {
            case ChatTableCircle:
            {
                circleArray = [CircleSQL queryCircleChatWithCircleId:self.circleId mark:fItem.mark greaterOrLessMark:false length:self.newsCount];
                break;
            }
            case ChatTablePrivate:
            {
                circleArray = [CircleSQL queryPrivateChatWithChatTopic:self.chatTopic mark:fItem.mark greaterOrLessMark:false length:self.newsCount];
                break;
            }
            default:
                break;
        }
        
        if (circleArray) {
            for (int i = (int)[circleArray count] - 1; i>=0; i--) {
                CircleChatEntity *entity = [circleArray objectAtIndex:i];
                CircleChatExtendEntity *item = [CircleChatExtendEntity toExtendEntity:entity];
                [tableData insertObject:item atIndex:0];
                
                if ([tableData count] == self.newsCount) {
                    [tableData insertObject:self.localMsgTmp atIndex:0];
                }
            }
            if ([tableData count] < self.newsCount) {
                if (circleArray.count>0)[tableData insertObject:self.localMsgTmp atIndex:0];
            }
            [self reloadData];
        }
    }
    
    NSInteger i = 0;
    for (CircleChatExtendEntity *item in tableData) {
        i++;
        if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_LOCAL]) {
            [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
            break;
        }
    }
    
}

#pragma mark - Refresh Delegate Methods
- (void)refreshDidBegin{

    CircleChatExtendEntity *fItem = [self getTableDataFirstObject];
    if (!fItem) return;
    
    NSArray *circleArray =  nil;
    
    switch (tableType) {
        case ChatTableCircle:
        {
            circleArray = [CircleSQL queryCircleChatWithCircleId:self.circleId mark:fItem.mark greaterOrLessMark:false length:CIRCLESQL_QUERY_MAX];
            break;
        }
        case ChatTablePrivate:
        {
            circleArray = [CircleSQL queryPrivateChatWithChatTopic:self.chatTopic mark:fItem.mark greaterOrLessMark:false length:CIRCLESQL_QUERY_MAX];
            break;
        }
        default:
            break;
    }
    
    if (circleArray) {
        for (int i = (int)[circleArray count] - 1; i>=0; i--) {
            CircleChatEntity *entity = [circleArray objectAtIndex:i];
            CircleChatExtendEntity *item = [CircleChatExtendEntity toExtendEntity:entity];
            [tableData insertObject:item atIndex:0];
            
            if ([tableData count] == self.newsCount) {
                [tableData insertObject:self.localMsgTmp atIndex:0];
            }
        }
        if ([tableData count] < self.newsCount && [tableData count] < CIRCLESQL_QUERY_MAX) {
            if (circleArray.count>0)[tableData insertObject:self.localMsgTmp atIndex:0];
            _moreTop = 0;
            if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:moreNewTop:)]) {
                [_circleDelegate tableView:self moreNewTop:_moreTop];
            }
        }
        [self reloadData];
    }
    if ([circleArray count]>=20) {
        [self footerViewEndDidRefresh];
        bReqFinished = YES;
    }else{
        [self footerViewEndRefreshNoData];
        bReqFinished = NO;
    }
    
    
}
- (void)footerViewRefreshing:(TJRPullToLoadFooterView *)control{
    [super footerViewRefreshing:control];
    //等待2s
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (bReqFinished) {
            bReqFinished = NO;
            [self refreshDidBegin];
        }
        
    });
    
}



#pragma mark -
#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    float height = 0;
    
    CircleChatExtendEntity *item = [tableData objectAtIndex:indexPath.row];
    
    //以第一个item的时间为开始
    if (indexPath.row == 0)
        self.priorTime = item.createTime;
    else {
        CircleChatExtendEntity *priorItem = [tableData objectAtIndex:indexPath.row - 1];
        self.priorTime = priorItem.createTime;
    }
    
    //获取时间分隔标签
    item.timeFormat = [self getTimeString:self.priorTime thisTime:item.createTime];
    if (item.timeFormat.length > 0) {
        self.priorTime = item.timeFormat;
        item.timeFormat = [VeDateUtil dateLongFormatter:item.timeFormat];
    }
    
    if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_TEXT]) {
        //文本类型
        height = [CircleChatTextCell getHeightOfCell:item.say isMine:[item.userId isEqualToString:ROOTCONTROLLER_USER.userId] timeFormat:item.timeFormat];
        
    }else if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_VOICE]) {
        
        height = [CircleChatVoiceCell getHeightOfCell:item.say isMine:[item.userId isEqualToString:ROOTCONTROLLER_USER.userId] timeFormat:item.timeFormat];
        
    }else if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_IMG]) {
        height = [CircleChatImageCell getHeightOfCell:[item.userId isEqualToString:ROOTCONTROLLER_USER.userId] size:item.imgSize timeFormat:item.timeFormat];
        
    }else if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_SYSTEM]) {
        height = [CircleChatSystemCell getHeightOfCell:item.timeFormat say:item.say];
        
    }else if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_LOCAL]) {
        height = [CircleChatLocalCell getHeightOfCell];

    }else if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_JSON]) {
        height = [CircleChatJsonCell getHeightOfCell:[item.userId isEqualToString:ROOTCONTROLLER_USER.userId] timeFormat:item.timeFormat say:item.say];
    }else{
        height = [CircleChatSystemCell getHeightOfCell:item.timeFormat say:@""];
    }
    item.cellHeight = height;
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    UITableViewCell *cell = nil;
    
    CircleChatExtendEntity *item = [tableData objectAtIndex:indexPath.row];

    
     if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_TEXT]) {
        //文本类型
        if ([item.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
            static NSString *rightTextIdentifier = @"CircleChatTextRightCell";
            cell = [self dequeueReusableCellWithIdentifier:rightTextIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:rightTextIdentifier owner:self options:nil]lastObject];
            }
            CircleChatTextCell* c = (CircleChatTextCell*)cell;
            c.delegate = self;
            [c setTextCell:item];
            
        }else {
            static NSString *leftTextIdentifier = @"CircleChatTextLeftCell";
            cell = [self dequeueReusableCellWithIdentifier:leftTextIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:leftTextIdentifier owner:self options:nil]lastObject];
            }
            CircleChatTextCell* c = (CircleChatTextCell*)cell;
            c.delegate = self;
            [c setTextCell:item];
        }
        
    }else if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_VOICE]) {
        
        if ([item.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
            static NSString *rightVoiceIdentifier = @"CircleChatVoiceRightCell";
            cell = [self dequeueReusableCellWithIdentifier:rightVoiceIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:rightVoiceIdentifier owner:self options:nil]lastObject];
                CircleChatVoiceCell* c = (CircleChatVoiceCell*)cell;
                [c setPlayView:item];
            }
            CircleChatVoiceCell* c = (CircleChatVoiceCell*)cell;
            c.delegate = self;
            [c setVoiceCell:item];
            
        }else {
            static NSString *leftVoiceIdentifier = @"CircleChatVoiceLeftCell";
            cell = [self dequeueReusableCellWithIdentifier:leftVoiceIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:leftVoiceIdentifier owner:self options:nil]lastObject];
                CircleChatVoiceCell* c = (CircleChatVoiceCell*)cell;
                [c setPlayView:item];
            }
            CircleChatVoiceCell* c = (CircleChatVoiceCell*)cell;
            c.delegate = self;
            [c setVoiceCell:item];
        }
        
    }else if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_IMG]) {
        
        if ([item.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
            static NSString *rightImageIdentifier = @"CircleChatImageRightCell";
            cell = [self dequeueReusableCellWithIdentifier:rightImageIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:rightImageIdentifier owner:self options:nil]lastObject];
            }
            CircleChatImageCell* c = (CircleChatImageCell*)cell;
            c.delegate = self;
            [c setImageCell:item];
            
        }else {
            static NSString *leftImageIdentifier = @"CircleChatImageLeftCell";
            cell = [self dequeueReusableCellWithIdentifier:leftImageIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:leftImageIdentifier owner:self options:nil]lastObject];
            }
            CircleChatImageCell* c = (CircleChatImageCell*)cell;
            c.delegate = self;
            [c setImageCell:item];
        }
    }else if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_SYSTEM]) {
        
        static NSString *systemCellIdentifier = @"CircleChatSystemCell";
        cell = [self dequeueReusableCellWithIdentifier:systemCellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:systemCellIdentifier owner:self options:nil]lastObject];
        }
        CircleChatSystemCell* c = (CircleChatSystemCell*)cell;
        c.delegate = self;
        [c setSystemCell:item];
        
    }else if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_LOCAL]) {
        
        static NSString *localCellIdentifier = @"CircleChatLocalCell";
        cell = [self dequeueReusableCellWithIdentifier:localCellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:localCellIdentifier owner:self options:nil]lastObject];
        }
        CircleChatLocalCell* c = (CircleChatLocalCell*)cell;
        [c setLocalCell:item];
        
    }else if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_JSON]) {
        
        if ([item.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
            static NSString *rightJsonIdentifier = @"CircleChatJsonRightCell";
            cell = [self dequeueReusableCellWithIdentifier:rightJsonIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:rightJsonIdentifier owner:self options:nil]lastObject];
            }
            CircleChatJsonCell* c = (CircleChatJsonCell*)cell;
            c.delegate = self;
            [c setJsonCell:item];
            
        }else {
            static NSString *leftJsonIdentifier = @"CircleChatJsonLeftCell";
            cell = [self dequeueReusableCellWithIdentifier:leftJsonIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:leftJsonIdentifier owner:self options:nil]lastObject];
            }
            CircleChatJsonCell* c = (CircleChatJsonCell*)cell;
            c.delegate = self;
            [c setJsonCell:item];
        }
    }else {
        //未知类型
        static NSString *systemCellIdentifier = @"CircleChatSystemCell";
        cell = [self dequeueReusableCellWithIdentifier:systemCellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:systemCellIdentifier owner:self options:nil]lastObject];
        }
        CircleChatSystemCell* c = (CircleChatSystemCell*)cell;
        item.say = [NSString stringWithFormat:@"%@ 发送了新的消息，当前版本暂不支持",item.userName];
        [c setSystemCell:item];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableData.count<=indexPath.row) {
        return;
    }
    
    CircleChatExtendEntity *item = [tableData objectAtIndex:indexPath.row];
    
    if ([cell isKindOfClass:[CircleChatTextCell class]]) {
        CircleChatTextCell* c = (CircleChatTextCell*)cell;
        [c willDispayTableViewCell:[item.userId isEqualToString:ROOTCONTROLLER_USER.userId]];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    
    if (tableData.count<=indexPath.row) {
        return;
    }
    
    CircleChatExtendEntity *item = [tableData objectAtIndex:indexPath.row];
    
    if ([cell isKindOfClass:[CircleChatTextCell class]]) {
        CircleChatTextCell* c = (CircleChatTextCell*)cell;
        [c willDispayTableViewCell:[item.userId isEqualToString:ROOTCONTROLLER_USER.userId]];
    }
}


#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (void)showLastCellActivityIndicator:(BOOL)show{
}

- (void)clearTableData{
    
    [tableData removeAllObjects];
    [tableDic removeAllObjects];
    [self reloadData];
}

- (void)insertEntity:(CircleChatExtendEntity *)item index:(NSUInteger)index{
    
    _newsCount = index;
    if (index < tableData.count) {
        [tableData insertObject:item atIndex:(tableData.count - index)];
    }else{
        self.localMsgTmp = item;
    }
    [self reloadData];
}

- (void)insertEntity:(CircleChatExtendEntity *)item{
    
    if (item.mark>0) {
        if (![tableDic objectForKey:[NSString stringWithFormat:@"%@",@(item.mark)]]) {
            [tableDic setObject:item forKey:[NSString stringWithFormat:@"%@",@(item.mark)]];
            [tableData addObject:item];
        }
    }else{
        [tableData addObject:item];
    }
    
    [self reloadData];
    if (CGRectIsEmpty(_tableViewRect)) return;
    
    CGRect frame = self.frame;
    frame.size.height = _tableViewRect.size.height + item.cellHeight;
    self.frame = frame;
    [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.frame = _tableViewRect;
        
    }completion:^(BOOL finished){
    }];
    
    CGPoint offset = self.contentOffset;
    
    if (self.contentSize.height - offset.y > 2*_tableViewRect.size.height) {
        offset.y -= item.cellHeight;
        self.contentOffset = offset;
        _moreBottom ++;
        if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:moreNewBottom:)]) {
            [_circleDelegate tableView:self moreNewBottom:_moreBottom];
        }
    }else{
        [self scrollToBottom:YES];
    }
}

- (void)replaceEntity:(CircleChatExtendEntity *)item tmpEntity:(CircleChatExtendEntity *)tmpEntity{
    
    for (NSInteger i = [tableData count] - 1; i>=0; i--) {
        CircleChatExtendEntity *entity =  [tableData objectAtIndex:i];
        if (entity.say.length>0 && [entity.say isEqualToString:tmpEntity.say] && [ROOTCONTROLLER_USER.userId isEqualToString:entity.userId]) {
            [tableData removeObject:entity];
            break;
        }
    }

    if (![tableDic objectForKey:[NSString stringWithFormat:@"%@",@(item.mark)]]) {
        [tableDic setObject:item forKey:[NSString stringWithFormat:@"%@",@(item.mark)]];
        [tableData addObject:item];
    }
    
    [self reloadData];
    
    [self scrollToBottom:YES];
    
    
}

#pragma mark - TextCell delegate
- (void)circleChatTextCell:(CircleChatTextCell *)textCell handleLongPressed:(UILongPressGestureRecognizer *)recognizer{
    
    selectRow = [self indexPathForCell:textCell].row;
    CircleChatExtendEntity *item = [tableData objectAtIndex:selectRow];
    item.isClicked = YES;
    [self reloadData];
    [self showMenu:(UIView*)textCell.bubbleView delete:YES copy:YES];
}

- (void)circleChatTextCell:(CircleChatTextCell *)textCell linkClicked:(NSString *)url{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:linkClicked:)]) {
        [_circleDelegate tableView:self linkClicked:url];
    }
}

- (void)circleChatTextCell:(CircleChatTextCell *)textCell fullcodeClicked:(NSString *)fullcode{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:fullcodeClicked:)]) {
        [_circleDelegate tableView:self fullcodeClicked:fullcode];
    }
}

- (void)circleChatTextCell:(CircleChatTextCell *)textCell paramsClicked:(NSString *)params{
    NSDictionary* dic = [CommonUtil jsonValue:params];
    NSInteger type = [[dic objectForKey:@"type"]integerValue];
    switch (type) {
        case 1:
        {
            NSDictionary* paramsDic = [CommonUtil jsonValue:[dic objectForKey:@"params"]];
            NSString* userId = [NSString stringWithFormat:@"%@",[paramsDic objectForKey:@"userId"]];
            if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:atClicked:)]) {
                [_circleDelegate tableView:self atClicked:userId];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)circleChatTextCell:(CircleChatTextCell *)textCell buttonErrorClicked:(NSString*)key{
    selectRow = [self indexPathForCell:textCell].row;
    CircleChatExtendEntity *item = [tableData objectAtIndex:selectRow];
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:buttonErrorClicked:)]) {
        [_circleDelegate tableView:self buttonErrorClicked:item.verifi];
    }
}

- (void)circleChatTextCell:(CircleChatTextCell *)textCell headViewLongPressed:(NSString *)userId name:(NSString*)name{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:setupAtUser:name:)]) {
        [_circleDelegate tableView:self setupAtUser:userId name:name];
    }
}

- (void)circleChatTextCell:(CircleChatTextCell *)textCell headViewClicked:(NSString *)userId name:(NSString*)name{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:headViewClicked:name:)]) {
        [_circleDelegate tableView:self headViewClicked:userId name:name];
    }
}

#pragma mark - ImageCell delegate
- (void)circleChatImageCell:(CircleChatImageCell *)imgCell handleLongPressed:(UILongPressGestureRecognizer *)recognizer{
    selectRow = [self indexPathForCell:imgCell].row;
    CircleChatExtendEntity *item = [tableData objectAtIndex:selectRow];
    item.isClicked = YES;
    [self reloadData];
    [self showMenu:(UIView*)imgCell.bubbleView delete:YES copy:NO];
}

- (void)circleChatImageCell:(CircleChatImageCell *)imgCell imageViewTouched:(UIView *)touchView url:(NSString*)url{
    
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc]init]autorelease];
    NSArray* cells = [self visibleCells];
    for (UITableViewCell* cell in cells) {
        if ([cell isKindOfClass:[CircleChatImageCell class]]) {
            TJRImageAndDownFile* imageView = ((CircleChatImageCell*)cell).imageAndDownFile;
            if (imageView && TTIsStringWithAnyText(imageView.urlPath)) {
                [dic setObject:imageView forKey:imageView.urlPath];
            }
        }
    }
    
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:imageViewsTouched:url:)]) {
        [_circleDelegate tableView:self imageViewsTouched:dic url:url];
    }
}

- (void)circleChatImageCell:(CircleChatImageCell *)imgCell buttonErrorClicked:(NSString*)key{
    selectRow = [self indexPathForCell:imgCell].row;
    CircleChatExtendEntity *item = [tableData objectAtIndex:selectRow];
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:buttonErrorClicked:)]) {
        [_circleDelegate tableView:self buttonErrorClicked:item.verifi];
    }
}

- (void)circleChatImageCell:(CircleChatImageCell *)imgCell headViewLongPressed:(NSString *)userId name:(NSString*)name{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:setupAtUser:name:)]) {
        [_circleDelegate tableView:self setupAtUser:userId name:name];
    }
}

- (void)circleChatImageCell:(CircleChatImageCell *)imgCell headViewClicked:(NSString *)userId name:(NSString*)name{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:headViewClicked:name:)]) {
        [_circleDelegate tableView:self headViewClicked:userId name:name];
    }
}

#pragma mark - VoiceCell delegate
- (void)circleChatVoiceCell:(CircleChatVoiceCell *)voiceCell handleLongPressed:(UILongPressGestureRecognizer *)recognizer{
    selectRow = [self indexPathForCell:voiceCell].row;
    CircleChatExtendEntity *item = [tableData objectAtIndex:selectRow];
    item.isClicked = YES;
    [self reloadData];
    [self showMenu:(UIView*)voiceCell.voicePlayView delete:YES copy:NO];
}

- (void)circleChatVoiceCell:(CircleChatVoiceCell *)voiceCell buttonErrorClicked:(NSString*)key{
    selectRow = [self indexPathForCell:voiceCell].row;
    CircleChatExtendEntity *item = [tableData objectAtIndex:selectRow];
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:buttonErrorClicked:)]) {
        [_circleDelegate tableView:self buttonErrorClicked:item.verifi];
    }
}
- (void)circleChatVoiceCell:(CircleChatVoiceCell *)voiceCell voiceClicked:(NSString*)url{
    
    NSInteger row = [self indexPathForCell:voiceCell].row;
    CircleChatExtendEntity *item = [tableData objectAtIndex:row];
    
    CircleChatExtendEntity *entity = nil;
    switch (tableType) {
        case ChatTableCircle:
        {
            entity = [CircleSQL queryCircleChatWithCircleId:item.circleId mark:item.mark];
            if (entity && !entity.isRead) {
                bMakeVoice = YES;
                item.isRead = YES;
                [CircleSQL updateCircleChatRead:item];
            }else{
                bMakeVoice = NO;
            }
            break;
        }
        case ChatTablePrivate:
        {
            entity = [CircleSQL queryCircleChatWithChatTopic:item.chatTopic mark:item.mark];
            if (entity && !entity.isRead) {
                bMakeVoice = YES;
                item.isRead = YES;
                [CircleSQL updatePrivateChatRead:item];
            }else{
                bMakeVoice = NO;
            }
            break;
        }
        default:
            break;
    }
    [self reloadData];
    
}

- (void)voiceOverNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *url = [userInfo objectForKey:TJRVoicePlayViewVoiceUrlKey];

    BOOL bNext = NO;
    for (int i = 0; i< tableData.count; i++) {
        CircleChatExtendEntity *item = [tableData objectAtIndex:i];
        if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_VOICE] && ![item.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
            if (bNext && !item.isRead && bMakeVoice) {

                CircleChatVoiceCell *voiceCell = (CircleChatVoiceCell *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                [voiceCell playVoice:item.say voiceLength:item.voiceLength];
                break;
            }
            
            if ([item.say isEqualToString:url]) {
                bNext = YES;//寻找下一条需要连播的语音
            }
        }
    }

    
}

- (void)circleChatVoiceCell:(CircleChatVoiceCell *)voiceCell headViewLongPressed:(NSString *)userId name:(NSString*)name{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:setupAtUser:name:)]) {
        [_circleDelegate tableView:self setupAtUser:userId name:name];
    }
}

- (void)circleChatVoiceCell:(CircleChatVoiceCell *)voiceCell headViewClicked:(NSString *)userId name:(NSString*)name{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:headViewClicked:name:)]) {
        [_circleDelegate tableView:self headViewClicked:userId name:name];
    }
}

#pragma mark - JsonCell delegate
- (void)circleChatJsonCell:(CircleChatJsonCell *)stockCell handleLongPressed:(UILongPressGestureRecognizer *)recognizer{
    selectRow = [self indexPathForCell:stockCell].row;
    CircleChatExtendEntity *item = [tableData objectAtIndex:selectRow];
    item.isClicked = YES;
    [self reloadData];
    [self showMenu:(UIView*)stockCell.bubbleView delete:YES copy:NO];
}

- (void)circleChatJsonCell:(CircleChatJsonCell *)stockCell contentCellTouched:(UIView *)touchView pview:(NSString*)pview params:(NSString*)params{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:contentClicked:params:)]) {
        [_circleDelegate tableView:self contentClicked:pview params:params];
    }
}

- (void)circleChatJsonCell:(CircleChatJsonCell *)stockCell buttonErrorClicked:(id)sender{
    selectRow = [self indexPathForCell:stockCell].row;
    CircleChatExtendEntity *item = [tableData objectAtIndex:selectRow];
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:buttonErrorClicked:)]) {
        [_circleDelegate tableView:self buttonErrorClicked:item.verifi];
    }
}

- (void)circleChatJsonCell:(CircleChatJsonCell *)stockCell headViewLongPressed:(NSString *)userId name:(NSString*)name{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:setupAtUser:name:)]) {
        [_circleDelegate tableView:self setupAtUser:userId name:name];
    }
}

- (void)circleChatJsonCell:(CircleChatJsonCell *)stockCell headViewClicked:(NSString *)userId name:(NSString*)name{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:headViewClicked:name:)]) {
        [_circleDelegate tableView:self headViewClicked:userId name:name];
    }
}

#pragma mark - SystemCell delegate
- (void)circleChatSystemCell:(CircleChatSystemCell *)systemCell fullcodeClicked:(NSString *)fullcode{
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:fullcodeClicked:)]) {
        [_circleDelegate tableView:self fullcodeClicked:fullcode];
    }
}
- (void)circleChatSystemCell:(CircleChatSystemCell *)systemCell paramsClicked:(NSString *)params{
    
    NSDictionary* dic = [CommonUtil jsonValue:params];
    NSInteger type = [[dic objectForKey:@"type"]integerValue];
    switch (type) {
        case 1:
        {
            //1代表人名点击
            NSDictionary* paramsDic = [CommonUtil jsonValue:[dic objectForKey:@"params"]];
            NSString* userId = [NSString stringWithFormat:@"%@",[paramsDic objectForKey:@"userId"]];
            if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:atClicked:)]) {
                [_circleDelegate tableView:self atClicked:userId];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - Menu
- (void)showMenu:(UIView*)view delete:(BOOL)delete copy:(BOOL)copy{
    //必须成为第一响应者
    [self becomeFirstResponder];
    
    menuController = [UIMenuController sharedMenuController];
    
    NSMutableArray* arr = [[[NSMutableArray alloc]init]autorelease];
    
    if (delete) {
        //删除选项
        UIMenuItem *deleteItem = [[[UIMenuItem alloc] initWithTitle:@"删除消息" action:@selector(deleteSelectedMessage:)]autorelease];
        [arr addObject:deleteItem];
    }
    
    if (copy) {
        UIMenuItem *copyItem = [[[UIMenuItem alloc] initWithTitle:@"复制文本" action:@selector(copySelectedMessage:)]autorelease];
        [arr addObject:copyItem];
    }
    
   [menuController setMenuItems:arr];
    
    //设置菜单栏位置
    [menuController setTargetRect:view.frame inView:view.superview];
    
    //显示菜单栏
    [self setMenuVisible:YES animated:YES];
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    BOOL retValue = NO;
    
    if (action == @selector(deleteSelectedMessage:)) {
        retValue = YES;
    }else if (action == @selector(copySelectedMessage:)){
        retValue = YES;
    }
    return retValue;
}

- (void)setMenuVisible:(BOOL)bVisible animated:(BOOL)animated{
    [menuController setMenuVisible:bVisible animated:animated];
}

//删除选中消息
- (void)deleteSelectedMessage:(id)sender {
    if (selectRow < 0) return;
    
    CircleChatExtendEntity *item = [tableData objectAtIndex:selectRow];
    
    BOOL isLastItem = NO;
    if ([item isEqual:[tableData lastObject]]) {
        isLastItem = YES;
    }
   
    NSInteger i = [tableData indexOfObject:item];
    NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
    
    switch (tableType) {
        case ChatTableCircle:
        {
            [CircleSQL delectCircleChatWithCircleId:item.circleId mark:item.mark];
            break;
        }
        case ChatTablePrivate:
        {
            [CircleSQL delectPrivateChatWithChatTopic:item.chatTopic mark:item.mark];
            break;
        }
        default:
            break;
    }
    
    NSInteger animation =[item.userId isEqualToString:ROOTCONTROLLER_USER.userId]?UITableViewRowAnimationRight:UITableViewRowAnimationLeft;
    
    [tableData removeObjectAtIndex:i];
    [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:animation];

    selectRow = -1;
    
    if (isLastItem) {
        if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:deleteItem:)]) {
            [_circleDelegate tableView:self deleteItem:i];
        }
    }
    
}
//复制选中消息
- (void)copySelectedMessage:(id)sender {
     if (selectRow < 0) return;
    
    CircleChatExtendEntity *item = [tableData objectAtIndex:selectRow];
    NSString* content = item.say;
    
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:paramsContent:)]) {
        content = [_circleDelegate tableView:self paramsContent:item.say];
    }
    
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    [generalPasteBoard setString:content];
    
    
}

// 取消气泡选中状态
- (void)willHideMenuController{
    
    [mark removeFromSuperview];
    
    if (selectRow < 0) return;
    CircleChatExtendEntity *item = [tableData objectAtIndex:selectRow];
    item.isClicked = NO;
    selectRow = -1;
    [self reloadData];

    
}

- (void)willShowMenuController{
    
    if (!mark) mark = [[UIView alloc]initWithFrame:self.superview.frame];
    [self.superview addSubview:mark];
}


- (void)hideMenu{
    
    //关闭菜单栏
    [self setMenuVisible:NO animated:YES];
    [self willHideMenuController];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    
    if (!(scrollView.dragging || scrollView.tracking)) return;
    
    if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:scrollViewDidScroll:)]) {
        [_circleDelegate tableView:self scrollViewDidScroll:scrollView];
    }
    
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    CGFloat currentOffset = offset.y + bounds.size.height - inset.bottom;
    CGFloat maximumOffset = size.height;

    if(currentOffset>=maximumOffset-20){
        _moreBottom = 0;
        if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:moreNewBottom:)]) {
            [_circleDelegate tableView:self moreNewBottom:_moreBottom];
        }
    }
    
    if(currentOffset<=(maximumOffset/3*2)){
        _moreTop = 0;
        if (_circleDelegate && [_circleDelegate respondsToSelector:@selector(tableView:moreNewTop:)]) {
            [_circleDelegate tableView:self moreNewTop:_moreTop];
        }
    }
}

#pragma mark - 获取时间标签
/**
 获取时间标签
 @param priorTime 前一个时间
 @param thisTime 聊天记录的时间
 @returns 时间字符串
 */
- (NSString*)getTimeString:(NSString*)priorTime thisTime:(NSString*)thisTime{
    
    NSString *str = @"";
    if ([priorTime isEqualToString:thisTime]) {
        return priorTime;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *priorDate = [formatter dateFromString:priorTime];
    NSDate *thisDate = [formatter dateFromString:thisTime];
    
    //时间间隔
    NSTimeInterval thisPriorInterval = [thisDate timeIntervalSinceDate:priorDate] / (3600*24);

    //大于半天
    if (thisPriorInterval > 0.02)
        str = thisTime;

    [formatter release];
    
    return str;
}

- (float)getTableViewVisibleHeight{

    NSArray *indexPathsForVisibleRows = [self indexPathsForVisibleRows];
    
    float height = 0;
    for (NSIndexPath* indexPath in indexPathsForVisibleRows) {
        UITableViewCell* cell = [self cellForRowAtIndexPath:indexPath];
        height = height + cell.frame.size.height;
    }
    return height;
}

- (CircleChatExtendEntity *)getTableDataFirstObject{
    
    CircleChatExtendEntity *entity = nil;
    for (int i = 0; i< [tableData count]; i++) {
        CircleChatExtendEntity *item = [tableData objectAtIndex:i];
        if (![item.sayType isEqualToString:CIRCLE_CHAT_TYPE_LOCAL]) {
            entity = [tableData objectAtIndex:i];
            break;
        }
    }
    return entity;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_circleId release];
    [tableDic release];
    [tableData release];
    [_localMsgTmp release];
    [_priorTime release];
    [super dealloc];
}

@end
