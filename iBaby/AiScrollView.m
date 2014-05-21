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
#import "AiBannerView.h"
#import "AiScrollViewController.h"
#import "AiFirstViewController.h"

@implementation AiScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _videoDatas = [[NSMutableArray alloc] init];
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)setAiVideoObjects:(NSArray *)aiVideoObjects
{
    [self.videoDatas removeAllObjects];
    [self.videoDatas addObjectsFromArray:aiVideoObjects];
    [self reloadData];
    
    if (self.videoDatas.count % SearchNum == 0 && self.videoDatas.count > 0) {
        _egoFooterView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, self.contentSize.height, self.frame.size.width, 60)];
        _egoFooterView.delegate = self;
        [self addSubview:_egoFooterView];
    }
}

-(void)addAiVideoObjects:(NSArray *)aiVideoObjects
{
    int startIndex = self.videoDatas.count;
    [self.videoDatas addObjectsFromArray:aiVideoObjects];
    for (int i = startIndex; i<[self.videoDatas count]; i++) {
        AiScrollViewCell *cell = [self scrollCellWithIndex:i];
        cell.aiVideoObject = [self.videoDatas objectAtIndex:i];
    }
    
    int deltaHeight = ceil((float)aiVideoObjects.count/ColNum) * _cellHeight;

    [self setContentSize:CGSizeMake(self.frame.size.width, self.contentSize.height + deltaHeight)];
    if (aiVideoObjects.count == SearchNum) {
        _egoFooterView.center = CGPointMake(_egoFooterView.center.x, _egoFooterView.center.y + deltaHeight);
    }
    else {
        [_egoFooterView removeFromSuperview];
    }
}

-(void)addButtonsFromOffSet:(float)offset
{
    CGSize size = CGSizeMake(100, 30);
    int deltaX = 150;
    UIButton * allButton = [[UIButton alloc] initWithFrame:CGRectMake(0, offset, size.width, size.height)];
    [allButton addTarget:self action:@selector(searchAll) forControlEvents:UIControlEventTouchUpInside];
    [allButton setTitle:@"全部" forState:UIControlStateNormal];
    [self addSubview:allButton];
    
    UIButton *songButton = [[UIButton alloc] initWithFrame:CGRectMake(deltaX, offset, size.width, size.height)];
    [songButton addTarget:self action:@selector(searchSong) forControlEvents:UIControlEventTouchUpInside];
    [songButton setTitle:@"儿歌" forState:UIControlStateNormal];
    [self addSubview:songButton];
    
    UIButton *catoonButton = [[UIButton alloc] initWithFrame:CGRectMake(deltaX * 2, offset, size.width, size.height)];
    [catoonButton addTarget:self action:@selector(searchCatoon) forControlEvents:UIControlEventTouchUpInside];
    [catoonButton setTitle:@"动画" forState:UIControlStateNormal];
    [self addSubview:catoonButton];
    
    UIButton *videoButton = [[UIButton alloc] initWithFrame:CGRectMake(deltaX * 3, offset, size.width, size.height)];
    [videoButton addTarget:self action:@selector(searchVideo) forControlEvents:UIControlEventTouchUpInside];
    [videoButton setTitle:@"节目" forState:UIControlStateNormal];
    [self addSubview:videoButton];
}

-(void)removeAllSubViews
{
    NSArray * views = [self subviews];
    for (UIView * view in views) {
        NSLog(@"view tag is %d",view.tag);
        if (view.tag > 3) {
            [view removeFromSuperview];
        }
    }
}

-(void)searchAll
{
    [self removeAllSubViews];
    [self.scrollViewController clickKeyWords:nil resourceType:-1];
}

-(void)searchSong
{
    [self removeAllSubViews];
    [self.scrollViewController clickKeyWords:nil resourceType:0];
}

-(void)searchCatoon
{
    [self removeAllSubViews];
    [self.scrollViewController clickKeyWords:nil resourceType:1];
}

-(void)searchVideo
{
    [self removeAllSubViews];
    [self.scrollViewController clickKeyWords:nil resourceType:2];
}

-(void)reloadData
{
    //首页效果
    _cellOffSet = 0;
    
    self.delegate = self;
    AiVideoObject *firstVideoObject = nil;
    if (self.videoDatas.count > 0) {
        firstVideoObject = [self.videoDatas objectAtIndex:0];
    }

    //搜索页面推荐效果
    if (firstVideoObject.status == 1 && self.viewType == kTagViewTypeSearch) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"AiSearchRecommendView" owner:self options:nil];
        
        AiSearchRecommendView *searchRecommendView = [nib objectAtIndex:0];
        searchRecommendView.videoObject = [firstVideoObject copy];
        searchRecommendView.keyWords = self.scrollViewController.keyWords;
        //专辑标题
        [searchRecommendView.albumTitle setText:firstVideoObject.serialTitle];
        [searchRecommendView.introText setText:firstVideoObject.serialDes];
        searchRecommendView.tag = 2001;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:firstVideoObject.imageUrl]];
        UIImage *image = [UIImage imageWithData:data];
        [searchRecommendView.albumImage setImage:image];
        [self addSubview:searchRecommendView];
        _cellOffSet = searchRecommendView.frame.size.height + 30;
        
        [self addButtonsFromOffSet:searchRecommendView.frame.size.height];
    }
    else if (self.viewType == kTagViewTypeSearch) {
        _cellOffSet = 50;
        [self addButtonsFromOffSet:_cellOffSet - 30];
    }

    //专辑页面
    if (self.viewType == kTagViewTypeAlbum) {
        _cellOffSet = 250;
    }
    
    if (self.viewType == kTagViewTypeIndex && firstVideoObject.status == 2) {
        AiBannerView *bannerView = [[AiBannerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 400) videoDatas:self.videoDatas scrollView:self];
        [self addSubview:bannerView];
        _cellOffSet = bannerView.frame.size.height;
    }
    
    _cellHeight = 0;
    for (int i = 0; i<[self.videoDatas count]; i++) {
        AiScrollViewCell *cell = [self scrollCellWithIndex:i];
        cell.aiVideoObject = [self.videoDatas objectAtIndex:i];
        _cellHeight = cell.frame.size.height + 10;
    }
    float height = ceil((float)self.videoDatas.count / ColNum) * _cellHeight + _cellOffSet;
    [self setContentSize:CGSizeMake(self.frame.size.width, height)];
}


-(AiScrollViewCell *)scrollCellWithIndex:(int)index
{
    UIImageView *frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edge_background_low.png"]];
    CGSize size = frameImageView.frame.size;
    int startX = 0;
    int startY = 0;
    int colNum = 4;
    
    int deltaX = 32;
    int deltaY = 10;
    
    AiScrollViewCell *cell = nil;
    
    if ([self viewWithTag:index + kTagVideoCellStartIndex]) {
        cell = (AiScrollViewCell *)[self viewWithTag:index + kTagVideoCellStartIndex];
    } else {
        cell = [[AiScrollViewCell alloc] initWithFrame:CGRectMake(startX + (size.width + deltaX)*(index%colNum), startY + (size.height+deltaY)*(index/colNum)+_cellOffSet, size.width, size.height) cellType:kViewCellTypeNormal];
        cell.scrollView = self;
        cell.tag = index + kTagVideoCellStartIndex;
        [self addSubview:cell];
    }
    
    return cell;
}

#pragma EGOFooterView
- (void)egoRefreshTableHeaderDidTriggerGetMore:(EGORefreshTableHeaderView*)view
{
    NSLog(@"egoRefreshTableHeaderDidTriggerGetMore");
    [self.scrollViewController getMoreData];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_egoFooterView egoRefreshScrollViewDidEndDragging:scrollView];
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

@implementation AiSearchRecommendView

-(IBAction)playVideo:(id)sender
{
    NSString *serialTitle = self.videoObject.serialTitle;
    NSLog(@"serialTitle is %@ keywords is %@",serialTitle,self.keyWords);
    //搜索关键字和专辑名字相同的话，打开专辑页面，否则打开播放页面
    if ([self.keyWords isEqualToString:serialTitle]) {
        AiScrollViewCell *scrollViewCell = [[AiScrollViewCell alloc] initWithVideoObject:self.videoObject];
        [scrollViewCell onClickButton:nil];
    } else {
        [self.videoObject getSongUrlWithCompletion:^(NSString *urlString,NSError *error){
            if (error == nil) {
                AiPlayerViewController *playViewController = [[AiPlayerViewController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
                [AiVideoPlayerManager shareInstance].aiPlayerViewController = playViewController;
                self.videoObject.playUrl = urlString;
                [AiVideoPlayerManager shareInstance].currentVideoObject = self.videoObject;
                UIApplication *shareApplication = [UIApplication sharedApplication];
                [shareApplication.keyWindow.rootViewController presentMoviePlayerViewControllerAnimated:playViewController];
            } else {
                NSLog(@"error is %@",error);
            }
        }];
    }
}

@end

@implementation AiScrollViewCell

-(id)initWithVideoObject:(AiVideoObject *)videoObject
{
    self = [super init];
    if (self) {
        _aiVideoObject = [[AiVideoObject alloc] init];
        self.aiVideoObject = [videoObject copy];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame cellType:(kViewCellType)viewCellType
{
    self = [super initWithFrame:frame];
    if (self) {
        if (viewCellType == kViewCellTypeNormal) {
            UIImageView *frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edge_background_low.png"]];
            [self addSubview:frameImageView];
        }
        self.backgroundColor = [UIColor clearColor];
        
        CGRect rect = CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 50);
        UIButton *imageButton_ = [[UIButton alloc] initWithFrame:rect];
        self.imageButton = imageButton_;
        [imageButton_ addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.imageButton];
        
        
        if (viewCellType == kViewCellTypeHot || viewCellType == kViewCellTypeRecommend) {
            CGRect backGroundRect = CGRectMake(5, rect.size.height - 25, rect.size.width, 30);
            UIView *textBackgroundView = [[UIView alloc] initWithFrame:backGroundRect];
            [textBackgroundView setBackgroundColor:[UIColor grayColor]];
            textBackgroundView.alpha = 0.5;
            [self addSubview:textBackgroundView];
            
            CGRect labelRect = CGRectMake(20, backGroundRect.origin.y, backGroundRect.size.width, backGroundRect.size.height);
            UILabel *label_ = [[UILabel alloc] initWithFrame:labelRect];
            label_.font = [UIFont systemFontOfSize:18];
            label_.backgroundColor = [UIColor clearColor];
            [label_ setTextColor:[UIColor whiteColor]];
            self.titleLabel = label_;
            [self addSubview:self.titleLabel];

        } else if(viewCellType == kViewCellTypeNormal) {
            CGRect labelRect = CGRectMake(20, rect.size.height + 10, rect.size.width, 30);
            UILabel *label_ = [[UILabel alloc] initWithFrame:labelRect];
            label_.font = [UIFont systemFontOfSize:12];
            label_.backgroundColor = [UIColor clearColor];
            [label_ setTextColor:[UIColor whiteColor]];
            self.titleLabel = label_;
            [self addSubview:self.titleLabel];
        }
        
        _aiVideoObject = [[AiVideoObject alloc] init];
    }
    return self;
}

-(void)onClickButton:(UIButton *)button
{
    NSLog(@"vid is %@ sourceType is %d videoType is %d serialId is %@ url is %@",self.aiVideoObject.vid,self.aiVideoObject.sourceType,self.aiVideoObject.videoType,self.aiVideoObject.serialId,self.aiVideoObject.playUrl);
    
    if (![self.aiVideoObject.serialId isEqualToString:@"0"]  && self.scrollView.viewType == kTagViewTypeIndex) {
        AiFirstViewController *firstViewController = (AiFirstViewController *)[[UIApplication sharedApplication].delegate window].rootViewController;
        [firstViewController presentAlbumViewController:self.aiVideoObject.serialId];
    } else {
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
    _aiVideoObject = [aiVideoObject copy];
    UMImageView *imageView = [[UMImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"icon"]];
    [imageView setImageURL:[NSURL URLWithString:aiVideoObject.imageUrl]];
    
    if ( !imageView.isCache) {
        [self.scrollView.queue addOperationWithBlock:^(void){
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aiVideoObject.imageUrl]];
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageButton setBackgroundImage:image forState:UIControlStateNormal];
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageButton setBackgroundImage:imageView.image forState:UIControlStateNormal];
        });
    }
    self.titleLabel.text = aiVideoObject.title;
}

@end
