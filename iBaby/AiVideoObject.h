//
//  AiVideoObject.h
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiDefine.h"
#import "AiThriftManager.h"

@class AiPlayerViewControl;

@interface AiVideoObject : NSObject<NSCopying>

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *imageUrl;

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, assign) NSInteger playTime;

@property (nonatomic, copy) NSString *serialId;

@property (nonatomic, assign) int resourceType;

@property (nonatomic, assign) int sourceType;

@property (nonatomic, copy) NSString *playUrl;

@property (nonatomic, assign) int curSectionNum;

@property (nonatomic, assign) int totalSectionNum;

@property (nonatomic, assign) int status;

@property (nonatomic, assign) int durationTime;

@property (nonatomic, copy) NSString *serialTitle;

@property (nonatomic, copy) NSString *serialDes;

@property (nonatomic, assign) BOOL isLike;

-(void)getSongUrlWithCompletion:(void (^)(NSString *urlString,NSError *error))completion;

-(id)initWithResourceInfo:(ResourceInfo *)resourceInfo;

-(void)playVideo;

@end
