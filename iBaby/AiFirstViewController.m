//
//  ViewController.m
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiFirstViewController.h"
//#import "AiGridView.h"
#import "AiVideoObject.h"
#import "AiDefine.h"
#import "AiDataRequestManager.h"
//#import "AiGridViewController.h"
#import "AiScrollViewController.h"
#import "AiAlbumViewController.h"
#import "AiUserManager.h"

#import "MZFormSheetController.h"
#import "SwipeView.h"

#import "Reachability.h"

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

- (void)checkNetwork
{
    Reachability* reach = [Reachability reachabilityWithHostName:@"http://www.aijingang.com/"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    reach.reachableBlock = ^(Reachability*reach)
    {
        NSLog(@"REACHABLE!");
    };
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@"REACHABLE!");
    };
    [reach startNotifier];
}

-(void)reachabilityChanged:(NSNotification *)note{
    Reachability * reach = [note object];
    
    if(![reach isReachable])
    {
        return;
    }
    
    if (reach.isReachableViaWiFi) {
    } else {
    }
    
    if (reach.isReachableViaWWAN) {
    } else {
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkNetwork];
    [AiUserManager shareInstance];
    [self setUI];
    _isPresentView = NO;
    _isOnClickButton = NO;
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)setUI
{
    self.songButton.tag = kTagButtonTypeSong;
    self.catoonButton.tag = kTagButtonTypeCatoon;
    self.videoButton.tag = kTagButtonTypeVideo;
    
    CGRect backGroundRect = self.backgroundView.frame;
    
//    [AiUserManager shareInstance];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main background"]];
//    imageView.frame = backGroundRect;
//    [self.view addSubview:imageView];
    
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
    
//    [self.view addSubview:self.catoonScrollView];
    //下面的代码防止滑动过程出现左右偏移
//    [self.swipeview scrollToItemAtIndex:0 duration:0.5];
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

    formSheet.presentedFormSheetSize = CGSizeMake(self.backgroundView.frame.size.width + 80, self.backgroundView.frame.size.height+ 50);
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    return formSheet;
}

-(void)presentAlbumViewController:(NSString *)serialId
{
    if (_isPresentView == NO) {
        _isPresentView = YES;
        AiAlbumViewController *albumViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"album"];
        albumViewController.serialId = serialId;
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

-(IBAction)onClickSearch:(id)sender
{
    if (_isPresentView == NO) {
        _isPresentView = YES;
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
        [self mz_presentFormSheetController:[self makeMZFormSheetController:vc] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            NSLog(@"finish!!");
            _isPresentView = NO;
        }];
        [self.searchButton setBackgroundImage:[UIImage imageNamed:@"search_pressed"] forState:UIControlStateNormal];
    }
}

-(IBAction)onClickHistory:(id)sender
{
    if (_isPresentView == NO) {
        _isPresentView = YES;
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"history"];
        [self mz_presentFormSheetController:[self makeMZFormSheetController:vc] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            _isPresentView = NO;
        }];
        
        [self.historyButton setBackgroundImage:[UIImage imageNamed:@"history_pressed"] forState:UIControlStateNormal];
    }
}

-(IBAction)onClickSetting:(id)sender
{
    if (_isPresentView == NO) {
        _isPresentView = YES;
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"setting"];
        [self mz_presentFormSheetController:[self makeMZFormSheetController:vc] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            _isPresentView = NO;
        }];
        
        [self.favouriteButton setBackgroundImage:[UIImage imageNamed:@"favourite_pressed"] forState:UIControlStateNormal];
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
    _currentType = (int)sender.tag;
    _isOnClickButton = YES;
    [self setCurrentButton:_currentType];
    [self.swipeview scrollToItemAtIndex:_currentType duration:0.5];
    
    [[AiDataRequestManager shareInstance] requestReportWithString:[NSString stringWithFormat:@"%d",_currentType] completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
