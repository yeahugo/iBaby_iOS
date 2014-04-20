//
//  JGPlayerViewController.m
//  FourPlayer
//
//  Created by yeahugo on 14-3-13.
//  Copyright (c) 2014年 AiJingang. All rights reserved.
//

#import "AiPlayerViewController.h"

@implementation AiPlayerViewControl

@end

@interface AiPlayerViewController ()

@end

@implementation AiPlayerViewController

-(id)initWithContentURL:(NSURL *)contentURL
{
    if ([super initWithContentURL:contentURL]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishVideo) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    return self;
}

-(void)finishVideo
{
    if (_timer) {
        [_timer invalidate];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateTime:(NSTimer *)timer
{
    NSLog(@"update !!");
    self.playControlView.slider.minimumValue = 0;
    self.playControlView.slider.maximumValue = self.moviePlayer.duration;
    int currentTime = self.moviePlayer.currentPlaybackTime;
    int minutes = currentTime / 60;
    int seconds = currentTime % 60;
    
    NSString *time = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    self.playControlView.slider.value = currentTime;
    self.playControlView.currentTimeLabel.text = [NSString stringWithFormat:@"%@",time];
}

-(void)durationSliderValueChanged:(UISlider *)slider
{
    [self.moviePlayer setCurrentPlaybackTime:slider.value];
}

-(IBAction)onClickClose:(id)sender
{
    [_timer invalidate];
    _timer = nil;
    [self dismissModalViewControllerAnimated:YES];
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

-(IBAction)onClickSelectVideos:(id)sender
{
    if (self.playControlView.videoListView == nil) {
        UIImage *videoListBackgroundImage = [UIImage imageNamed:@"videoList_background"];
        UIView *videoListView = [[UIView alloc] initWithFrame:CGRectMake(550, 80, videoListBackgroundImage.size.width, videoListBackgroundImage.size.height)];
        videoListView.tag = 10;
        UIImageView *videoListBackgroundView = [[UIImageView alloc] initWithImage:videoListBackgroundImage];
        [videoListView addSubview:videoListBackgroundView];
        
        int rowNum = 5;
        int totalNum = 40;
        UIImage *videoFrame = [UIImage imageNamed:@"video_frame"];
        CGSize size = videoFrame.size;
        for (int i = 0; i < totalNum; i++) {
            UIButton *videoButton = [[UIButton alloc] initWithFrame:CGRectMake(i%rowNum * size.width, i/rowNum * size.height, size.width , size.height)];
            [videoButton setBackgroundImage:[UIImage imageNamed:@"video_frame"] forState:UIControlStateNormal];
            [videoListView addSubview:videoButton];
        }
        self.playControlView.videoListView = videoListView;
        [self.playControlView addSubview:videoListView];
    } else {
        [self.playControlView.videoListView removeFromSuperview];
        self.playControlView.videoListView = nil;
    }
}

-(IBAction)onClickLike:(UIButton *)button
{
    if (self.isLike == NO) {
        UIImage *likeImage = [UIImage imageNamed:@"like_select"];
        [button setBackgroundImage:likeImage forState:UIControlStateNormal];
        self.isLike = YES;
    } else {
        UIImage *likeImage = [UIImage imageNamed:@"like"];
        [button setBackgroundImage:likeImage forState:UIControlStateNormal];
        self.isLike = NO;
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
    NSLog(@"addControllView");

    if (self.playControlView == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"AiPlayerViewControl" owner:self options:nil];
        //得到第一个UIView
        AiPlayerViewControl *controlView = [nib objectAtIndex:0];
        controlView.playerViewController = self;
        self.playControlView = controlView;
        [controlView.slider setThumbImage:[UIImage imageNamed:@"slider_point"] forState:UIControlStateNormal];
        [controlView.slider setMinimumTrackImage:[UIImage imageNamed:@"slider_background_min"] forState:UIControlStateNormal];
        [controlView.slider setMaximumTrackImage:[UIImage imageNamed:@"slider_background_max"] forState:UIControlStateNormal];
        [controlView.slider addTarget:self action:@selector(durationSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        controlView.slider.minimumValue = 0;
        controlView.slider.maximumValue = self.moviePlayer.duration;
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
        [self.view addSubview:self.playControlView];
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

- (void)viewDidLoad
{
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addControllView)];
    gesture.delegate = self;
    [self.moviePlayer.view addGestureRecognizer:gesture];

    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
