//
//  AiAudioManager.h
//  iBaby
//
//  Created by yeahugo on 14-5-27.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AiAudioManager : NSObject

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

+ (AiAudioManager *)shareInstance;

+ (void)play:(NSString *)soundName;

@end
