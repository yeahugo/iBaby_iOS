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

#import "MZFormSheetController.h"
#import "SwipeView.h"

@interface AiFirstViewController ()
{
    AiDataRequestManager *_dataManager;
    NSMutableArray *_songListArray;
    AiGridViewController *_songViewController;
    AiGridViewController *_catoonViewController;
    AiGridViewController *_videoViewController;
    kTagButtonType _currentType;
    int _scrollNum;
}
@end

@implementation AiFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)setUI
{
    self.songButton.tag = kTagButtonTypeSong;
    self.catoonButton.tag = kTagButtonTypeCatoon;
    self.videoButton.tag = kTagButtonTypeVideo;
    
    CGRect backGroundRect = self.backgroundView.frame;
        
    _songViewController = [[AiGridViewController alloc] initWithFrame:backGroundRect keyWords:@"儿歌"];
    self.songGridView = _songViewController.gridView;
    self.songGridView.tag = kTagButtonTypeSong;
    _catoonViewController = [[AiGridViewController alloc] initWithFrame:backGroundRect keyWords:@"卡通"];
    self.catoonGridView = _catoonViewController.gridView;
    self.catoonGridView.tag = kTagButtonTypeCatoon;

    _videoViewController = [[AiGridViewController alloc] initWithFrame:backGroundRect keyWords:@"节目"];
    self.videoGridView = _videoViewController.gridView;
    self.videoGridView.tag = kTagButtonTypeVideo;
    SwipeView *swipeView = [[SwipeView alloc] initWithFrame:backGroundRect];
    swipeView.dataSource = self;
    swipeView.pagingEnabled = YES;
    self.swipeview = swipeView;
    [self.view addSubview:swipeView];
    
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return 3;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIView *showView = nil;
    if (index == 0) {
        showView = self.songGridView;
    }
    if (index == 1) {
        showView = self.catoonGridView;
    }
    if (index == 2) {
        showView = self.videoGridView;
    }
    return showView;
}

-(MZFormSheetController *)makeMZFormSheetController:(UIViewController *)viewController
{
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:viewController];
    
    formSheet.presentedFormSheetSize = CGSizeMake(self.backgroundView.frame.size.width + 50, self.backgroundView.frame.size.height);
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    return formSheet;
}

-(IBAction)onClickSearch:(id)sender
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];

    [self mz_presentFormSheetController:[self makeMZFormSheetController:vc] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
}

-(IBAction)onClickHistory:(id)sender
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"history"];
    [self mz_presentFormSheetController:[self makeMZFormSheetController:vc] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
}

-(IBAction)onClickSetting:(id)sender
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"setting"];
    [self mz_presentFormSheetController:[self makeMZFormSheetController:vc] animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
}

-(IBAction)onClickButton:(UIButton *)sender
{
    _currentType = (int)sender.tag;
    
    [self.swipeview scrollToItemAtIndex:_currentType duration:0.2];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
