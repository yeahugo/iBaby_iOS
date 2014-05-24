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
    _albumViewController = [[AiScrollViewController alloc] initWithFrame:self.backGroundView.frame serialId:self.serialId completion:^(NSArray *resultArray, NSError *error) {
        if (error == nil) {
            ResourceInfo *resourceInfo = [resultArray objectAtIndex:0];
            self.videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
            NSMutableString *serialDescription = [[NSMutableString alloc] init];
            if (resourceInfo.serialDes.length > 0) {
                [serialDescription appendString:resourceInfo.serialDes];
            }
            [self.serialDescriptionLabel setText:serialDescription];
            [self.sectionNumLabel setText:[NSString stringWithFormat:@"%d首",resourceInfo.sectionNum]];
            [self.titleLabel setText:resourceInfo.serialName];
            
            CGSize labelSize = self.serialDescriptionLabel.frame.size;
            UIFont *font = [UIFont fontWithName:@"Helvetica" size:16];
            CGSize newLabelSize = [self.serialDescriptionLabel.text sizeWithFont:font constrainedToSize:labelSize lineBreakMode:self.serialDescriptionLabel.lineBreakMode];
            self.serialDescriptionLabel.frame = CGRectMake(self.serialDescriptionLabel.frame.origin.x, self.serialDescriptionLabel.frame.origin.y, newLabelSize.width, newLabelSize.height);
            
            UMImageView *imageView = [[UMImageView alloc] initWithFrame:self.serialImageView.frame];
            [imageView setImageURL:[NSURL URLWithString:resourceInfo.img]];
            if (imageView.isCache) {
                self.serialImageView.image = imageView.image;
            } else {
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:resourceInfo.url]];
                UIImage *image = [UIImage imageWithData:data];
                self.serialImageView.image = image;
            }
            self.serialImageView.layer.cornerRadius = 6;
            self.serialImageView.layer.masksToBounds = YES;
            [_albumViewController.scrollView addSubview:_albumView];
        }
    }];
    _albumViewController.sourceType = kDataSourceTypeWeb;
    [self.view addSubview:_albumViewController.scrollView];    
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
