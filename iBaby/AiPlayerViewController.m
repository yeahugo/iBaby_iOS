//
//  JGPlayerViewController.m
//  FourPlayer
//
//  Created by yeahugo on 14-3-13.
//  Copyright (c) 2014年 AiJingang. All rights reserved.
//

#import "AiPlayerViewController.h"
#import "AiDataRequestManager.h"
#import "AiVideoPlayerManager.h"
#import "AiDataBaseManager.h"

@implementation AiPlayerViewControl

@end

@interface AiPlayerViewController ()

@end

@implementation AiPlayerViewController

-(id)initWithContentURL:(NSURL *)contentURL
{
    if ([super init]) {
        [self.moviePlayer stop];
        self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        [self.moviePlayer setContentURL:contentURL];
        _videoArray = [[NSArray alloc] init];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishVideo) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        
        NSString *serialId = [AiVideoPlayerManager shareInstance].currentVideoObject.serialId;
        int curSectionNum = [AiVideoPlayerManager shareInstance].currentVideoObject.curSectionNum;
        int sectionNum = [AiVideoPlayerManager shareInstance].currentVideoObject.totalSectionNum;
        NSString *videoTitle = [AiVideoPlayerManager shareInstance].currentVideoObject.title;
        if ([serialId isEqualToString:@"0"]) {
            sectionNum = AlbumNum;
        }
        [[AiDataRequestManager shareInstance] requestAlbumWithSerialId:serialId startId:0 recordNum:sectionNum videoTitle:videoTitle completion:^(NSArray *result, NSError *error) {
            if (result.count > 0) {
                int sectionNum = [(ResourceInfo *)[result objectAtIndex:0] sectionNum];
                if (sectionNum == 1 && ![serialId isEqualToString:@"0"]) {
                    [[AiDataRequestManager shareInstance] requestAlbumWithSerialId:serialId startId:0 recordNum:sectionNum videoTitle:videoTitle completion:^(NSArray *resultArray, NSError *error) {
                        self.videoArray = resultArray;
                    }];
                } else{
                    self.videoArray = result;
                }                
            }
        }];
    }
    return self;
}

-(void)finishVideo
{
    NSLog(@"finish video!!");
    if (_timer) {
        [_timer invalidate];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateTime:(NSTimer *)timer
{
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

-(void)volumnSliderValueChanged:(UISlider *)slider
{
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:slider.value];
}

-(IBAction)onClickVolumn:(UIButton *)button
{
    NSLog(@"onClickVolumn");
    if (self.isOnVolumn == YES) {
        [button setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
        self.moviePlayer.useApplicationAudioSession = NO;
        self.isOnVolumn = NO;
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"volume"] forState:UIControlStateNormal];
        self.moviePlayer.useApplicationAudioSession = YES;
        self.isOnVolumn = YES;
    }
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

-(void)reloadVideoList:(NSArray *)result videoListView:(UIScrollView *)videoListView
{
    int rowNum = 5;
    int totalNum = result.count;
    UIImage *videoFrame = [UIImage imageNamed:@"episode edge"];
    CGSize size = videoFrame.size;
    self.videoArray = result;
    NSString *serialId = [AiVideoPlayerManager shareInstance].currentVideoObject.serialId;
    int curSectionNum = [AiVideoPlayerManager shareInstance].currentVideoObject.curSectionNum;
    NSLog(@"curSection num is %d",curSectionNum);
    for (int i = 0; i < totalNum; i++) {
        UIButton *videoButton = [[UIButton alloc] initWithFrame:CGRectMake(i%rowNum * (size.width-2), i/rowNum * (size.height-2), size.width , size.height)];
        videoButton.tag = i;
        [videoButton addTarget:self action:@selector(selectVideo:) forControlEvents:UIControlEventTouchUpInside];
        ResourceInfo *resourceInfo = (ResourceInfo *)[result objectAtIndex:i];
        //获取同一专辑下的列表
        if (![serialId isEqualToString:@"0"]) {
            int sectionNum = resourceInfo.curSection;
            [videoButton setTitle:[NSString stringWithFormat:@"%d",sectionNum] forState:UIControlStateNormal];
        } else {
            [videoButton setTitle:resourceInfo.title forState:UIControlStateNormal];
        }
        if (curSectionNum == i+1) {
            [videoButton setBackgroundImage:[UIImage imageNamed:@"episode current"] forState:UIControlStateNormal];
        } else {
            [videoButton setBackgroundImage:[UIImage imageNamed:@"episode edge"] forState:UIControlStateNormal];
        }
        [videoListView addSubview:videoButton];
    }
    CGSize contentSize = CGSizeMake(videoListView.frame.size.width, ceil((float)totalNum/rowNum) * size.height);
    [videoListView setContentSize:contentSize];
    if (contentSize.height > videoListView.frame.size.height) {
        UIView * backGroundView = [videoListView viewWithTag:2000];
        backGroundView.frame = CGRectMake(0, 0, backGroundView.frame.size.width, contentSize.height);
    }
}

-(IBAction)onClickSelectVideos:(UIButton *)button
{
    if (self.playControlView.videoListView == nil) {
        NSLog(@"video is %@",[AiVideoPlayerManager shareInstance].currentVideoObject);
        NSString *serialId = [AiVideoPlayerManager shareInstance].currentVideoObject.serialId;
        int sectionNum = [AiVideoPlayerManager shareInstance].currentVideoObject.totalSectionNum;
        NSString *videoTitle = [AiVideoPlayerManager shareInstance].currentVideoObject.title;
        if ([serialId isEqualToString:@"0"]) {
            sectionNum = AlbumNum;
        }
        
        [button setBackgroundImage:[UIImage imageNamed:@"episode_pressed"] forState:UIControlStateNormal];
        UIImage *videoListBackgroundImage = [UIImage imageNamed:@"episode background"];
        UIScrollView *videoListView = [[UIScrollView alloc] initWithFrame:CGRectMake(1024 - videoListBackgroundImage.size.width, 89, videoListBackgroundImage.size.width, videoListBackgroundImage.size.height)];
        videoListView.tag = 10;
        UIImageView *videoListBackgroundView = [[UIImageView alloc] initWithImage:videoListBackgroundImage];
        videoListBackgroundView.tag = 2000;
        [videoListView addSubview:videoListBackgroundView];
        
        [[AiDataRequestManager shareInstance] requestAlbumWithSerialId:serialId startId:0 recordNum:sectionNum videoTitle:videoTitle completion:^(NSArray *result, NSError *error) {
            [self reloadVideoList:self.videoArray videoListView:videoListView];
        }];
        
        self.playControlView.videoListView = videoListView;
        [self.playControlView addSubview:videoListView];
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"episode_nomal"] forState:UIControlStateNormal];
        [self.playControlView.videoListView removeFromSuperview];
        self.playControlView.videoListView = nil;
    }
}


-(void)selectVideo:(UIButton *)button
{
    [[AiVideoPlayerManager shareInstance] saveVideoInDatabase];
    [self.playControlView removeFromSuperview];
    [self.moviePlayer pause];
    ResourceInfo *resourceInfo = [self.videoArray objectAtIndex:button.tag];
    AiVideoObject *videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
    [AiVideoPlayerManager shareInstance].currentVideoObject = videoObject;
    
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

-(IBAction)onClickLike:(UIButton *)button
{
    if (self.isLike == NO) {
        UIImage *likeImage = [UIImage imageNamed:@"red_heart_pressed"];
        [button setBackgroundImage:likeImage forState:UIControlStateNormal];
        self.isLike = YES;
        [[AiDataBaseManager shareInstance] addFavouriteRecord:[AiVideoPlayerManager shareInstance].currentVideoObject];
    } else {
        UIImage *likeImage = [UIImage imageNamed:@"red_heart"];
        [button setBackgroundImage:likeImage forState:UIControlStateNormal];
        self.isLike = NO;
        [[AiDataBaseManager shareInstance] deleteFavouriteRecord:[AiVideoPlayerManager shareInstance].currentVideoObject];
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
        [controlView.slider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
        [controlView.slider setMinimumTrackImage:[UIImage imageNamed:@"schedule_bar_schedule"] forState:UIControlStateNormal];
        [controlView.slider setMaximumTrackImage:[UIImage imageNamed:@"schedule_bar_bottom"] forState:UIControlStateNormal];
        [controlView.slider addTarget:self action:@selector(durationSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        controlView.slider.minimumValue = 0;
        controlView.slider.maximumValue = self.moviePlayer.duration;
        
        [controlView.volumn_slider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
        [controlView.volumn_slider setMinimumTrackImage:[UIImage imageNamed:@"volume_bar_top"] forState:UIControlStateNormal];
        [controlView.volumn_slider setMaximumTrackImage:[UIImage imageNamed:@"volume_bar_bottom"] forState:UIControlStateNormal];
        [controlView.volumn_slider addTarget:self action:@selector(volumnSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        float volume = [MPMusicPlayerController applicationMusicPlayer].volume;
        [controlView.volumn_slider setValue:volume];
        
        BOOL isLike = [[AiDataBaseManager shareInstance] isFavouriteVideo:[AiVideoPlayerManager shareInstance].currentVideoObject];
        if (isLike) {
            [controlView.likeButton setBackgroundImage:[UIImage imageNamed:@"red_heart-pressed"] forState:UIControlStateNormal];
        } else {
            [controlView.likeButton setBackgroundImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
        }
        
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
