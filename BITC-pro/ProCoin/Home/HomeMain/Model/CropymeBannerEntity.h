//
//  CropymeBannerEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"


@interface CropymeBannerEntity : TJRBaseEntity


@property (copy, nonatomic) NSString *bannerId;
@property (copy, nonatomic) NSString *imageUrl;
@property (copy, nonatomic) NSString *params;
@property (copy, nonatomic) NSString *pview;
@property (assign, nonatomic) NSInteger type;
@property (copy, nonatomic) NSString *videoUrl;

@end

