//
//  AiWebViewPlayerController.m
//  iBaby
//
//  Created by yeahugo on 14-6-7.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiWebViewPlayerController.h"
#import "AiVideoPlayerManager.h"
#import "AiUserManager.h"
#import "AiDataRequestManager.h"
#import "AiWaitingView.h"
#import "AiScrollView.h"
#import "AiDataBaseManager.h"

@interface AiWebViewPlayerController ()

@end

@implementation AiWebViewPlayerController

-(id)initWithVid:(NSString *)vid
{
    self = [super initWithNibName:@"AiWebViewPlayerController" bundle:nil];
    if (self) {
        CGRect rect = [UIScreen mainScreen].bounds;
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, rect.size.height, rect.size.width)];
        self.view.backgroundColor = [UIColor blackColor];
        self.webView = webView;
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.delegate = self;
        [self playVideoWithVid:vid];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addWebViewButton)];
        tap.numberOfTapsRequired = 1;
        tap.delegate = self;
        self.recognizer = tap;
        [self.webView addGestureRecognizer:tap];
        self.playControlView = nil;
     }
    return self;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)addWebViewButton
{
    [self.recognizer removeTarget:self action:@selector(addWebViewButton)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIButton *touchButton = [[UIButton alloc] initWithFrame:self.webView.frame];
        touchButton.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addControl)];
        [touchButton addGestureRecognizer:gesture];
        self.webViewButton = touchButton;
        [self.webView addSubview:touchButton];
        });
}

-(void)viewDidDisappear:(BOOL)animated
{
    [_timer invalidate];
    [super viewDidDisappear:animated];
}

-(void)finishVideo
{
    int sectionNum = [AiVideoPlayerManager shareInstance].currentVideoObject.curSectionNum;
    if (self.videoArray.count > sectionNum + 2) {
        ResourceInfo *resourceInfo = [self.videoArray objectAtIndex:sectionNum + 1];
        AiVideoObject *videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
        [AiVideoPlayerManager shareInstance].currentVideoObject = videoObject;
        [self playVideoWithVid:videoObject.vid];
    } else {
        [self playVideoWithVid:[AiVideoPlayerManager shareInstance].currentVideoObject.vid];
    }
}

-(void)playVideoWithVid:(NSString *)vid
{
    [AiWaitingView showInView:self.webView];
    [self.webViewButton removeFromSuperview];
    [self.recognizer addTarget:self action:@selector(addWebViewButton)];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    
    NSString *clientScrete = [AiDataRequestManager shareInstance].youkuAppkey;
    NSString *clientId = [AiDataRequestManager shareInstance].youkuSecret;
    
    NSString *sourceSig = [NSString stringWithFormat:@"%@_%d_%@",vid,(int)timeInterval,clientScrete];
    NSString *signature = [AiUserManager md5Value:sourceSig];
    NSString *embSig = [NSString stringWithFormat:@"1_%d_%@",(int)timeInterval,signature];
    NSString *htmlString = [NSString stringWithFormat:@"<html><div id=\"youkuplayer\" style=\"background-color:Black;margin:-10px -10px;width:1026; height:770px;\"></div><script type=\"text/javascript\" src=\"http://player.youku.com/jsapi\"> player = new YKU.Player('youkuplayer',{client_id: '%@',vid: '%@',embsig:'%@',show_related: false,autoplay:true,events:{onPlayerReady:function(){window.location='ibaby:ready'},onPlayEnd:function(){ window.location='ibaby:finish';},onPlayStart:function(){window.location='ibaby:start'}}}); </script></html>",clientId,vid,embSig];
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (![request.URL.scheme isEqualToString:@"ibaby"]) {
        return YES;
    } else {
        if ([request.URL.resourceSpecifier isEqualToString:@"finish"]) {
            self.isPlay = NO;
            [self finishVideo];
        } else if ([request.URL.resourceSpecifier isEqualToString:@"ready"]){
            [AiWaitingView dismiss];
            [self.view addSubview:self.webView];
        } else if ([request.URL.resourceSpecifier isEqualToString:@"start"]){
//            [self addWebViewButton];
            [_timer invalidate];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
            self.isPlay = YES;
        }
        //更新播放时间
        else {
            int currentTime = [request.URL.resourceSpecifier intValue];
            int minutes = currentTime / 60;
            int seconds = currentTime % 60;
            
            NSString *time = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
            self.playControlView.slider.value = currentTime;
            self.playControlView.currentTimeLabel.text = [NSString stringWithFormat:@"%@",time];
        }
    }
    return NO;
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
        NSString *vid = [AiVideoPlayerManager shareInstance].currentVideoObject.vid;
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

-(void)selectVideo:(UIButton *)button
{
    [[AiVideoPlayerManager shareInstance] saveVideoInDatabase];
    [self.playControlView removeFromSuperview];
    AiVideoObject * videoObject = [self.videoArray objectAtIndex:button.tag];
    [self playVideoWithVid:videoObject.vid];
}


-(IBAction)onClickSelectVideos:(UIButton *)button
{
    if (self.playControlView.videoListView == nil) {
        NSString *serialId = [AiVideoPlayerManager shareInstance].currentVideoObject.serialId;
        int sectionNum = [AiVideoPlayerManager shareInstance].currentVideoObject.totalSectionNum;
//        NSString *videoTitle = [AiVideoPlayerManager shareInstance].currentVideoObject.title;
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

-(IBAction)onClickPlay:(id)button
{
    if (self.isPlay == YES) {
        self.isPlay = NO;
        [self.webView stringByEvaluatingJavaScriptFromString:@"player.pauseVideo();"];
        [button setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    } else {
        self.isPlay = YES;
        [self.webView stringByEvaluatingJavaScriptFromString:@"player.playVideo();"];
        [button setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

-(IBAction)onClickLike:(UIButton *)button
{
    AiVideoObject *videoObject = [AiVideoPlayerManager shareInstance].currentVideoObject;
    if (self.isLike == NO) {
        UIImage *likeImage = [UIImage imageNamed:@"red_heart_pressed"];
        [button setBackgroundImage:likeImage forState:UIControlStateNormal];
        self.isLike = YES;
        [[AiDataBaseManager shareInstance] addFavouriteRecord:[AiVideoPlayerManager shareInstance].currentVideoObject];
                [[AiDataRequestManager shareInstance] requestReportWithString:[NSString stringWithFormat:@"L\n%d\n%@",videoObject.sourceType,videoObject.vid] completion:nil];
    } else {
        UIImage *likeImage = [UIImage imageNamed:@"red_heart"];
        [button setBackgroundImage:likeImage forState:UIControlStateNormal];
        self.isLike = NO;
        [[AiDataBaseManager shareInstance] deleteFavouriteRecord:[AiVideoPlayerManager shareInstance].currentVideoObject];
        [[AiDataRequestManager shareInstance] requestReportWithString:[NSString stringWithFormat:@"NL\n%d\n%@",videoObject.sourceType,videoObject.vid] completion:nil];
    }
}

-(void)updateTime:(NSTimer *)timer
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"var time = player.currentTime(); window.location=\"ibaby:\"+time"];
    
}

-(void)durationSliderValueChanged:(UISlider *)slider
{
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"player.seekTo(%d)",(int)(slider.value)]];
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

-(void)addControl
{
    if (self.playControlView) {
        AiPlayerViewControl * viewControl = self.playControlView;
        [viewControl removeFromSuperview];
        self.playControlView = nil;
    } else {
        @try {
            AiPlayerViewControl *controlView = [AiPlayerViewControl makePlayerViewControl];
            [self.webViewButton addSubview:controlView];
            [controlView.slider addTarget:self action:@selector(durationSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            //毫秒转换为秒
            int durationTime =[AiVideoPlayerManager shareInstance].currentVideoObject.durationTime/1000;
            controlView.slider.maximumValue = durationTime;
            
            [controlView.volumn_slider addTarget:self action:@selector(volumnSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            
            int minutes = durationTime / 60;
            int seconds = durationTime % 60;
            
            NSString *time = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
            
            controlView.totalTimeLabel.text = [NSString stringWithFormat:@"%@",time];
            self.playControlView = controlView;
        }
        @catch (NSException *exception) {
            NSLog(@"addControl error");
        }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)onClickClose:(id)sender
{
    [_timer invalidate];
    [[AiVideoPlayerManager shareInstance] saveVideoInDatabase];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
