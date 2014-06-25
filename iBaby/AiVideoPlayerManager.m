//
//  AiVIdeoPlayerManager.m
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiVideoPlayerManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AiDataBaseManager.h"

@implementation AiVideoPlayerManager

+ (AiVideoPlayerManager *)shareInstance {
    static AiVideoPlayerManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

-(id)init
{
    self = [super init];
    if (self) {
        AiNormalPlayerViewController * playerViewController = [[AiNormalPlayerViewController alloc] init];
        self.aiPlayerViewController = playerViewController;
        _currentVideoObject = [[AiVideoObject alloc] init];
    }
    return self;
}

-(void)saveVideo:(NSNotification *)notification
{
    if (![self.currentVideoObject.serialId isEqualToString:@"0"]) {
        int sectionNum = self.currentVideoObject.curSectionNum;
        if (self.aiPlayerViewController.videoArray.count > sectionNum + 2) {
            [self.aiPlayerViewController playVideoAtSection:sectionNum + 1];
        }
    } else {
//        MPMoviePlayerController *moviePlayer = self.aiPlayerViewController.moviePlayer;
//        [moviePlayer stop];
    }
    [self saveVideoInDatabase];
}

-(void)saveVideoInDatabase
{
    AiVideoObject *aiVideoObject = self.currentVideoObject;
#warning Todo here
//    aiVideoObject.playTime = self.aiPlayerViewController.moviePlayer.currentPlaybackTime;
    [[AiDataBaseManager shareInstance] addVideoRecord:aiVideoObject];
}
@end
