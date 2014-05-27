//
//  AiFeedbackViewController.m
//  iBaby
//
//  Created by yeahugo on 14-5-25.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiFeedbackViewController.h"
#import "AiFirstViewController.h"

@interface AiFeedbackViewController ()

@end

@implementation AiFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)closeFeedback:(id)sender
{
    NSLog(@"closeFeedback!!");
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
