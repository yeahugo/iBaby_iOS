//
//  AiScrollView.m
//  iBaby
//
//  Created by yeahugo on 14-5-10.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiScrollView.h"
#import "AiPlayerViewController.h"
#import "AiVideoPlayerManager.h"
#import "UMImageView.h"
#import "AiScrollViewController.h"

@implementation AiScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _videoDatas = [[NSMutableArray alloc] init];
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)setAiVideoObjects:(NSArray *)aiVideoObjects
{
//    NSArray * views = [self subviews];
//    for (UIView * view in views) {
//        NSLog(@"view tag is %d",view.tag);
//        if (view.tag > 3) {
//            [view removeFromSuperview];
//        }
//    }
    [self.videoDatas addObjectsFromArray:aiVideoObjects];
    [self reloadData];
}

-(void)addAiVideoObjects:(NSArray *)aiVideoObjects
{
    int startIndex = self.videoDatas.count;
    [self.videoDatas addObjectsFromArray:aiVideoObjects];
    for (int i = startIndex; i<[self.videoDatas count]; i++) {
        AiScrollViewCell *cell = [self scrollCellWithIndex:i];
        cell.aiVideoObject = [self.videoDatas objectAtIndex:i];
    }
    
    int deltaHeight = ((float)aiVideoObjects.count/ColNum) * _cellHeight;
    [self setContentSize:CGSizeMake(self.frame.size.width, self.contentSize.height + deltaHeight)];
    if (aiVideoObjects.count == SearchNum) {
        _egoFooterView.center = CGPointMake(_egoFooterView.center.x, _egoFooterView.center.y + deltaHeight);
    } else {
        [_egoFooterView removeFromSuperview];
    }
}


-(void)reloadData
{
    self.delegate = self;
    if (self.videoDatas.count > 0) {
        NSLog(@"title is %@",[[self.videoDatas objectAtIndex:0] title]);
    }
    //测试专辑页面效果
    if (self.videoDatas.count > 0 && [[[self.videoDatas objectAtIndex:0] title] hasPrefix:@"The"]) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"AiAlbumView" owner:self options:nil];

        AiAlbumView *albumView = [nib objectAtIndex:0];
        albumView.tag = 2001;
        albumView.frame = CGRectMake(0, 100, albumView.frame.size.width, albumView.frame.size.height);
        [self.superview addSubview:albumView];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + albumView.frame.size.height - 100, self.frame.size.width, self.frame.size.height);
    }
    //测试首页效果
    _cellOffSet = 0;
    if (self.videoDatas.count && [[[self.videoDatas objectAtIndex:0] title] hasPrefix:@"儿歌"]) {
        SwipeView *bannerView = [[SwipeView alloc] initWithFrame:CGRectMake(100, 0, 500, 250)];
        bannerView.dataSource = self;
        [self addSubview:bannerView];
        _cellOffSet = 250;
    }
    _cellHeight = 0;
    for (int i = 0; i<[self.videoDatas count]; i++) {
        AiScrollViewCell *cell = [self scrollCellWithIndex:i];
        cell.aiVideoObject = [self.videoDatas objectAtIndex:i];
        _cellHeight = cell.frame.size.height + 10;
    }
    float height = (self.videoDatas.count / ColNum) * _cellHeight + _cellOffSet;
    [self setContentSize:CGSizeMake(self.frame.size.width, height)];
    
    if (self.videoDatas.count % SearchNum == 0 && self.videoDatas.count > 0) {
        _egoFooterView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, self.contentSize.height, self.frame.size.width, 60)];
        _egoFooterView.delegate = self;
        [self addSubview:_egoFooterView];
    }
}


-(AiScrollViewCell *)scrollCellWithIndex:(int)index
{
    CGSize size = CGSizeMake(200, 190);
    int startX = 0;
    int startY = 0;
    int colNum = 4;
    
    int deltaX = 0;
    int deltaY = 0;
    
    AiScrollViewCell *cell = nil;
    
    if ([self viewWithTag:index + kTagVideoCellStartIndex]) {
        cell = (AiScrollViewCell *)[self viewWithTag:index + kTagVideoCellStartIndex];
    } else {
        cell = [[AiScrollViewCell alloc] initWithFrame:CGRectMake(startX + (size.width + deltaX)*(index%colNum), startY + (size.height+deltaY)*(index/colNum)+_cellOffSet, size.width, size.height)];
        cell.scrollView = self;
        cell.tag = index + kTagVideoCellStartIndex;
        [self addSubview:cell];
    }
    
    return cell;
}

#pragma EGOFooterView
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    NSLog(@"egoRefreshTableHeaderDidTriggerRefresh");
}

- (void)egoRefreshTableHeaderDidTriggerGetMore:(EGORefreshTableHeaderView*)view
{
    NSLog(@"egoRefreshTableHeaderDidTriggerGetMore");
    [self.scrollViewController getMoreData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return 0;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_egoFooterView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma SwipeDataSource
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return 3;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    AiScrollViewCell *scrollViewCell = nil;
    if (index == 0) {
        scrollViewCell = [[AiScrollViewCell alloc] initWithFrame:CGRectMake(120 * index, 0, 50, 50)];
    }
    if (index == 1) {
        scrollViewCell = [[AiScrollViewCell alloc] initWithFrame:CGRectMake(120 * index, 0, 150, 150)];
    }
    if (index == 2) {
        scrollViewCell = [[AiScrollViewCell alloc] initWithFrame:CGRectMake(300, 0, 50, 50)];
    }
    return scrollViewCell;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

@implementation AiAlbumView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

@end

@implementation AiScrollViewCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        CGRect frameRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        UIImageView *frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edge_background.png"]];
        [self addSubview:frameImageView];
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frameImageView.frame.size.width, frameImageView.frame.size.height);
        
        CGRect rect = CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 50);
        UIButton *imageButton_ = [[UIButton alloc] initWithFrame:rect];
        self.imageButton = imageButton_;
        [imageButton_ addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.imageButton];
        
        CGRect labelRect = CGRectMake(20, rect.size.height + 10, rect.size.width, 30);
        UILabel *label_ = [[UILabel alloc] initWithFrame:labelRect];
        label_.font = [UIFont systemFontOfSize:12];
        label_.backgroundColor = [UIColor clearColor];
        [label_ setTextColor:[UIColor whiteColor]];
        self.titleLabel = label_;
        [self addSubview:self.titleLabel];
        
        _aiVideoObject = [[AiVideoObject alloc] init];
    }
    return self;
}

-(void)onClickButton:(UIButton *)button
{
    NSLog(@"vid is %@ sourceType is %d videoType is %d",self.aiVideoObject.vid,self.aiVideoObject.sourceType,self.aiVideoObject.videoType);
    if (self.aiVideoObject.videoType == RESOURCE_TYPE_CARTOON) {
        AiPlayerViewController *playViewController = [[AiPlayerViewController alloc] initWithContentURL:[NSURL URLWithString:self.aiVideoObject.vid]];
        self.aiVideoObject.playUrl = self.aiVideoObject.vid;
        [AiVideoPlayerManager shareInstance].aiPlayerViewController = playViewController;
        [AiVideoPlayerManager shareInstance].currentVideoObject = self.aiVideoObject;
        UIApplication *shareApplication = [UIApplication sharedApplication];
        [shareApplication.keyWindow.rootViewController presentMoviePlayerViewControllerAnimated:playViewController];
    } else if (self.aiVideoObject.videoType == RESOURCE_TYPE_SONG) {
        [self.aiVideoObject getSongUrlWithCompletion:^(NSString *urlString,NSError *error){
            if (error == nil) {
                AiPlayerViewController *playViewController = [[AiPlayerViewController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
                [AiVideoPlayerManager shareInstance].aiPlayerViewController = playViewController;
                self.aiVideoObject.playUrl = urlString;
                [AiVideoPlayerManager shareInstance].currentVideoObject = self.aiVideoObject;
                UIApplication *shareApplication = [UIApplication sharedApplication];
                [shareApplication.keyWindow.rootViewController presentMoviePlayerViewControllerAnimated:playViewController];
            } else {
                NSLog(@"error is %@",error);
            }
        }];
    }
}

-(void)setAiVideoObject:(AiVideoObject *)aiVideoObject
{
    self.aiVideoObject.title = aiVideoObject.title;
    self.aiVideoObject.imageUrl = aiVideoObject.imageUrl;
    self.aiVideoObject.vid = aiVideoObject.vid;
    self.aiVideoObject.sourceType = aiVideoObject.sourceType;
    self.aiVideoObject.videoType = aiVideoObject.videoType;
    self.aiVideoObject.serialId = aiVideoObject.serialId;
    self.aiVideoObject.totalSectionNum = aiVideoObject.totalSectionNum;
    UMImageView *imageView = [[UMImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"icon"]];
    [imageView setImageURL:[NSURL URLWithString:aiVideoObject.imageUrl]];
    if ( !imageView.isCache) {
        [self.scrollView.queue addOperationWithBlock:^(void){
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aiVideoObject.imageUrl]];
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageButton setBackgroundImage:image forState:UIControlStateNormal];
                //                [self.imageButton setImage:image forState:UIControlStateNormal];
            });
        }];
    } else {
        [self.imageButton setBackgroundImage:imageView.image forState:UIControlStateNormal];
    }
    self.titleLabel.text = aiVideoObject.title;
    [self setNeedsDisplay];
}

@end
