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
            [self.serialDescriptionLabel setText:resourceInfo.serialDes];
            [self.sectionNumLabel setText:[NSString stringWithFormat:@"%d首",resourceInfo.sectionNum]];
            [self.titleLabel setText:resourceInfo.serialName];
            UMImageView *imageView = [[UMImageView alloc] initWithFrame:self.serialImageView.frame];
            [imageView setImageURL:[NSURL URLWithString:resourceInfo.img]];
            if (imageView.isCache) {
                self.serialImageView.image = imageView.image;
            } else {
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:resourceInfo.url]];
                UIImage *image = [UIImage imageWithData:data];
                self.serialImageView.image = image;
            }
            [_albumViewController.scrollView addSubview:_albumView];
        }
    }];
    _albumViewController.sourceType = kDataSourceTypeWeb;
    [self.view addSubview:_albumViewController.scrollView];    
}

-(IBAction)close:(id)sender
{
    AiFirstViewController  *rootViewController = (AiFirstViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootViewController closeSheetController];
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
