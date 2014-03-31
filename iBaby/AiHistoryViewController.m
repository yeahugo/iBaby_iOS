//
//  AiHistoryViewController.m
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiHistoryViewController.h"
#import "AiDataBaseManager.h"
#import "AiGridView.h"

@interface AiHistoryViewController ()

@end

@implementation AiHistoryViewController

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
    AiGridView * gridView = [[AiGridView alloc] initWithFrame:self.backGroundView.frame];
    gridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gridView];

    [[AiDataBaseManager shareInstance] getVideoListsWithCompletion:^(NSArray *videoList, NSError *error) {
        if (error == nil) {
            [gridView setVideoObjects:videoList];
        } else {
            NSLog(@"getVideoList error is %@",error);
        }
    }];
    // Do any additional setup after loading the view.
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
