//
//  ViewController.m
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiFirstViewController.h"
#import "AiGridView.h"
#import "AiVideoObject.h"
#import "AiDefine.h"
#import "AiDataManager.h"

@interface AiFirstViewController ()
{
    AiDataManager *_dataManager;
}
@end

@implementation AiFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
    [self getVideoDatas];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)setUI
{
    self.songButton.tag = kTagButtonTypeSong;
    self.catoonButton.tag = kTagButtonTypeCatoon;
    self.videoButton.tag = kTagButtonTypeVideo;
    
    AiGridView *songGridView_ = [[AiGridView alloc] initWithFrame:self.backgroundView.frame];
    songGridView_.tag = kTagButtonTypeSong;
    self.songGridView = songGridView_;
    
    AiGridView *catoonGridView_ = [[AiGridView alloc] initWithFrame:self.backgroundView.frame];
    catoonGridView_.tag = kTagButtonTypeCatoon;
    self.catoonGridView = catoonGridView_;
    
    AiGridView *videoGridView_ = [[AiGridView alloc] initWithFrame:self.backgroundView.frame];
    videoGridView_.tag = kTagButtonTypeVideo;
    self.videoGridView = videoGridView_;
    
    [self.view addSubview:self.catoonGridView];
    [self.view addSubview:self.videoGridView];
    [self.view addSubview:self.songGridView];
}

-(void)saveVideoObjects:(NSArray *)resultArray saveArray:(NSMutableArray *)saveArray error:(NSError *)error
{
    if (error == nil) {
        for (int i = 0; i < resultArray.count; i++) {
            AiVideoObject *videoObject = [[AiVideoObject alloc] init];
            ResourceInfo *resourceInfo = [resultArray objectAtIndex:i];
            videoObject.title = resourceInfo.title;
            videoObject.imageUrl = resourceInfo.img;
            videoObject.vid = resourceInfo.url;
            videoObject.sourceType = resourceInfo.resourceType;
            [saveArray addObject:videoObject];
        }
    } else{
        NSLog(@"error is %@",error);
    }
}

-(void)getVideoDatas
{
    _dataManager = [[AiDataManager alloc] initWithBabyId:123123];
    NSMutableArray *songArray = [NSMutableArray array];
    NSMutableArray *catoonArray = [NSMutableArray array];
    NSMutableArray *videoArray = [NSMutableArray array];
    [_dataManager searchWithKeyWords:@"儿歌" completion:^(NSArray *resultArray ,NSError *error){
        [self saveVideoObjects:resultArray saveArray:songArray error:error];
    }];
    
    [_dataManager searchWithKeyWords:@"动画" completion:^(NSArray *resultArray ,NSError *error){
        [self saveVideoObjects:resultArray saveArray:catoonArray error:error];
    }];
    
    [_dataManager searchWithKeyWords:@"视频" completion:^(NSArray *resultArray ,NSError *error){
        [self saveVideoObjects:resultArray saveArray:videoArray error:error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.songGridView setVideoObjects:songArray];
            [self.catoonGridView setVideoObjects:catoonArray];
            [self.videoGridView setVideoObjects:videoArray];
        });
    }];
}

-(IBAction)onClickButton:(UIButton *)sender
{
    switch (sender.tag) {
        case kTagButtonTypeSong:
        {
            NSLog(@"song click!!");
            [self.view bringSubviewToFront:self.songGridView];
            break;
        }
        case kTagButtonTypeCatoon:
        {
            NSLog(@"catoon click!!");
            [self.view bringSubviewToFront:self.catoonGridView];
            break;
        }
        case kTagButtonTypeVideo:
        {
            NSLog(@"video click!!");
            [self.view bringSubviewToFront:self.videoGridView];
            break;
        }
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
