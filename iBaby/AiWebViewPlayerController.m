//
//  AiWebViewPlayerController.m
//  iBaby
//
//  Created by yeahugo on 14-6-7.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiWebViewPlayerController.h"
//#import "AiVideoPlayerManager.h"
#import "AiUserManager.h"
#import "AiDataRequestManager.h"
#import "AiWaitingView.h"
#import "AiScrollView.h"
#import "AiDataBaseManager.h"

@interface AiWebViewPlayerController ()

@end

@implementation AiWebViewPlayerController
-(id)initWithAiVideoObject:(AiVideoObject *)videoObject
{
    if (self = [super initWithAiVideoObject:videoObject]) {
        CGRect rect = [UIScreen mainScreen].bounds;
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, rect.size.height, rect.size.width)];
        self.view.backgroundColor = [UIColor blackColor];
        self.webView = webView;
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.delegate = self;
        [self playVideoWithVid:videoObject.vid];
        
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
    [self.timer invalidate];
    [super viewDidDisappear:animated];
}

-(void)finishVideo
{
    int sectionNum = self.videoObject.curSectionNum;
    if (self.videoArray.count > sectionNum + 2) {
        ResourceInfo *resourceInfo = [self.videoArray objectAtIndex:sectionNum + 1];
        AiVideoObject *videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
        self.videoObject = videoObject;
        [self playVideoWithVid:videoObject.vid];
    } else {
        [self playVideoWithVid:self.videoObject.vid];
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
            [self.timer invalidate];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
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
            AiPlayerViewControl *controlView = [AiPlayerViewControl makePlayerViewControl:self.videoObject];
            [self.webViewButton addSubview:controlView];
            [controlView.slider addTarget:self action:@selector(durationSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            //毫秒转换为秒
            int durationTime = self.videoObject.durationTime/1000;
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
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
