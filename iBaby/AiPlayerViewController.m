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
#import "AiScrollView.h"
#import "AiWaitingView.h"

@implementation AiPlayerViewControl

+(AiPlayerViewControl *)makePlayerViewControl
{
    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"AiPlayerViewControl" owner:self options:nil];
    AiPlayerViewControl *controlView = [nib objectAtIndex:0];
    [controlView.slider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    [controlView.slider setMinimumTrackImage:[[UIImage imageNamed:@"schedule-bar-schedule"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
    [controlView.slider setMaximumTrackImage:[UIImage imageNamed:@"schedule-bar-bottom"] forState:UIControlStateNormal];
//    [controlView.slider addTarget:self action:@selector(durationSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    controlView.slider.minimumValue = 0;
    
    [controlView.volumn_slider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    [controlView.volumn_slider setMinimumTrackImage:[[UIImage imageNamed:@"volume-bar-top"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
    [controlView.volumn_slider setMaximumTrackImage:[UIImage imageNamed:@"volume-bar-bottom"] forState:UIControlStateNormal];
//    [controlView.volumn_slider addTarget:self action:@selector(volumnSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    float volume = [MPMusicPlayerController applicationMusicPlayer].volume;
    [controlView.volumn_slider setValue:volume];
    
    BOOL isLike = [[AiDataBaseManager shareInstance] isFavouriteVideo:[AiVideoPlayerManager shareInstance].currentVideoObject];
    if (isLike) {
        [controlView.likeButton setBackgroundImage:[UIImage imageNamed:@"red_heart_pressed"] forState:UIControlStateNormal];
    } else {
        [controlView.likeButton setBackgroundImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
    }
    return controlView;
    
//    int currentTime = floor(self.moviePlayer.currentPlaybackTime);
//    controlView.slider.value = currentTime;
//    int current_minutes = currentTime / 60;
//    int current_seconds = currentTime % 60;
//    
//    NSString *currentTimeString = [NSString stringWithFormat:@"%d:%02d", current_minutes, current_seconds];
//    
//    controlView.currentTimeLabel.text = [NSString stringWithFormat:@"%@",currentTimeString];
//    
//    int totalTime = self.moviePlayer.duration;
//    int minutes = totalTime / 60;
//    int seconds = totalTime % 60;
//    
//    NSString *time = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
//    
//    controlView.totalTimeLabel.text = [NSString stringWithFormat:@"%@",time];
}

@end

@interface AiPlayerViewController ()

@end

@implementation AiPlayerViewController

-(id)initWithContentURL:(NSURL *)contentURL
{
    self = [super init];
    if (self) {
        [self.moviePlayer stop];
        self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
        [self.moviePlayer setContentURL:contentURL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishVideo) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeVideo:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
        
        if ([MPMusicPlayerController applicationMusicPlayer].volume > 0) {
            self.isOnVolumn = YES;
        } else {
            self.isOnVolumn = NO;
        }
        
        [AiWaitingView showInView:self.view];
    }
    return self;
}

-(void)viewDidLoad{
    NSString *serialId = [AiVideoPlayerManager shareInstance].currentVideoObject.serialId;
    int sectionNum = [AiVideoPlayerManager shareInstance].currentVideoObject.totalSectionNum;
    if ([serialId isEqualToString:@"0"]) {
        sectionNum = AlbumNum;
    }
    NSString *videoTitle = [AiVideoPlayerManager shareInstance].currentVideoObject.title;
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

- (void)didChangeVideo:(NSNotification *)notification
{
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        [AiWaitingView dismiss];
    }
}

-(void)finishVideo
{
    if (_timer) {
        [_timer invalidate];
    }
    if (![[AiVideoPlayerManager shareInstance].currentVideoObject.serialId isEqualToString:@"0"]) {
        int sectionNum = [AiVideoPlayerManager shareInstance].currentVideoObject.curSectionNum;
        if (self.videoArray.count > sectionNum + 2) {
            [self playVideoAtSection:sectionNum + 1];
        }
    } 
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
    
    int curSectionNum = [AiVideoPlayerManager shareInstance].currentVideoObject.curSectionNum;
    
    if ((int)(self.moviePlayer.currentPlaybackTime + 1) == (int)(self.moviePlayer.duration)) {
        if (curSectionNum + 1 < [AiVideoPlayerManager shareInstance].currentVideoObject.totalSectionNum && ![[AiVideoPlayerManager shareInstance].currentVideoObject.serialId isEqualToString:@"0"] && self.videoArray.count > 0) {
            [self playVideoAtSection:curSectionNum+1];
        }
        if([[AiVideoPlayerManager shareInstance].currentVideoObject.serialId isEqualToString:@"0"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.moviePlayer pause];
                [self onClickSelectVideos:nil];
            });
            [_timer invalidate];
        }
    }
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

-(IBAction)onClickClose:(id)sender
{
    [_timer invalidate];
    _timer = nil;
    [[AiVideoPlayerManager shareInstance] saveVideoInDatabase];
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
    int totalNum = result.count;
    UIImage *videoFrame = [UIImage imageNamed:@"episode edge"];
    CGSize size = videoFrame.size;
    self.videoArray = result;

    int curSectionNum = [AiVideoPlayerManager shareInstance].currentVideoObject.curSectionNum;
    if ([AiVideoPlayerManager shareInstance].currentVideoObject.resourceType == RESOURCE_TYPE_CARTOON) {
        int rowNum = 5;
        for (int i = 0; i < totalNum; i++) {
            UIButton *videoButton = [[UIButton alloc] initWithFrame:CGRectMake(i%rowNum * (size.width-2), i/rowNum * (size.height-2), size.width , size.height)];
            videoButton.tag = i;
            [videoButton addTarget:self action:@selector(selectVideo:) forControlEvents:UIControlEventTouchUpInside];
            ResourceInfo *resourceInfo = (ResourceInfo *)[result objectAtIndex:i];
            //获取同一专辑下的列表
            int sectionNum = resourceInfo.curSection;
            [videoButton setTitle:[NSString stringWithFormat:@"%d",sectionNum] forState:UIControlStateNormal];
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
    else{
        UIImageView *frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edge_background_low"]];
        CGSize size = frameImageView.frame.size;
        int startX = 28;
        int startY = 23;
        int deltaX = (size.width + 28);
        int deltaY = (size.height + 26);
        int rowNum = 2;
        int videoListWidth = 442;
        videoListView.frame = CGRectMake(1024-videoListWidth, videoListView.frame.origin.y, videoListWidth, videoListView.frame.size.height);
        for (int i = 0; i < totalNum; i++) {
            AiVideoObject *videoObject = [[AiVideoObject alloc] initWithResourceInfo:[result objectAtIndex:i]];
            AiScrollViewCell *scrollViewCell = [[AiScrollViewCell alloc] initWithFrame:CGRectMake(startX + deltaX *(i%rowNum) , startY + deltaY *(i/rowNum), size.width, size.height) cellType:kViewCellTypeNormal];
            scrollViewCell.aiVideoObject = videoObject;
            [videoListView addSubview:scrollViewCell];
            scrollViewCell.imageButton.tag = i;
            [scrollViewCell.imageButton removeTarget:scrollViewCell action:NULL forControlEvents:UIControlEventTouchUpInside];
            [scrollViewCell.imageButton addTarget:self action:@selector(selectVideo:) forControlEvents:UIControlEventTouchUpInside];
        }
        CGSize contentSize = CGSizeMake(videoListView.frame.size.width, ceil((float)totalNum/rowNum) * deltaY);
        [videoListView setContentSize:contentSize];
        if (contentSize.height > videoListView.frame.size.height) {
            UIView * backGroundView = [videoListView viewWithTag:2000];
            backGroundView.frame = CGRectMake(0, 0, backGroundView.frame.size.width, contentSize.height);
        }
    }
}

-(IBAction)onClickSelectVideos:(UIButton *)button
{
    NSLog(@"onClickSelectVideos !!");
    if (self.playControlView.videoListView == nil) {
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
        
        [self reloadVideoList:self.videoArray videoListView:videoListView];
        
        self.playControlView.videoListView = videoListView;
        [self.playControlView addSubview:videoListView];
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"episode_nomal"] forState:UIControlStateNormal];
        [self.playControlView.videoListView removeFromSuperview];
        self.playControlView.videoListView = nil;
    }
}

-(void)playVideoAtSection:(int)section
{
    ResourceInfo *resourceInfo = [self.videoArray objectAtIndex:section];
    AiVideoObject *videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
    [AiVideoPlayerManager shareInstance].currentVideoObject = videoObject;
    self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    
    [videoObject getSongUrlWithCompletion:^(NSString *urlString,NSError *error){
        if (error == nil) {
//            NSLog(@"-------------play url is %@ self.moviePlayer is %@",urlString,self.moviePlayer);
            [self.moviePlayer setContentURL:[NSURL URLWithString:urlString]];
            [self.moviePlayer play];
        } else {
            NSLog(@"error is %@",error);
        }
    }];
}

-(void)selectVideo:(UIButton *)button
{
    [[AiVideoPlayerManager shareInstance] saveVideoInDatabase];
    [self.playControlView removeFromSuperview];
    
    [self playVideoAtSection:button.tag];
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
    if (self.playControlView == nil) {
        AiPlayerViewControl *controlView = [AiPlayerViewControl makePlayerViewControl];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
