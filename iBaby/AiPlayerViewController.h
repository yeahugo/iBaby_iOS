//
//  AiPlayerViewController.h
//  iBaby
//
//  Created by yeahugo on 14-6-16.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AiVideoObject.h"

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

@property (nonatomic, weak) AiVideoObject *videoObject;

+(AiPlayerViewControl *)makePlayerViewControl:(AiVideoObject *)videoObject;


@end

@interface AiPlayerViewController : UIViewController

@property (nonatomic, strong) AiPlayerViewControl *playControlView;

//@property (nonatomic, assign) BOOL isLike;

@property (nonatomic, assign) BOOL isPlay;

@property (nonatomic, assign) BOOL isOnVolumn;

@property (nonatomic, assign) float volume;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSArray *videoArray;

@property (nonatomic, strong) AiVideoObject *videoObject;

-(IBAction)onClickSelectVideos:(UIButton *)button;

-(id)initWithAiVideoObject:(AiVideoObject *)videoObject;
//- (id)initWithContentURL:(NSURL *)url;
@end
