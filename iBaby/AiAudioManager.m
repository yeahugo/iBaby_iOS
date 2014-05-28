//
//  AiAudioManager.m
//  iBaby
//
//  Created by yeahugo on 14-5-27.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiAudioManager.h"

@implementation AiAudioManager

+ (AiAudioManager *)shareInstance {
    static AiAudioManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

+ (void)play:(NSString *)soundName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
    NSURL *audioUrl = [[NSURL alloc] initFileURLWithPath:path];
    [self shareInstance].audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
    [[self shareInstance].audioPlayer prepareToPlay];
    [[self shareInstance].audioPlayer play];
}

@end
