//
//  AiScrollView.m
//  iBaby
//
//  Created by yeahugo on 14-5-10.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiScrollView.h"
#import "AiScrollViewCell.h"
#import "AiNormalPlayerViewController.h"
#import "AiVideoPlayerManager.h"
#import "AiBannerView.h"
#import "AiIndexViewController.h"
#import "AiAudioManager.h"
#import "AiDataRequestManager.h"

#define DeltaY 14

@implementation AiScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        _videoDatas = [[NSMutableArray alloc] init];
        _queue = [[NSOperationQueue alloc] init];
        self.pageCount = SearchNum;
        EGORefreshTableHeaderView * footView = [[EGORefreshTableHeaderView alloc] initWithWaitingImage:CGRectMake(0, self.contentSize.height, self.frame.size.width - 50, 60)];
        self.egoFooterView = footView;
        [self addSubview:self.egoFooterView];
    }
    return self;
}

-(void)setAiVideoObjects:(NSArray *)aiVideoObjects
{
    //首页效果
    _cellOffSetY = 0;
    _cellOffSetX = 0;
    
    self.delegate = self;
    AiVideoObject *firstVideoObject = nil;
    if (aiVideoObjects.count > 0) {
        firstVideoObject = [aiVideoObjects objectAtIndex:0];
    }
    
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(scrollViewReload)]) {
        _cellOffSetY = [self.scrollViewDelegate scrollViewReload];
    }
    
    _cellHeight = 0;

    //计算可以整除4个的小图数量
    NSArray *showDatas = nil;
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(showVideoArray:)]) {
        showDatas = [self.scrollViewDelegate showVideoArray:aiVideoObjects];
    }
    for (int i = 0; i<showDatas.count; i++) {
        AiScrollViewCell *cell = [self scrollCellWithIndex:i];
        cell.resourceInfo = [showDatas objectAtIndex:i];
        [cell reloadResourceInfo];
        _cellHeight = cell.frame.size.height + DeltaY;
    }
    _showdNum = showDatas.count;
    float height = ceil((float)showDatas.count / ColNum) * _cellHeight + _cellOffSetY;
    [self setContentSize:CGSizeMake(self.frame.size.width, height)];
    
    //设置EGO Footer
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(reloadEgoFooterView:totalNum:egoView:)]) {
        BOOL isShow = [self.scrollViewDelegate reloadEgoFooterView:aiVideoObjects totalNum:self.pageCount egoView:self.egoFooterView];
        if (isShow == NO) {
            self.egoFooterView.hidden = YES;
        }
    }
}

-(void)addAiVideoObjects:(NSArray *)aiVideoObjects
{
    for (int i = _showdNum; i<_showdNum + [aiVideoObjects count]; i++) {
        AiScrollViewCell *cell = [self scrollCellWithIndex:i];
        cell.resourceInfo = [aiVideoObjects objectAtIndex:i-_showdNum];
        [cell reloadResourceInfo];
    }
    
    int deltaHeight = (ceil((float)(_showdNum+aiVideoObjects.count)/ColNum) - ceil((float)_showdNum/ColNum)) * _cellHeight;
    [self setContentSize:CGSizeMake(self.frame.size.width, self.contentSize.height + deltaHeight)];
    _showdNum = _showdNum + aiVideoObjects.count;
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


#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.egoFooterView egoRefreshScrollViewDidEndDragging:scrollView];
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
    [self.videoObject playVideo];
//    NSString *serialTitle = self.videoObject.serialTitle;
    //搜索关键字和专辑名字相同的话，打开专辑页面，否则打开播放页面
//    if ([self.keyWords isEqualToString:serialTitle]) {
//        AiScrollViewCell *scrollViewCell = [[AiScrollViewCell alloc] initWithVideoObject:self.videoObject];
//        [scrollViewCell onClickButton:nil];
//    } else {
//        [self.videoObject playVideo];
//    }
}

@end

