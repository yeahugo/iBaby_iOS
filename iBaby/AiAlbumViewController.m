//
//  AiAlbumViewController.m
//  iBaby
//
//  Created by yeahugo on 14-5-17.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiAlbumViewController.h"
#import "AiFirstViewController.h"
#import "UMImageView.h"
#import "AiVideoPlayerManager.h"
#import "AiWaitingView.h"
#import <QuartzCore/QuartzCore.h>

@interface AiAlbumViewController ()

@end

@implementation AiAlbumViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    self.videoObject = [AiVideoPlayerManager shareInstance].currentVideoObject;
    [self.sectionNumLabel setText:[NSString stringWithFormat:@"%d",self.videoObject.totalSectionNum]];
    [self.titleLabel setText:self.videoObject.serialTitle];
    if (self.videoObject.serialDes.length > 0) {
        [self.serialTextView setText:self.videoObject.serialDes];
    }
    
    self.serialImageView.layer.cornerRadius = 6;
    self.serialImageView.layer.masksToBounds = YES;
    
    _albumViewController = [[AiScrollViewController alloc] initWithFrame:self.backGroundView.frame serialId:self.videoObject.serialId completion:^(NSArray *resultArray, NSError *error) {
//        NSLog(@"result is %@",resultArray);
        [AiWaitingView dismiss];
        if (error == nil) {
            [_albumViewController.scrollView addSubview:_albumView];
            if (resultArray.count == 0) {
                return ;
            }
            ResourceInfo *resourceInfo = [resultArray objectAtIndex:0];
            self.videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
            UMImageView *imageView = [[UMImageView alloc] initWithFrame:self.serialImageView.frame];
            [imageView setImageURL:[NSURL URLWithString:resourceInfo.img]];
            if (imageView.isCache) {
                self.serialImageView.image = imageView.image;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:resourceInfo.img]];
                    UIImage *image = [UIImage imageWithData:data];
                    self.serialImageView.image = image;
//                     NSLog(@"set sericial image view image is %@",image);
                    [self.serialImageView setNeedsDisplay];
                });
            }
        }
    }];
    _albumViewController.sourceType = kDataSourceTypeWeb;
    [self.view addSubview:_albumViewController.scrollView];
    [AiWaitingView showInView:self.view];
}

-(IBAction)playVideo:(id)sender
{
    [self.videoObject playVideo];
}

-(IBAction)close:(id)sender
{
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
//    AiFirstViewController  *rootViewController = (AiFirstViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
//    [rootViewController closeSheetController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
