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
#import "AiDataRequestManager.h"
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
    [self.sectionNumLabel setText:[NSString stringWithFormat:@"%d",self.videoObject.totalSectionNum]];
    [self.titleLabel setText:self.videoObject.serialTitle];
    if (self.videoObject.serialDes.length > 0) {
        [self.serialTextView setText:self.videoObject.serialDes];
    }
    
    UMImageView *imageView = [[UMImageView alloc] initWithFrame:self.serialImageView.frame];
    [imageView setImageURL:[NSURL URLWithString:self.videoObject.imageUrl]];
    if (imageView.isCache) {
        self.serialImageView.image = imageView.image;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{

            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.videoObject.imageUrl]];
            UIImage *image = [UIImage imageWithData:data];
            self.serialImageView.image = image;
            [self.serialImageView setNeedsDisplay];
        });
    }
    
    self.serialImageView.layer.cornerRadius = 6;
    self.serialImageView.layer.masksToBounds = YES;
    
    _startId = 0;
    self.serialId = self.videoObject.serialId;
    [self getAlbumResource:self.serialId completion:nil];
    
    [AiWaitingView showInView:self.view];
}

-(void)getAlbumResource:(NSString *)serialId completion:(void (^)(NSArray *, NSError *))viewCompletion
{
    AiDataRequestManager *dataManager = [AiDataRequestManager shareInstance];
    [dataManager requestAlbumWithSerialId:serialId startId:_startId recordNum:SearchNum videoTitle:@"" completion:^(NSArray *resultArray, NSError *error) {
        [AiWaitingView dismiss];
        if (error == nil) {
            if (self.scrollView == nil) {
                AiScrollView *scrollView = [[AiScrollView alloc] initWithFrame:self.backGroundView.frame];
                [scrollView addSubview:self.albumView];
                scrollView.viewType = kTagViewTypeAlbum;
                scrollView.scrollViewDelegate = self;
                self.scrollView = scrollView;
                [self.view addSubview:self.scrollView];
            }
            _startId = _startId + (int)resultArray.count;
            [self.scrollView setAiVideoObjects:resultArray];
        }
        if (viewCompletion) {
            viewCompletion(resultArray,error);
        }
    }];
}

#pragma mark AiScrollViewDelegate
-(int)scrollViewReload
{
    int cellOffSetY = 190;
    return cellOffSetY;
}

-(NSArray *)showVideoArray:(NSArray *)videoArray
{
    return videoArray;
}

-(void)getMoreData:(int)num
{
    [[AiDataRequestManager shareInstance] requestAlbumWithSerialId:self.serialId startId:_startId recordNum:SearchNum videoTitle:@"" completion:^(NSArray *resultArray, NSError *error) {
        if (error == nil) {
            _startId = _startId + resultArray.count;
            [self.scrollView addAiVideoObjects:resultArray];
            
            if (resultArray.count == SearchNum) {
                EGORefreshTableHeaderView * egoFooterView = self.scrollView.egoFooterView;
                egoFooterView.center = CGPointMake(egoFooterView.center.x, self.scrollView.contentSize.height + egoFooterView.frame.size.height/2);
            } else {
                self.scrollView.egoFooterView.hidden = YES;
            }
        }
    }];
}

-(BOOL)reloadEgoFooterView:(NSArray *)resourceInfos totalNum:(int)totalNum egoView:(EGORefreshTableHeaderView *)footView
{
    BOOL returnResult = NO;
    if (resourceInfos.count % totalNum == 0 && resourceInfos.count > 0) {
        footView.delegate = self;
        footView.center = CGPointMake(footView.center.x, self.scrollView.contentSize.height);
        [self.scrollView addSubview:footView];
        returnResult = YES;
    }
    return returnResult;
}

-(IBAction)playVideo:(id)sender
{
    [self.videoObject playVideo];
}

-(IBAction)close:(id)sender
{
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
//    AiFirstViewController  *rootViewController = (AiFirstViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
//    [rootViewController closeSheetController];
}

#pragma mark EgoHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerGetMore:(EGORefreshTableHeaderView*)view
{
    NSLog(@"egoRefreshTableHeaderDidTriggerGetMore !!");
    [self getMoreData:SearchNum];
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
