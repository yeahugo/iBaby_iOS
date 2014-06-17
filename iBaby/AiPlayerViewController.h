//
//  JGPlayerViewController.h
//  FourPlayer
//
//  Created by yeahugo on 14-3-13.
//  Copyright (c) 2014年 AiJingang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiVideoObject.h"
#import <MediaPlayer/MediaPlayer.h>

@class AiPlayerViewController;

@interface AiPlayerViewControl : UIView

@property (nonatomic, strong) UIView *videoListView;

@property (nonatomic, strong) IBOutlet UISlider *slider;

@property (nonatomic, weak) AiPlayerViewController *playerViewController;

@property (nonatomic, weak) IBOutlet UILabel *currentTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *totalTimeLabel;

@property (nonatomic, weak) IBOutlet UIButton *volumn_button;

@property (nonatomic, weak) IBOutlet UISlider *volumn_slider;

@property (nonatomic, weak) IBOutlet UIButton *likeButton;

+(AiPlayerViewControl *)makePlayerViewControl;


@end

@interface AiPlayerViewController : MPMoviePlayerViewController
<UIGestureRecognizerDelegate>
{
    NSTimer *_timer;
}

@property (nonatomic, strong) NSArray *videoArray;

@property (nonatomic, strong) AiPlayerViewControl *playControlView;

@property (nonatomic, strong) MPMoviePlayerController *playerController;

@property (nonatomic, strong) UIView *webView;

@property (nonatomic, assign) float volume;

@property (nonatomic, unsafe_unretained) BOOL isLike;

@property (nonatomic, assign) BOOL isOnVolumn;

-(IBAction)onClickClose:(id)sender;

-(IBAction)onClickLike:(id)sender;

-(IBAction)onClickPlay:(id)sender;

-(IBAction)onClickSelectVideos:(UIButton *)button;

-(IBAction)onClickVolumn:(id)sender;

-(void)playVideoAtSection:(int)section;

@end
