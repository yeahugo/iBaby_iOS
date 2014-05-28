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
#import "AiAudioManager.h"
#import "AiDataRequestManager.h"
#import "AFNetworking/AFNetworking.h"
#import "AiWaitingView.h"

#define DeltaY 14

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
    
    if (self.videoDatas.count % self.pageCount == 0 && self.videoDatas.count > 0) {
        _egoFooterView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, self.contentSize.height, self.frame.size.width - 50, 60)];
        _egoFooterView = [[EGORefreshTableHeaderView alloc] initWithWaitingImage:CGRectMake(0, self.contentSize.height, self.frame.size.width - 50, 60)];
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
    if (aiVideoObjects.count == self.pageCount) {
        _egoFooterView.center = CGPointMake(_egoFooterView.center.x, _egoFooterView.center.y + deltaHeight);
    }
    else {
        [_egoFooterView removeFromSuperview];
    }
}

-(void)addButtonsFromOffSet:(float)offset
{
    CGSize size = CGSizeMake(55, 31);
    int deltaX = 10+size.width;
    UIButton * allButton = [[UIButton alloc] initWithFrame:CGRectMake(0, offset, size.width, size.height)];
    self.allButton = allButton;
    [self.allButton addTarget:self action:@selector(searchAll:) forControlEvents:UIControlEventTouchUpInside];
    [allButton setTitle:@"全部" forState:UIControlStateNormal];
    
    [self addSubview:self.allButton];
    
    UIButton *songButton = [[UIButton alloc] initWithFrame:CGRectMake(deltaX, offset, size.width, size.height)];
     self.songButton = songButton;
    [self.songButton addTarget:self action:@selector(searchSong:) forControlEvents:UIControlEventTouchUpInside];
    [songButton setTitle:@"儿歌" forState:UIControlStateNormal];
   
    [self addSubview:self.songButton];
    
    UIButton *catoonButton = [[UIButton alloc] initWithFrame:CGRectMake(deltaX * 2, offset, size.width, size.height)];
    self.cattonButton = catoonButton;
    [self.cattonButton addTarget:self action:@selector(searchCatoon:) forControlEvents:UIControlEventTouchUpInside];
    [catoonButton setTitle:@"动画" forState:UIControlStateNormal];
    
    [self addSubview:self.cattonButton];
    
    UIButton *videoButton = [[UIButton alloc] initWithFrame:CGRectMake(deltaX * 3, offset, size.width, size.height)];
    self.videoButton = videoButton;
    [self.videoButton addTarget:self action:@selector(searchVideo:) forControlEvents:UIControlEventTouchUpInside];
    [videoButton setTitle:@"节目" forState:UIControlStateNormal];
    
    [self addSubview:self.videoButton];
    
    self.chooseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"choose"]];
    if (self.searchViewType == kSearchViewTypeAll) {
        [self.allButton addSubview:self.chooseView];
    }
    if (self.searchViewType == kSearchViewTypeSong) {
        [self.songButton addSubview:self.chooseView];
    }
    if (self.searchViewType == kSearchViewTypeCatoon) {
        [self.cattonButton addSubview:self.chooseView];
    }
    if (self.searchViewType == kSearchViewTypeVideo) {
        [self.videoButton addSubview:self.chooseView];
    }
}

-(void)removeAllSubViews
{
    NSArray * views = [self subviews];
    for (UIView * view in views) {
//        NSLog(@"view tag is %d",view.tag);
        if (view.tag > 3) {
            [view removeFromSuperview];
        }
    }
}


-(void)searchAll:(UIButton *)button
{
    [self removeAllSubViews];
    [self.chooseView removeFromSuperview];
    self.searchViewType = kSearchViewTypeAll;
    [self.scrollViewController clickKeyWords:nil resourceType:-1];
}

-(void)searchSong:(UIButton *)button
{
    [self removeAllSubViews];
    [self.chooseView removeFromSuperview];
    self.searchViewType = kSearchViewTypeSong;
    [self.scrollViewController clickKeyWords:nil resourceType:1];
}

-(void)searchCatoon:(UIButton *)button
{
    [self removeAllSubViews];
    [self.chooseView removeFromSuperview];
    self.searchViewType = kSearchViewTypeCatoon;
    [self.scrollViewController clickKeyWords:nil resourceType:2];
}

-(void)searchVideo:(UIButton *)button
{
    [self removeAllSubViews];
    [self.chooseView removeFromSuperview];
    self.searchViewType = kSearchViewTypeVideo;
    [self.scrollViewController clickKeyWords:nil resourceType:3];
}


-(void)reloadData
{
    //首页效果
    _cellOffSetY = 0;
    _cellOffSetX = 0;
    
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
        if ([self.scrollViewController.keyWords isEqualToString:firstVideoObject.serialTitle]) {
            [searchRecommendView.albumTitle setText:firstVideoObject.serialTitle];
        } else{
            [searchRecommendView.albumTitle setText:firstVideoObject.title];
        }
        [searchRecommendView.introText setText:firstVideoObject.serialDes];
        searchRecommendView.tag = 2001;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:firstVideoObject.imageUrl]];
        UIImage *image = [UIImage imageWithData:data];
        [searchRecommendView.albumImage setImage:image];
        [self addSubview:searchRecommendView];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"break line"]];
        line.center = CGPointMake(self.frame.size.width/2, searchRecommendView.frame.size.height);
        [self addSubview:line];
        
        _cellOffSetY = searchRecommendView.frame.size.height + 40;
        
        [self addButtonsFromOffSet:searchRecommendView.frame.size.height];
    }
    else if (self.viewType == kTagViewTypeSearch) {
        _cellOffSetY = 50;
        [self addButtonsFromOffSet:_cellOffSetY - 45];
    }

    //专辑页面
    if (self.viewType == kTagViewTypeAlbum) {
        _cellOffSetY = 190;
    }
    
    if (self.viewType == kTagViewTypeIndex && firstVideoObject.status == 2) {
        AiBannerView *bannerView = [[AiBannerView alloc] initWithFrame:CGRectMake( _cellOffSetX, 0, self.frame.size.width, 296) videoDatas:self.videoDatas scrollView:self];
        [self addSubview:bannerView];
        _cellOffSetY = 322;
    }
    
    _cellHeight = 0;
    for (int i = 0; i<[self.videoDatas count]; i++) {
        AiScrollViewCell *cell = [self scrollCellWithIndex:i];
        cell.aiVideoObject = [self.videoDatas objectAtIndex:i];
        _cellHeight = cell.frame.size.height + DeltaY;
    }
    float height = ceil((float)self.videoDatas.count / ColNum) * _cellHeight + _cellOffSetY;
    [self setContentSize:CGSizeMake(self.frame.size.width, height)];
}


-(AiScrollViewCell *)scrollCellWithIndex:(int)index
{
    UIImageView *frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edge_background_low"]];
    CGSize size = frameImageView.frame.size;
    int startY = 0;
    int colNum = 4;
    
    int deltaX = 17;
    int deltaY = DeltaY;
    
    AiScrollViewCell *cell = nil;
    
    if ([self viewWithTag:index + kTagVideoCellStartIndex]) {
        cell = (AiScrollViewCell *)[self viewWithTag:index + kTagVideoCellStartIndex];
    } else {
        cell = [[AiScrollViewCell alloc] initWithFrame:CGRectMake(_cellOffSetX + (size.width + deltaX)*(index%colNum), startY + (size.height+deltaY)*(index/colNum)+_cellOffSetY, size.width, size.height) cellType:kViewCellTypeNormal];
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
                self.videoObject.playUrl = urlString;
                [AiVideoPlayerManager shareInstance].currentVideoObject = self.videoObject;
                AiPlayerViewController *playViewController = [[AiPlayerViewController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
                [AiVideoPlayerManager shareInstance].aiPlayerViewController = playViewController;
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
            
            CGRect labelRect = CGRectMake(20, backGroundRect.origin.y - 3, backGroundRect.size.width, backGroundRect.size.height);
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

            CGRect labelRect = CGRectMake(16, rect.size.height , rect.size.width - 10, 45);
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
        
        _aiVideoObject = [[AiVideoObject alloc] init];
    }
    return self;
}

-(void)onClickButton:(UIButton *)button
{
    NSLog(@"vid is %@ sourceType is %d videoType is %d serialId is %@ url is %@",self.aiVideoObject.vid,self.aiVideoObject.sourceType,self.aiVideoObject.videoType,self.aiVideoObject.serialId,self.aiVideoObject.playUrl);
    
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [AiWaitingView addNoNetworkTip];
//        [AiWaitingView addNoNetworkTip:self.superview.superview.superview];
        return;
    }
    
    if (self.viewCellType == kViewCellTypeSearchRecommend) {
        UITextField *textField = (UITextField *)[self.superview.superview viewWithTag:50];
        [textField resignFirstResponder];
//        [AiAudioManager play:@"search"];
    }
    
    if (![self.aiVideoObject.serialId isEqualToString:@"0"]  && self.scrollView.viewType == kTagViewTypeIndex) {
        AiFirstViewController *firstViewController = (AiFirstViewController *)[[UIApplication sharedApplication].delegate window].rootViewController;
        [firstViewController presentAlbumViewObject:self.aiVideoObject];
    } else {
        [self.aiVideoObject getSongUrlWithCompletion:^(NSString *urlString,NSError *error){
            if (error == nil) {
                [AiVideoPlayerManager shareInstance].currentVideoObject = self.aiVideoObject;
                AiPlayerViewController *playViewController = [[AiPlayerViewController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
                [AiVideoPlayerManager shareInstance].aiPlayerViewController = playViewController;
                self.aiVideoObject.playUrl = urlString;
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
//        NSLog(@"imageView not cache!");
        [[AiDataRequestManager shareInstance].queue addOperationWithBlock:^(void){
//                    NSLog(@"imageView add block!");
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aiVideoObject.imageUrl]];
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
    self.titleLabel.text = aiVideoObject.title;
}

@end
