//
//  JGPlayerViewController.m
//  FourPlayer
//
//  Created by yeahugo on 14-3-13.
//  Copyright (c) 2014年 AiJingang. All rights reserved.
//

#import "AiNormalPlayerViewController.h"
#import "AiDataRequestManager.h"
//#import "AiVideoPlayerManager.h"
#import "AiDataBaseManager.h"
#import "AiScrollView.h"
#import "AiWaitingView.h"


@interface AiNormalPlayerViewController ()

@end

@implementation AiNormalPlayerViewController

-(id)initWithAiVideoObject:(AiVideoObject *)videoObject
{
    self = [super initWithAiVideoObject:videoObject];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishVideo) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeVideo:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
        
        self.moviePlayer = [[MPMoviePlayerController alloc] init];
        self.moviePlayer.view.frame = CGRectMake(0, 0, 1024, 768);
        [self.view addSubview:self.moviePlayer.view];
        self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
        [self.moviePlayer setContentURL:[NSURL URLWithString:videoObject.playUrl]];
        [self.moviePlayer play];
        [AiWaitingView showInView:self.moviePlayer.view];
        if ([MPMusicPlayerController applicationMusicPlayer].volume > 0) {
            self.isOnVolumn = YES;
        } else {
            self.isOnVolumn = NO;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)didChangeVideo:(NSNotification *)notification
{
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
        [AiWaitingView dismiss];
    }
}

-(void)updateTime:(NSTimer *)timer
{
    NSLog(@"updateTime here!!");
    self.playControlView.slider.minimumValue = 0;
    self.playControlView.slider.maximumValue = self.moviePlayer.duration;
    int currentTime = self.moviePlayer.currentPlaybackTime;
    int minutes = currentTime / 60;
    int seconds = currentTime % 60;
    
    NSString *time = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    self.playControlView.slider.value = currentTime;
    self.playControlView.currentTimeLabel.text = [NSString stringWithFormat:@"%@",time];
    
    int curSectionNum = self.videoObject.totalSectionNum;
    
    if ((int)(self.moviePlayer.currentPlaybackTime + 1) == (int)(self.moviePlayer.duration)) {
        if([self.videoObject.serialId isEqualToString:@"0"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.moviePlayer pause];
                [self onClickSelectVideos:nil];
                [self.timer invalidate];
                self.timer = nil;
            });
            
        } else {
            if (curSectionNum + 1 < self.videoObject.totalSectionNum && ![self.videoObject.serialId isEqualToString:@"0"] && self.videoArray.count > 0) {
                [self playVideoAtSection:curSectionNum+1];
            }
        }
    }
}

-(void)viewDidLoad{
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addControllView)];
    gesture.delegate = self;
    [self.moviePlayer.view addGestureRecognizer:gesture];
    
    [super viewDidLoad];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

-(void)finishVideo
{
    if (self.timer) {
        [self.timer invalidate];
    }
    if (![self.videoObject.serialId isEqualToString:@"0"]) {
        int sectionNum = self.videoObject.curSectionNum;
        if (self.videoArray.count > sectionNum + 2) {
            [self playVideoAtSection:sectionNum + 1];
        }
    } 
}

-(void)durationSliderValueChanged:(UISlider *)slider
{
    NSLog(@"slider value is %f",slider.value);
    [self.moviePlayer setCurrentPlaybackTime:slider.value];
}

-(void)volumnSliderValueChanged:(UISlider *)slider
{
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:slider.value];
}

-(IBAction)onClickVolumn:(UIButton *)button
{
//    NSLog(@"onClickVolumn");
    if (self.isOnVolumn == YES) {
        self.volume = [MPMusicPlayerController applicationMusicPlayer].volume;
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:0];
        self.isOnVolumn = NO;
        [button setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
    } else {
        if (self.playControlView.volumn_slider.value > 0) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:self.playControlView.volumn_slider.value];
        } else{
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.1];
        }
        self.isOnVolumn = YES;
        [button setBackgroundImage:[UIImage imageNamed:@"volume"] forState:UIControlStateNormal];
    }
}


-(IBAction)onClickPlay:(UIButton *)button
{
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self.moviePlayer pause];
        [button setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    } else {
        [self.moviePlayer play];
        [button setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

-(void)playVideoAtSection:(int)section
{
    ResourceInfo *resourceInfo = [self.videoArray objectAtIndex:section];
    AiVideoObject *videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
    if (resourceInfo.sourceType == RESOURCE_SOURCE_TYPE_RESOURCE_SOURCE_YOUKU) {
        [self.timer invalidate];
        self.timer = nil;
        [[AiDataBaseManager shareInstance] addVideoRecord:self.videoObject];
//        [[AiVideoPlayerManager shareInstance] saveVideoInDatabase];
        [self dismissViewControllerAnimated:YES completion:^(){
            [videoObject playVideo];
        }];

    } else {
        self.videoObject = videoObject;
//        [AiVideoPlayerManager shareInstance].currentVideoObject = videoObject;
        self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        
        [videoObject getSongUrlWithCompletion:^(NSString *urlString,NSError *error){
            if (error == nil) {
                [self.moviePlayer setContentURL:[NSURL URLWithString:urlString]];
                [self.moviePlayer play];
            } else {
                NSLog(@"error is %@",error);
            }
        }];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)addControllView
{
    if (self.playControlView == nil) {
        AiPlayerViewControl *controlView = [AiPlayerViewControl makePlayerViewControl:self.videoObject];
        self.playControlView = controlView;
        controlView.playerViewController = self;
        [controlView.slider addTarget:self action:@selector(durationSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        controlView.slider.maximumValue = self.moviePlayer.duration;
        
        [controlView.volumn_slider addTarget:self action:@selector(volumnSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        int currentTime = floor(self.moviePlayer.currentPlaybackTime);
        controlView.slider.value = currentTime;
        int current_minutes = currentTime / 60;
        int current_seconds = currentTime % 60;
        
        NSString *currentTimeString = [NSString stringWithFormat:@"%d:%02d", current_minutes, current_seconds];

        controlView.currentTimeLabel.text = [NSString stringWithFormat:@"%@",currentTimeString];
        
        int totalTime = self.moviePlayer.duration;
        int minutes = totalTime / 60;
        int seconds = totalTime % 60;
        
        NSString *time = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];

        controlView.totalTimeLabel.text = [NSString stringWithFormat:@"%@",time];
        [self.moviePlayer.view  addSubview:self.playControlView];
    } else {
        [self.playControlView removeFromSuperview];
        self.playControlView = nil;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
