//
//  JGPlayerViewController.h
//  FourPlayer
//
//  Created by yeahugo on 14-3-13.
//  Copyright (c) 2014年 AiJingang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class AiPlayerViewController;

@interface AiPlayerViewControl : UIView

@property (nonatomic, strong) UIView *videoListView;

@property (nonatomic, strong) IBOutlet UISlider *slider;

@property (nonatomic, assign) AiPlayerViewController *playerViewController;

@property (nonatomic, assign) IBOutlet UILabel *currentTimeLabel;

@property (nonatomic, assign) IBOutlet UILabel *totalTimeLabel;

@end

@interface AiPlayerViewController : MPMoviePlayerViewController
<UIGestureRecognizerDelegate>
{
    NSTimer *_timer;
}

@property (nonatomic, strong) AiPlayerViewControl *playControlView;

@property (nonatomic, unsafe_unretained) BOOL isLike;

-(IBAction)onClickClose:(id)sender;

-(IBAction)onClickLike:(id)sender;

-(IBAction)onClickPlay:(id)sender;

-(IBAction)onClickSelectVideos:(id)sender;

@end
