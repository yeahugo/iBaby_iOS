//
//  AiAlbumViewController.h
//  iBaby
//
//  Created by yeahugo on 14-5-17.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiScrollView.h"
#import "AiVideoObject.h"
//#import "AiScrollViewController.h"

@interface AiAlbumViewController : UIViewController<AiScrollViewDelegate,EGORefreshTableHeaderDelegate>
//{
//    AiScrollViewController *_albumViewController;
//}

@property (nonatomic, copy) NSString *serialId;

@property (nonatomic, weak) IBOutlet UIView * backGroundView;

@property (nonatomic, weak) IBOutlet UITextView *serialTextView;

@property (nonatomic, weak) IBOutlet UILabel * serialLabel;

@property (nonatomic, weak) IBOutlet UILabel * sectionNumLabel;

@property (nonatomic, weak) IBOutlet UIImageView * serialImageView;

@property (nonatomic, weak) IBOutlet UIView * albumView;

@property (nonatomic, weak) IBOutlet UILabel * titleLabel;

@property (nonatomic, strong) AiScrollView *scrollView;

@property (nonatomic, strong) AiVideoObject *videoObject;

@property (nonatomic, assign) int startId;

-(IBAction)close:(id)sender;

-(IBAction)playVideo:(id)sender;
@end
