//
//  AiBackgroundView.m
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiGridView.h"
#import "AiPlayerViewController.h"
#import "AppDelegate.h"
#import "UMImageView.h"
#import "AiVideoPlayerManager.h"

@implementation AiGridViewCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CGRect rect = CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10);
        UIButton *imageButton_ = [[UIButton alloc] initWithFrame:rect];
        self.imageButton = imageButton_;
        [imageButton_ addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.imageButton];
        
        CGRect frameRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        UIImageView *frameImageView = [[UIImageView alloc] initWithFrame:frameRect];
        frameImageView.image = [UIImage imageNamed:@"item_normal"];
        [self addSubview:frameImageView];
        
        CGRect labelRect = CGRectMake(20, rect.size.height + 10, rect.size.width, 30);
        UILabel *label_ = [[UILabel alloc] initWithFrame:labelRect];
        label_.font = [UIFont systemFontOfSize:12];
        label_.backgroundColor = [UIColor clearColor];
        self.titleLabel = label_;
        [self addSubview:self.titleLabel];
        
        _aiVideoObject = [[AiVideoObject alloc] init];
    }
    return self;
}

-(void)onClickButton:(UIButton *)button
{
    NSLog(@"vid is %@ sourceType is %d",self.aiVideoObject.vid,self.aiVideoObject.sourceType);
    [self.aiVideoObject getSongUrlWithCompletion:^(NSString *urlString,NSError *error){
        if (error == nil) {
            AiPlayerViewController *playViewController = [[AiPlayerViewController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
            [AiVideoPlayerManager shareInstance].aiPlayerViewController = playViewController;
            [AiVideoPlayerManager shareInstance].currentVideoObject = self.aiVideoObject;
            UIApplication *shareApplication = [UIApplication sharedApplication];
            [shareApplication.keyWindow.rootViewController presentMoviePlayerViewControllerAnimated:playViewController];
//            [shareApplication.keyWindow.rootViewController presentModalViewController:playViewController animated:YES];
        } else {
            NSLog(@"error is %@",error);
        }
    }];
}

-(void)setAiVideoObject:(AiVideoObject *)aiVideoObject
{
    self.aiVideoObject.title = aiVideoObject.title;
    self.aiVideoObject.imageUrl = aiVideoObject.imageUrl;
    self.aiVideoObject.vid = aiVideoObject.vid;
    self.aiVideoObject.sourceType = aiVideoObject.sourceType;
    UMImageView *imageView = [[UMImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"20090706065940.gif"]];
    [imageView setImageURL:[NSURL URLWithString:aiVideoObject.imageUrl]];
    if ( !imageView.isCache) {
        [self.gridView.queue addOperationWithBlock:^(void){
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aiVideoObject.imageUrl]];
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageButton setImage:image forState:UIControlStateNormal];
            });
        }];
    } else {
        [self.imageButton setBackgroundImage:imageView.image forState:UIControlStateNormal];
    }
    self.titleLabel.text = aiVideoObject.title;
    [self setNeedsDisplay];
}

@end


@implementation AiGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
//        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 1.1);
//        self.showsVerticalScrollIndicator = NO;
//        
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueArrow.png"]];
//        self.footerArrowView = imageView;
//        self.footerArrowView.hidden = YES;
//        self.footerArrowView.tag = 0;
//        self.footerArrowView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height);
//        [self addSubview:self.footerArrowView];
//        NSLog(@"frame is %@",NSStringFromCGRect(self.frame));
//
//        UIImage *arrowImage = [UIImage imageNamed:@"blueArrow.png"];
//        UIImageView *headerView = [[UIImageView alloc] initWithImage:arrowImage];
//        self.headerArrowView = headerView;
//        self.headerArrowView.center = CGPointMake(self.frame.size.width/2, 0);
//        self.headerArrowView.transform = CGAffineTransformMakeScale(1.0,-1.0);
//        self.headerArrowView.tag = 1;
//        [self addSubview:self.headerArrowView];
//        self.headerArrowView.hidden = YES;
        
        NSOperationQueue * queue = [[NSOperationQueue alloc] init];
        self.queue = queue;
    }
    return self;
}

-(void)setVideoObjects:(NSArray *)videoObjects
{
    for (UIView *subView in self.subviews) {
        if (subView.tag > 3) {
            [subView removeFromSuperview];
        }
    }
    self.videoDatas = videoObjects;
    [self setNeedsDisplay];
}

-(AiGridViewCell *)gridViewCellWithIndex:(int)index
{
    int colNum = ColNum;
    int rowNum = RowNum;
    CGSize size = CGSizeMake(180, 135);
    int startX = 0;
    int startY = 0;
    int deltaX = (self.frame.size.width)/colNum;
    int deltaY = (self.frame.size.height)/rowNum;
    AiGridViewCell *cell = nil;
    if ([self viewWithTag:index + kTagVideoCellStartIndex]) {
        cell = (AiGridViewCell *)[self viewWithTag:index + kTagVideoCellStartIndex];
    } else {
        cell = [[AiGridViewCell alloc] initWithFrame:CGRectMake(startX + (index%colNum)*deltaX, startY+(index/colNum)*deltaY, size.width, size.height)];
        cell.gridView = self;
        cell.tag = index + kTagVideoCellStartIndex;
        [self addSubview:cell];
    }

    return cell;
}

-(void)transFormArrow:(UIImageView *)imageView
{
    [NSClassFromString(@"CATransaction") begin];
    [NSClassFromString(@"CATransaction") setAnimationDuration:0.18f];
    [NSClassFromString(@"CATransaction") setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    imageView.layer.transform = CATransform3DIdentity;
    CATransform3D footTransform = {-1,0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    [imageView.layer setTransform:footTransform];
    
    [NSClassFromString(@"CATransaction") commit];
}

-(void)recover:(UIImageView *)imageView
{
    [NSClassFromString(@"CATransaction") begin];
    [NSClassFromString(@"CATransaction") setAnimationDuration:0.18f];
    imageView.layer.transform = CATransform3DIdentity;
    [NSClassFromString(@"CATransaction") commit];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    for (int i = 0; i<[self.videoDatas count]; i++) {
        AiGridViewCell *cell = [self gridViewCellWithIndex:i];
        cell.aiVideoObject = [self.videoDatas objectAtIndex:i];
    }
}

@end

@implementation AiSwipeView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.vertical = YES;
        [self setScrollOffset:1];
        [self scrollToItemAtIndex:0 duration:0.2];
    }
    return self;
}

-(AiGridView *)gridView
{
    return (AiGridView *)self.currentItemView;
}

@end
