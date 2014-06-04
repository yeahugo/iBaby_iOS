//
//  ViewController.m
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiFirstViewController.h"
#import "AiVideoObject.h"
#import "AiDefine.h"
#import "AiDataRequestManager.h"
#import "AiScrollViewController.h"
#import "AiAlbumViewController.h"
#import "AiUserManager.h"

#import "MZFormSheetController.h"
#import "SwipeView.h"

#import "Reachability.h"
#import "iToast.h"
#import "AFNetworking.h"

#import "AiWaitingView.h"
#import "AiVideoPlayerManager.h"
#import "AiAudioManager.h"

@interface AiFirstViewController ()
{
    AiDataRequestManager *_dataManager;
    NSMutableArray *_songListArray;
    
    AiScrollViewController *_songViewController;
    AiScrollViewController *_catoonViewController;
    AiScrollViewController *_videoViewController;
    
    kTagButtonType _currentType;
    int _scrollNum;
    BOOL _isPresentView;
    BOOL _isOnClickButton;
}
@end

@implementation AiFirstViewController

-(void)addNoNetworkTip
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    if ([window viewWithTag:100]) {
        return;
    }
    UIImage *unreachableImage = [UIImage imageNamed:@"no_network"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:unreachableImage];
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        imageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
    } else {
        imageView.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    imageView.center = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
    imageView.tag = 101;
//    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    UIButton *unreachButton = [[UIButton alloc] initWithFrame:self.view.frame];
    [unreachButton setBackgroundColor:[UIColor lightGrayColor]];
    [unreachButton addTarget:self action:@selector(removeUnreach:) forControlEvents:UIControlEventTouchUpInside];
    unreachButton.tag = 100;
    unreachButton.alpha = 0.6;
    [window addSubview:unreachButton];
    [window addSubview:imageView];
    [AiAudioManager play:@"no_network"];
}

-(void)removeUnreach:(UIButton *)button
{
    [button removeFromSuperview];
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *subView = [window viewWithTag:101];
    [subView removeFromSuperview];
}

-(void)removeNetworkTip
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    NSArray *subViews = window.subviews;
    for (UIView *subView in subViews) {
        if (subView.tag == 100 || subView.tag == 101) {
            [subView removeFromSuperview];
        }
    }
}

- (void)checkNetwork
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == AFNetworkReachabilityStatusNotReachable) {
                [self addNoNetworkTip];
            } else {
//                [self removeNetworkTip];
//                if (self.songScrollView.videoDatas.count == 0) {
//                    [self.songScrollView.scrollViewController getRecommendResourceType];
//                }
//                if (self.catoonScrollView.videoDatas.count == 0) {
//                    [self.catoonScrollView.scrollViewController getRecommendResourceType];
//                }
//                if (self.videoScrollView.videoDatas.count == 0) {
//                    [self.videoScrollView.scrollViewController getRecommendResourceType];
//                }
            }
        });
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

-(void)reachabilityChanged:(NSNotification *)note{
    Reachability * reach = [note object];
    
    if(![reach isReachable])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addNoNetworkTip];
        });
        NSLog(@"isReachableViaWiFi close!!");
        return;
    }
    
    if (reach.isReachableViaWiFi) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeNetworkTip];
        });
        NSLog(@"isReachableViaWiFi recieve!!");
    } else {
    }
    
    if (reach.isReachableViaWWAN) {
        NSLog(@"isReachableViaWiFi WWAN!!");
    } else {
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AiUserManager shareInstance];
    [self setUI];
    _isPresentView = NO;
    _isOnClickButton = NO;
    [self checkNetwork];
}

-(void)setUI
{
    self.songButton.tag = kTagButtonTypeSong;
    self.catoonButton.tag = kTagButtonTypeCatoon;
    self.videoButton.tag = kTagButtonTypeVideo;
    
    CGRect backGroundRect = self.backgroundView.frame;
    
    _songViewController = [[AiScrollViewController alloc] initWithFrame:backGroundRect recommend:RESOURCE_TYPE_SONG];
    _songViewController.videoType = kTagButtonTypeSong;
    _songViewController.sourceType = kDataSourceTypeWeb;
    self.songScrollView = _songViewController.scrollView;
    self.songScrollView.tag = kTagButtonTypeSong;
    
    _catoonViewController = [[AiScrollViewController alloc] initWithFrame:backGroundRect recommend:RESOURCE_TYPE_CARTOON];
    _catoonViewController.videoType = kTagButtonTypeCatoon;
    _catoonViewController.sourceType = kDataSourceTypeWeb;
    self.catoonScrollView = _catoonViewController.scrollView;
    self.catoonScrollView.tag = kTagButtonTypeCatoon;
//
    _videoViewController = [[AiScrollViewController alloc] initWithFrame:backGroundRect recommend:RESOURCE_TYPE_TV];
    _videoViewController.videoType = kTagButtonTypeVideo;
    _videoViewController.sourceType = kDataSourceTypeWeb;
    self.videoScrollView = _videoViewController.scrollView;
    self.videoScrollView.tag = kTagButtonTypeVideo;

    SwipeView *swipeView = [[SwipeView alloc] initWithFrame:backGroundRect];
    swipeView.delegate = self;
    swipeView.dataSource = self;
    swipeView.pagingEnabled = NO;
    swipeView.scrollEnabled = NO;
    self.swipeview = swipeView;
    [self.view addSubview:self.swipeview];
    [self setCurrentButton:_currentType];
    
    [AiWaitingView showInView:self.view];
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return 3;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    if (_isOnClickButton == NO) {
        _currentType = swipeView.currentItemIndex;
        NSLog(@"currentType is %d",_currentType);
        [self setCurrentButton:_currentType];        
    }
}

- (void)swipeViewWillBeginDecelerating:(SwipeView *)swipeView
{
    _isOnClickButton = NO;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIView *showView = nil;
    if (index == 0) {
        showView = self.songScrollView;
    }
    if (index == 1) {
        showView = _catoonViewController.scrollView;
    }
    if (index == 2) {
        showView = _videoViewController.scrollView;
    }
    return showView;
}

-(IBAction)closeSheetController
{
    self.closeButton.hidden = YES;
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}

-(MZFormSheetController *)makeMZFormSheetController:(UIViewController *)viewController
{
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:viewController];
    self.formSheetController = formSheet;

    formSheet.presentedFormSheetSize = CGSizeMake(876, 588);
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    return formSheet;
}

-(void)presentAlbumViewObject:(AiVideoObject *)videoObject
{
    if (_isPresentView == NO) {
        _isPresentView = YES;
        AiAlbumViewController *albumViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"album"];
        [AiVideoPlayerManager shareInstance].currentVideoObject = videoObject;
//        AiAlbumViewController *albumViewController = [[AiAlbumViewController alloc] initWithVideoObject:videoObject];
        [self mz_presentFormSheetController:[self makeMZFormSheetController:albumViewController] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            NSLog(@"finish!!");
            _isPresentView = NO;
        }];
    }
}

-(void)resetButtons
{
    [self.searchButton setBackgroundImage:[UIImage imageNamed:@"search_normal"] forState:UIControlStateNormal];
    [self.historyButton setBackgroundImage:[UIImage imageNamed:@"history_normal"] forState:UIControlStateNormal];
    [self.favouriteButton setBackgroundImage:[UIImage imageNamed:@"favourite_normal"] forState:UIControlStateNormal];
}

#pragma mark OnClick

-(IBAction)onClickSearch:(id)sender
{
    if (_isPresentView == NO) {
        [self playWaterSound];
        _isPresentView = YES;
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
        [self mz_presentFormSheetController:[self makeMZFormSheetController:vc] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            NSLog(@"finish!!");
            _isPresentView = NO;
        }];
        [self.searchButton setBackgroundImage:[UIImage imageNamed:@"search_pressed"] forState:UIControlStateNormal];
        [[AiDataRequestManager shareInstance] requestReportWithString:[NSString stringWithFormat:@"%d",kReportTypeSearch] completion:nil];
    }
}

-(IBAction)onClickHistory:(id)sender
{
    if (_isPresentView == NO) {
        [self playWaterSound];
        _isPresentView = YES;
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"history"];
        [self mz_presentFormSheetController:[self makeMZFormSheetController:vc] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            _isPresentView = NO;
        }];
        
        [self.historyButton setBackgroundImage:[UIImage imageNamed:@"history_pressed"] forState:UIControlStateNormal];
        [[AiDataRequestManager shareInstance] requestReportWithString:[NSString stringWithFormat:@"%d",kReportTypeHistory] completion:nil];
    }
}

-(IBAction)onClickSetting:(id)sender
{
    if (_isPresentView == NO) {
        [self playWaterSound];
        _isPresentView = YES;
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"setting"];
        [self mz_presentFormSheetController:[self makeMZFormSheetController:vc] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            _isPresentView = NO;
        }];
        
        [self.favouriteButton setBackgroundImage:[UIImage imageNamed:@"favourite_pressed"] forState:UIControlStateNormal];
        
        [[AiDataRequestManager shareInstance] requestReportWithString:[NSString stringWithFormat:@"%d",kReportTypeFavourite] completion:nil];
    }
}

-(IBAction)onClickFeedback:(id)sender
{
    if (_isPresentView == NO) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"plane" ofType:@"mp3"];
        NSURL *audioUrl = [[NSURL alloc] initFileURLWithPath:path];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        
        _isPresentView = YES;
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"feedback"];
        [self mz_presentFormSheetController:[self makeMZFormSheetController:vc] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            _isPresentView = NO;
        }];
        
        [[AiDataRequestManager shareInstance] requestReportWithString:[NSString stringWithFormat:@"%d",kReportTypeFeedback] completion:nil];
    }
}

-(void)setCurrentButton:(kTagButtonType)buttonType
{
    if (buttonType == kTagButtonTypeSong) {
        [self.catoonButton setBackgroundImage:[UIImage imageNamed:@"cartoon_normal"] forState:UIControlStateNormal];
        [self.videoButton setBackgroundImage:[UIImage imageNamed:@"play_normal"] forState:UIControlStateNormal];
        
        [self.songButton setBackgroundImage:[UIImage imageNamed:@"song_pressed"] forState:UIControlStateNormal];
    } else if (buttonType == kTagButtonTypeCatoon){
        [self.songButton setBackgroundImage:[UIImage imageNamed:@"song_normal"] forState:UIControlStateNormal];
        [self.videoButton setBackgroundImage:[UIImage imageNamed:@"play_normal"] forState:UIControlStateNormal];
        
        [self.catoonButton setBackgroundImage:[UIImage imageNamed:@"cartoon_pressed"] forState:UIControlStateNormal];
    } else if (buttonType == kTagButtonTypeVideo){
        [self.songButton setBackgroundImage:[UIImage imageNamed:@"song_normal"] forState:UIControlStateNormal];
        [self.catoonButton setBackgroundImage:[UIImage imageNamed:@"cartoon_normal"] forState:UIControlStateNormal];
        
        [self.videoButton setBackgroundImage:[UIImage imageNamed:@"play_pressed"] forState:UIControlStateNormal];
    }
}

-(IBAction)onClickButton:(UIButton *)sender
{
    [self playWaterSound];
    _currentType = (int)sender.tag;
    _isOnClickButton = YES;
    [self setCurrentButton:_currentType];
    [self.swipeview scrollToItemAtIndex:_currentType duration:0.5];
    
    [[AiDataRequestManager shareInstance] requestReportWithString:[NSString stringWithFormat:@"%d",_currentType] completion:nil];
}

-(IBAction)onClickSun:(id)sender
{
    [AiAudioManager play:@"sun"];
}

-(IBAction)onClickBaby:(id)sender
{
    [AiAudioManager play:@"baby"];
}

-(IBAction)onClickTree:(id)sender
{
    [AiAudioManager play:@"tree"];
}

-(IBAction)onClickBee:(id)sender
{
    [AiAudioManager play:@"bee"];
}

-(IBAction)onclickBirds:(id)sender
{
    [AiAudioManager play:@"birds"];
}

-(IBAction)onClickFlowers:(id)sender
{
    [AiAudioManager play:@"flower"];
}

#pragma mark Audio Sound
-(void)playWaterSound
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"water" ofType:@"mp3"];
    NSURL *audioUrl = [[NSURL alloc] initFileURLWithPath:path];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
