//
//  AiHistoryViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiGridViewController.h"

@interface AiHistoryViewController : UIViewController
{
    AiGridViewController *_historyViewController;
}

@property (nonatomic, assign) IBOutlet UIView *backGroundView;

@end
