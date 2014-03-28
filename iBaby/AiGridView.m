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

@implementation AiGridViewCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor blackColor];
        CGRect rect = CGRectMake(0, 0, frame.size.width - 20, frame.size.height - 20);
        UIButton *imageButton_ = [[UIButton alloc] initWithFrame:rect];
        self.imageButton = imageButton_;
        [imageButton_ addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.imageButton];
        
        CGRect labelRect = CGRectMake(0, rect.size.height, rect.size.width - 20, 30);
        UILabel *label_ = [[UILabel alloc] initWithFrame:labelRect];
        label_.font = [UIFont systemFontOfSize:12];
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
            AiPlayerViewController *aiPlayerViewController = [[AiPlayerViewController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
            UIApplication *shareApplication = [UIApplication sharedApplication];
            [shareApplication.keyWindow.rootViewController presentModalViewController:aiPlayerViewController animated:YES];
        } else {
            NSLog(@"error is %@",error);
        }
    }];
}

-(void)setAiVideoObject:(AiVideoObject *)aiVideoObject
{
    self.aiVideoObject.vid = aiVideoObject.vid;
    self.aiVideoObject.sourceType = aiVideoObject.sourceType;
//    UIImage *image = [UIImage imageNamed:aiVideoObject.imageUrl];
    UMImageView *imageView = [[UMImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"20090706065940.gif"]];
    [imageView setImageURL:[NSURL URLWithString:aiVideoObject.imageUrl]];
    if ( !imageView.isCache) {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aiVideoObject.imageUrl]];
        UIImage *image = [UIImage imageWithData:imageData];
        [self.imageButton setBackgroundImage:image forState:UIControlStateNormal];
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
        self.backgroundColor = [UIColor whiteColor];
        // Initialization code
    }
    return self;
}

-(void)setVideoObjects:(NSArray *)videoObjects
{
    self.videoDatas = videoObjects;
    [self setNeedsDisplay];
}

-(AiGridViewCell *)gridViewCellWithIndex:(int)index
{
    CGSize size = CGSizeMake(140, 140);
    int startX = 0;
    int startY = 0;
    int deltaX = size.width + 10;
    int deltaY = size.height + 10;
    int rowNum = 5;
    AiGridViewCell *returnCell = nil;
    if ([self viewWithTag:index + kTagVideoCellStartIndex]) {
        AiGridViewCell *cell = (AiGridViewCell *)[self viewWithTag:index];
        returnCell = cell;
    } else {
        AiGridViewCell *cell = [[AiGridViewCell alloc] initWithFrame:CGRectMake(startX + (index%rowNum)*deltaX, startY+(index/rowNum)*deltaY, size.width, size.height)];
        cell.tag = index + kTagVideoCellStartIndex;
        [self addSubview:cell];
        returnCell = cell;
    }

    return returnCell;
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
