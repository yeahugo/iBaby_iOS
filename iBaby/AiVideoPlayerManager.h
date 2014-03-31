//
//  AiVIdeoPlayerManager.h
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiPlayerViewController.h"
#import "AiVideoObject.h"

@interface AiVideoPlayerManager : NSObject

@property (nonatomic, strong) AiPlayerViewController *aiPlayerViewController;

@property (nonatomic, strong) AiVideoObject *currentVideoObject;

+ (AiVideoPlayerManager *)shareInstance;

@end
