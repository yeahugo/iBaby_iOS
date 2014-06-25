//
//  AiVIdeoPlayerManager.h
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiVideoObject.h"
#import "AiNormalPlayerViewController.h"

@interface AiVideoPlayerManager : NSObject

@property (nonatomic, strong) AiNormalPlayerViewController *aiPlayerViewController;

@property (nonatomic, strong) AiVideoObject *currentVideoObject;

+ (AiVideoPlayerManager *)shareInstance;

-(void)saveVideoInDatabase;
@end
