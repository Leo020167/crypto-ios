//
//  ChatPopView.m
//  taojinroad
//
//  Created by road taojin on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChatEditPopView.h"

#define aFontSize 15

@implementation ChatEditPopView

@synthesize popBackground;
@synthesize contentLabel;
@synthesize delegate;

- (id)initWithBgImageName:(NSString *)bgImageName {
	self = [super init];

	if (self) {
		self.backgroundColor = [UIColor clearColor];
		UIImageView *back = [[UIImageView alloc] init];
		self.popBackground = back;
		[back release];

		UIImage *theImage = [UIImage imageNamed:bgImageName];
		bgImageSize = CGSizeMake(theImage.size.width, theImage.size.height + 10);

		popBackground.image = [theImage stretchableImageWithLeftCapWidth:21 topCapHeight:15];

		[self addSubview:popBackground];

		UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, popBackground.image.size.width, popBackground.image.size.height)];
		self.contentLabel = content;
		[content release];
		contentLabel.numberOfLines = 0;
		contentLabel.font = [UIFont systemFontOfSize:aFontSize];
		contentLabel.center = popBackground.center;
		contentLabel.backgroundColor = [UIColor clearColor];
		[contentLabel setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:contentLabel];

		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched)];
		[tapGestureRecognizer setNumberOfTapsRequired:2];
		[self addGestureRecognizer:tapGestureRecognizer];
		[tapGestureRecognizer release];
	}
	return self;
}

- (void)setText:(NSString *)str {
	contentLabel.text = str;
	[contentLabel sizeToFit];
	[self setNeedsLayout];
}

- (void)layoutSubviews {
	int width;

	if (self.contentLabel.text.length < 3) {
		width = bgImageSize.width;
	} else if ((self.contentLabel.text.length >= 3) && (self.contentLabel.text.length < 6)) {
		width = bgImageSize.width * 1.5;
	} else {
		width = bgImageSize.width * 2;
	}
	// [contentLabel sizeToFit];

	CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size = [contentLabel.text boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:aFontSize]} context:nil].size;

	if (contentLabel.text.length <= 0) {
		contentLabel.frame = CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, width, bgImageSize.height);
	} else {
		contentLabel.frame = CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, width, size.height + bgImageSize.height / 2.0);
	}

	popBackground.frame = CGRectMake(popBackground.frame.origin.x, popBackground.frame.origin.y, contentLabel.frame.size.width + 10, contentLabel.frame.size.height);
	self.contentLabel.center = CGPointMake(popBackground.center.x, popBackground.center.y - 2);

	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, popBackground.frame.size.width + 5, popBackground.frame.size.height + 5);

	[super layoutSubviews];
}

- (void)dealloc {
	[popBackground release];
	[contentLabel release];
	[super dealloc];
}

- (void)backgroundTouched {
	if ([delegate respondsToSelector:@selector(backgroundDoubleClick:)]) [delegate backgroundDoubleClick:self.tag];
}

@end

