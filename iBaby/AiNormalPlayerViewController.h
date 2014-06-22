//
//  JGPlayerViewController.h
//  FourPlayer
//
//  Created by yeahugo on 14-3-13.
//  Copyright (c) 2014年 AiJingang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiVideoObject.h"
#import "AiPlayerViewController.h"

@interface AiNormalPlayerViewController : AiPlayerViewController
<UIGestureRecognizerDelegate>

@property (nonatomic, strong) AiPlayerViewControl *playControlView;

@property(nonatomic, strong) MPMoviePlayerController *moviePlayer;

-(IBAction)onClickClose:(id)sender;

-(IBAction)onClickPlay:(id)sender;

-(IBAction)onClickVolumn:(id)sender;

-(void)playVideoAtSection:(int)section;
@end
