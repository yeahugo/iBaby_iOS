//
//  AiScrollViewCell.m
//  iBaby
//
//  Created by yeahugo on 14-6-23.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiScrollViewCell.h"
#import "shy.h"
#import "AFNetworking.h"
#import "AiWaitingView.h"
#import "AiFirstViewController.h"
#import "UMImageView.h"
#import "AiDataRequestManager.h"

@implementation AiScrollViewCell

-(id)initWithVideoResource:(ResourceInfo *)resourceInfo
{
    self = [super init];
    if (self) {
        self.resourceInfo = resourceInfo;
    }
    return self;
}

//-(id)initWithVideoObject:(AiVideoObject *)videoObject
//{
//    self = [super init];
//    if (self) {
//        _aiVideoObject = [[AiVideoObject alloc] init];
//        self.aiVideoObject = [videoObject copy];
//        NSLog(@"resource is %d",self.aiVideoObject.resourceType);
//    }
//    return self;
//}

-(id)initWithFrame:(CGRect)frame cellType:(kViewCellType)viewCellType
{
    self = [super initWithFrame:frame];
    if (self) {
        if (viewCellType == kViewCellTypeNormal) {
            UIImageView *frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edge_background_low.png"]];
            [self addSubview:frameImageView];
            self.backgroundView = frameImageView;
        }
        self.backgroundColor = [UIColor clearColor];
        self.viewCellType = viewCellType;
        
        if (viewCellType == kViewCellTypeHot || viewCellType == kViewCellTypeRecommend) {
            CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            UIButton *imageButton_ = [[UIButton alloc] initWithFrame:rect];
            self.imageButton = imageButton_;
            [imageButton_ addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.imageButton];
            
            CGRect backGroundRect = CGRectMake(0, rect.size.height - 25, rect.size.width, 25);
            if (viewCellType == kViewCellTypeHot) {
                UIImageView *textBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greybar_long"]];
                textBackgroundView.frame = CGRectMake(0, rect.size.height - textBackgroundView.frame.size.height, textBackgroundView.frame.size.width, textBackgroundView.frame.size.height);
                [self addSubview:textBackgroundView];
            } else {
                UIImageView *textBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greybar_short"]];
                textBackgroundView.frame = CGRectMake(0, rect.size.height - textBackgroundView.frame.size.height, textBackgroundView.frame.size.width, textBackgroundView.frame.size.height);
                [self addSubview:textBackgroundView];
            }
            
            CGRect labelRect = CGRectMake(20, backGroundRect.origin.y - 3, backGroundRect.size.width , backGroundRect.size.height);
            UILabel *label_ = [[UILabel alloc] initWithFrame:labelRect];
            label_.font = [UIFont systemFontOfSize:18];
            label_.backgroundColor = [UIColor clearColor];
            [label_ setTextColor:[UIColor whiteColor]];
            self.titleLabel = label_;
            [self addSubview:self.titleLabel];
            
        } else if(viewCellType == kViewCellTypeNormal) {
            CGRect rect = CGRectMake(1, 1, self.frame.size.width - 4, 122);
            UIButton *imageButton_ = [[UIButton alloc] initWithFrame:rect];
            self.imageButton = imageButton_;
            [imageButton_ addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.imageButton];
            
            CGRect labelRect = CGRectMake(16, rect.size.height , rect.size.width - 16, 45);
            UILabel *label_ = [[UILabel alloc] initWithFrame:labelRect];
            label_.numberOfLines = 2;
            label_.font = [UIFont systemFontOfSize:16];
            label_.backgroundColor = [UIColor clearColor];
            [label_ setTextColor:[UIColor whiteColor]];
            self.titleLabel = label_;
            [self addSubview:self.titleLabel];
        } else if (viewCellType == kViewCellTypeSearchRecommend){
            CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            UIButton *imageButton_ = [[UIButton alloc] initWithFrame:rect];
            self.imageButton = imageButton_;
            [self.imageButton addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.imageButton];
        }
        [self.imageButton setImage:[UIImage imageNamed:@"no_picture"] forState:UIControlStateNormal];
        
        //        _aiVideoObject = [[AiVideoObject alloc] init];
    }
    return self;
}

-(void)setHightLightScrollViewCell
{
    self.backgroundView.image = [UIImage imageNamed:@"current edge background_low"];
}

-(void)onClickButton:(UIButton *)button
{
    //    NSLog(@"vid is %@ sourceType is %d videoType is %d serialId is %@ url is %@",self.aiVideoObject.vid,self.aiVideoObject.sourceType,self.aiVideoObject.videoType,self.aiVideoObject.serialId,self.aiVideoObject.playUrl);
    
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [AiWaitingView addNoNetworkTip];
        return;
    }
    
    if (self.viewCellType == kViewCellTypeSearchRecommend) {
        UITextField *textField = (UITextField *)[self.superview.superview viewWithTag:50];
        [textField resignFirstResponder];
    }
    AiVideoObject *videoObject = [[AiVideoObject alloc] initWithResourceInfo:self.resourceInfo];
    if (![self.resourceInfo.serialId isEqualToString:@"0"]  && self.scrollView.viewType == kTagViewTypeIndex) {
        AiFirstViewController *firstViewController = (AiFirstViewController *)[[UIApplication sharedApplication].delegate window].rootViewController;
        [firstViewController presentAlbumViewObject:videoObject];
    } else {
        [videoObject playVideo];
    }
}

-(void)reloadResourceInfo
{
    UMImageView *imageView = [[UMImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"icon"]];
    [imageView setImageURL:[NSURL URLWithString:self.resourceInfo.img]];
    
    if ( !imageView.isCache) {
        [[AiDataRequestManager shareInstance].queue addOperationWithBlock:^(void){
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.resourceInfo.img]];
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageButton setImage:nil forState:UIControlStateNormal];
                [self.imageButton setBackgroundImage:image forState:UIControlStateNormal];
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageButton setImage:nil forState:UIControlStateNormal];
            [self.imageButton setBackgroundImage:imageView.image forState:UIControlStateNormal];
        });
    }
    self.titleLabel.text = self.resourceInfo.title;
}

//-(void)setAiVideoObject:(AiVideoObject *)aiVideoObject
//{
//    //    _aiVideoObject = [aiVideoObject copy];
//    //    NSLog(@"set aivideo object is %d",_aiVideoObject.resourceType);
//    UMImageView *imageView = [[UMImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"icon"]];
//    [imageView setImageURL:[NSURL URLWithString:aiVideoObject.imageUrl]];
//    
//    if ( !imageView.isCache) {
//        [[AiDataRequestManager shareInstance].queue addOperationWithBlock:^(void){
//            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aiVideoObject.imageUrl]];
//            UIImage *image = [UIImage imageWithData:imageData];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.imageButton setImage:nil forState:UIControlStateNormal];
//                [self.imageButton setBackgroundImage:image forState:UIControlStateNormal];
//            });
//        }];
//    } else {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.imageButton setImage:nil forState:UIControlStateNormal];
//            [self.imageButton setBackgroundImage:imageView.image forState:UIControlStateNormal];
//        });
//    }
//    self.titleLabel.text = aiVideoObject.title;
//}

@end
