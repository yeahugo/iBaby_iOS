//
//  AiAlbumViewController.h
//  iBaby
//
//  Created by yeahugo on 14-5-17.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiScrollViewController.h"

@interface AiAlbumViewController : UIViewController
{
    AiScrollViewController *_albumViewController;
}

@property (nonatomic, copy) NSString *serialId;

@property (nonatomic, assign) IBOutlet UIView * backGroundView;

@property (nonatomic, assign) IBOutlet UILabel * serialDescriptionLabel;

@property (nonatomic, assign) IBOutlet UILabel * sectionNumLabel;

@property (nonatomic, assign) IBOutlet UIImageView * serialImageView;

@property (nonatomic, assign) IBOutlet UIView * albumView;

@property (nonatomic, assign) IBOutlet UILabel * titleLabel;

-(IBAction)close:(id)sender;

@end
