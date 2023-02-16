//
//  CircleChatRecordView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-6-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "CircleChatRecordView.h"

@interface CircleChatRecordView (){
    
}
@property (retain, nonatomic) IBOutlet UIButton *btnSend;

@end

@implementation CircleChatRecordView

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self initTJRRecordView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self initTJRRecordView];
	}
	return self;
}

- (void)initTJRRecordView {
	[[NSBundle mainBundle] loadNibNamed:@"CircleChatRecordView" owner:self options:nil];
	self.allView.frame = self.bounds;
	[self addSubview:self.allView];
    [super initData];
}

- (void)finish:(BOOL)hasData{
    [self setSendBtnEnable:hasData];
}

- (void)clean{
    [super deleteRecordFile];
    [self setSendBtnEnable:NO];
}

- (IBAction)sendButtonClicked:(id)sender {
    if ([_circleDelegate respondsToSelector:@selector(recordView:recordOnClickSend:length:)]) {
        if ([self getMp3FileName].length>0 || [self recordTimeLength]>0) {
            [_circleDelegate recordView:self recordOnClickSend:[self getMp3FileName] length:[self recordTimeLength]];
        }
    }
}

- (void)setSendBtnEnable:(BOOL)enable{
    if (enable) {
        [_btnSend setBackgroundImage:[UIImage imageNamed:@"circleChat_face_send_btn_b"] forState:UIControlStateNormal];
        [_btnSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [_btnSend setBackgroundImage:[UIImage imageNamed:@"circleChat_face_send_btn"] forState:UIControlStateNormal];
        [_btnSend setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    [_btnSend release];
	[super dealloc];
}

@end

