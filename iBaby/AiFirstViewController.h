//
//  ViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiScrollView.h"
#import "SwipeView.h"
#import "MZFormSheetController.h"
#import <AVFoundation/AVFoundation.h>

@interface AiFirstViewController : UIViewController <SwipeViewDataSource,SwipeViewDelegate>

@property (nonatomic, assign) IBOutlet UIButton *songButton;

@property (nonatomic, assign) IBOutlet UIButton *catoonButton;

@property (nonatomic, assign) IBOutlet UIButton *videoButton;

@property (nonatomic, assign) IBOutlet UIView *backgroundView;

@property (nonatomic, strong) IBOutlet UIButton *historyButton;

@property (nonatomic, strong) IBOutlet UIButton *searchButton;

@property (nonatomic, strong) IBOutlet UIButton *favouriteButton;

@property (nonatomic, assign) UIButton *closeButton;

@property (nonatomic, strong) MZFormSheetController *formSheetController;

@property (nonatomic, strong) AiScrollView *songScrollView;

@property (nonatomic, strong) AiScrollView *catoonScrollView;

@property (nonatomic, strong) AiScrollView *videoScrollView;

@property (nonatomic, strong) SwipeView *swipeview;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

-(IBAction)onClickButton:(id)sender;

-(IBAction)onClickSearch:(id)sender;

-(IBAction)onClickHistory:(id)sender;

-(IBAction)onClickFeedback:(id)sender;

-(IBAction)onClickSun:(id)sender;

-(IBAction)onClickBee:(id)sender;

-(IBAction)onClickTree:(id)sender;

-(IBAction)onClickBaby:(id)sender;

-(IBAction)onClickPlane:(id)sender;

-(IBAction)onclickBirds:(id)sender;

-(void)presentAlbumViewObject:(AiVideoObject *)videoObject;

//-(void)presentAlbumViewController:(NSString *)serialId;

-(IBAction)closeSheetController;

-(void)resetButtons;
@end
