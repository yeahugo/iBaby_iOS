//
//  AiPlayerViewController.m
//  iBaby
//
//  Created by yeahugo on 14-6-16.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiPlayerViewController.h"
#import "AiDataBaseManager.h"
//#import "AiVideoPlayerManager.h"
#import "AiWaitingView.h"
#import "AiScrollView.h"
#import "AiDataRequestManager.h"

@implementation AiPlayerViewControl

+(AiPlayerViewControl *)makePlayerViewControl:(AiVideoObject *)videoObject
{
    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"AiPlayerViewControl" owner:self options:nil];
    AiPlayerViewControl *controlView = [nib objectAtIndex:0];
    [controlView.slider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    [controlView.slider setMinimumTrackImage:[[UIImage imageNamed:@"schedule-bar-schedule"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
    [controlView.slider setMaximumTrackImage:[UIImage imageNamed:@"schedule-bar-bottom"] forState:UIControlStateNormal];
    controlView.slider.minimumValue = 0;
    
    [controlView.volumn_slider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    [controlView.volumn_slider setMinimumTrackImage:[[UIImage imageNamed:@"volume-bar-top"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
    [controlView.volumn_slider setMaximumTrackImage:[UIImage imageNamed:@"volume-bar-bottom"] forState:UIControlStateNormal];
    float volume = [MPMusicPlayerController applicationMusicPlayer].volume;
    [controlView.volumn_slider setValue:volume];
    controlView.videoObject = videoObject;
    BOOL isLike = [[AiDataBaseManager shareInstance] isFavouriteVideo:videoObject];
    if (isLike) {
        [controlView.likeButton setBackgroundImage:[UIImage imageNamed:@"red_heart_pressed"] forState:UIControlStateNormal];
    } else {
        [controlView.likeButton setBackgroundImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
    }
    [controlView.likeButton addTarget:controlView action:@selector(onLikeClick) forControlEvents:UIControlEventTouchUpInside];
    return controlView;
}

-(void)onLikeClick
{
    if (self.videoObject.isLike == NO) {
        [self.likeButton setBackgroundImage:[UIImage imageNamed:@"red_heart_pressed"] forState:UIControlStateNormal];
        [[AiDataRequestManager shareInstance] requestReportWithString:[NSString stringWithFormat:@"L\t%d\n%@",self.videoObject.sourceType,self.videoObject.vid] completion:nil];
        [[AiDataBaseManager shareInstance] addFavouriteRecord:self.videoObject];
    } else {
        [self.likeButton setBackgroundImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
        [[AiDataRequestManager shareInstance] requestReportWithString:[NSString stringWithFormat:@"NL\t%d\n%@",self.videoObject.sourceType,self.videoObject.vid] completion:nil];
        [[AiDataBaseManager shareInstance] deleteFavouriteRecord:self.videoObject];
    }
}

@end


@interface AiPlayerViewController ()

@end

@implementation AiPlayerViewController

-(id)initWithAiVideoObject:(AiVideoObject *)videoObject
{
    self = [super init];
    if (self) {
        self.videoObject = videoObject;
    }
    return self;
}

- (void)viewDidLoad
{
    NSString *serialId = self.videoObject.serialId;
    int sectionNum = self.videoObject.totalSectionNum;
    if ([serialId isEqualToString:@"0"]) {
        sectionNum = AlbumNum;
    }
    NSString *videoTitle = self.videoObject.title;
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


-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

-(void)finishVideo
{
    if (_timer) {
        [_timer invalidate];
    }
    if (![self.videoObject.serialId isEqualToString:@"0"]) {
        int sectionNum = self.videoObject.curSectionNum;
        if (self.videoArray.count > sectionNum + 2) {
            [self playVideoAtSection:sectionNum + 1];
        }
    } 
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
    [self.timer invalidate];
    self.timer = nil;
    [[AiDataBaseManager shareInstance] addVideoRecord:self.videoObject];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)reloadVideoList:(NSArray *)result videoListView:(UIScrollView *)videoListView
{
    int totalNum = result.count;
    UIImage *videoFrame = [UIImage imageNamed:@"episode edge"];
    CGSize size = videoFrame.size;
    self.videoArray = result;

    int curSectionNum = self.videoObject.curSectionNum;
    if (self.videoObject.resourceType == RESOURCE_TYPE_CARTOON) {
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
        NSString *vid = self.videoObject.vid;
        for (int i = 0; i < totalNum; i++) {
            AiVideoObject *videoObject = [[AiVideoObject alloc] initWithResourceInfo:[result objectAtIndex:i]];
            AiScrollViewCell *scrollViewCell = [[AiScrollViewCell alloc] initWithFrame:CGRectMake(startX + deltaX *(i%rowNum) , startY + deltaY *(i/rowNum), size.width, size.height) cellType:kViewCellTypeNormal];
            scrollViewCell.aiVideoObject = videoObject;
            [videoListView addSubview:scrollViewCell];
            scrollViewCell.imageButton.tag = i;
            [scrollViewCell.imageButton removeTarget:scrollViewCell action:NULL forControlEvents:UIControlEventTouchUpInside];
            [scrollViewCell.imageButton addTarget:self action:@selector(selectVideo:) forControlEvents:UIControlEventTouchUpInside];
            if ([vid isEqualToString:videoObject.vid]) {
                [scrollViewCell setHightLightScrollViewCell];
            }
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
//    NSLog(@"onClickSelectVideos !!");
    if (self.playControlView.videoListView == nil) {
        NSString *serialId = self.videoObject.serialId;
        int sectionNum = self.videoObject.totalSectionNum;
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
    if (resourceInfo.sourceType == RESOURCE_SOURCE_TYPE_RESOURCE_SOURCE_YOUKU) {
        [_timer invalidate];
        _timer = nil;
        [[AiDataBaseManager shareInstance] addVideoRecord:self.videoObject];
        [self dismissViewControllerAnimated:YES completion:^(){
            [videoObject playVideo];
        }];

    } else {
        self.videoObject = videoObject;
//        self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
//        
//        [videoObject getSongUrlWithCompletion:^(NSString *urlString,NSError *error){
//            if (error == nil) {
//                [self.moviePlayer setContentURL:[NSURL URLWithString:urlString]];
//                [self.moviePlayer play];
//            } else {
//                NSLog(@"error is %@",error);
//            }
//        }];
    }
}

-(void)selectVideo:(UIButton *)button
{
    [[AiDataBaseManager shareInstance] addVideoRecord:self.videoObject];
    [self.playControlView removeFromSuperview];
    
    [self playVideoAtSection:button.tag];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
