//
//  ViewController.m
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiFirstViewController.h"
#import "AiGridView.h"
#import "AiVideoObject.h"
#import "AiDefine.h"
#import "AiDataRequestManager.h"
#import "AiGridViewController.h"
#import "AiScrollViewController.h"

#import "MZFormSheetController.h"
#import "SwipeView.h"

@interface AiFirstViewController ()
{
    AiDataRequestManager *_dataManager;
    NSMutableArray *_songListArray;
//    AiGridViewController *_songViewController;
//    AiGridViewController *_catoonViewController;
//    AiGridViewController *_videoViewController;
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    _songViewController = [[AiScrollViewController alloc] initWithFrame:backGroundRect keyWords:@"儿歌"];
    _songViewController.videoType = kTagButtonTypeSong;
    _songViewController.sourceType = kDataSourceTypeWeb;
    self.songScrollView = _songViewController.scrollView;
    self.songScrollView.tag = kTagButtonTypeSong;
    _catoonViewController = [[AiScrollViewController alloc] initWithFrame:backGroundRect keyWords:@"卡通"];
    self.catoonScrollView = _catoonViewController.scrollView;
    self.catoonScrollView.tag = kTagButtonTypeCatoon;
    _catoonViewController.videoType = kTagButtonTypeCatoon;
    _catoonViewController.sourceType = kDataSourceTypeWeb;
    _videoViewController = [[AiScrollViewController alloc] initWithFrame:backGroundRect keyWords:@"节目"];
    self.videoScrollView = _videoViewController.scrollView;
    self.videoScrollView.tag = kTagButtonTypeVideo;
    _videoViewController.videoType = kTagButtonTypeVideo;
    _videoViewController.sourceType = kDataSourceTypeWeb;
    
    SwipeView *swipeView = [[SwipeView alloc] initWithFrame:backGroundRect];
    swipeView.delegate = self;
    swipeView.dataSource = self;
    swipeView.pagingEnabled = NO;
    swipeView.scrollEnabled = NO;
    self.swipeview = swipeView;
    [self.view addSubview:swipeView];
    [self setCurrentButton:_currentType];
    
    //下面的代码防止滑动过程出现左右偏移
    [self.swipeview setScrollOffset:1];
    [self.swipeview scrollToItemAtIndex:0 duration:0.5];
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
        showView = self.catoonScrollView;
    }
    if (index == 2) {
        showView = self.videoScrollView;
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

-(IBAction)onClickSearch:(id)sender
{
    if (_isPresentView == NO) {
        _isPresentView = YES;
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
        [self mz_presentFormSheetController:[self makeMZFormSheetController:vc] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            NSLog(@"finish!!");
            _isPresentView = NO;
        }];
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
    }
}

-(void)setCurrentButton:(kTagButtonType)buttonType
{
    if (buttonType == kTagButtonTypeSong) {
        [self.catoonButton setBackgroundImage:[UIImage imageNamed:@"cartoon_off"] forState:UIControlStateNormal];
        [self.videoButton setBackgroundImage:[UIImage imageNamed:@"tv_off"] forState:UIControlStateNormal];
        
        [self.songButton setBackgroundImage:[UIImage imageNamed:@"song"] forState:UIControlStateNormal];
    } else if (buttonType == kTagButtonTypeCatoon){
        [self.songButton setBackgroundImage:[UIImage imageNamed:@"song_off"] forState:UIControlStateNormal];
        [self.videoButton setBackgroundImage:[UIImage imageNamed:@"tv_off"] forState:UIControlStateNormal];
        
        [self.catoonButton setBackgroundImage:[UIImage imageNamed:@"cartoon"] forState:UIControlStateNormal];
    } else if (buttonType == kTagButtonTypeVideo){
        [self.songButton setBackgroundImage:[UIImage imageNamed:@"song_off"] forState:UIControlStateNormal];
        [self.catoonButton setBackgroundImage:[UIImage imageNamed:@"cartoon_off"] forState:UIControlStateNormal];
        
        [self.videoButton setBackgroundImage:[UIImage imageNamed:@"tv"] forState:UIControlStateNormal];
    }
}

-(IBAction)onClickButton:(UIButton *)sender
{
    _currentType = (int)sender.tag;
    _isOnClickButton = YES;
    [self setCurrentButton:_currentType];
    [self.swipeview scrollToItemAtIndex:_currentType duration:0.5];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
