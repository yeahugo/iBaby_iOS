//
//  AiBannerView.m
//  iBaby
//
//  Created by yeahugo on 14-5-17.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiBannerView.h"
#import "AiScrollView.h"

@implementation AiBannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame videoDatas:(NSArray *)videoDatas scrollView:(AiScrollView *)aiScrollView
{
    self = [super initWithFrame:frame];
    if (self) {
        int bigVideoNum = 7;
        _scrollViewWidth = 490;
        UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _scrollViewWidth, frame.size.height)];
        scrollView.backgroundColor = [UIColor blackColor];
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake(bigVideoNum * scrollView.frame.size.width, scrollView.frame.size.height);
        scrollView.delegate = self;
        [self addSubview:scrollView];
        
        CGRect pageControlRect = CGRectMake(380, frame.size.height - 30, 100, 30);
        _pageControl = [[UIPageControl alloc] initWithFrame:pageControlRect];
        _pageControl.numberOfPages = bigVideoNum;
        _pageControl.currentPage = 0;
//        [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
//        [self pageChanged:_pageControl];
        [self addSubview:_pageControl];
        
        for (int i = 0; i < bigVideoNum; i++) {
            AiScrollViewCell *scrollViewCell = [[AiScrollViewCell alloc] initWithFrame:CGRectMake(i * scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height) cellType:kViewCellTypeHot];
            scrollViewCell.scrollView = aiScrollView;
            scrollViewCell.tag = 2000 + i;
            scrollViewCell.aiVideoObject = [videoDatas objectAtIndex:i];
            [scrollView addSubview:scrollViewCell];
        }
        scrollView.backgroundColor = [UIColor blackColor];
        
        int deltaX = 17;
        int height = 143;
        int width = 266;
        int deltaY = 10;
        
        for (int i = 0; i < 2; i++) {
            AiScrollViewCell *scrollViewCellRecommend = [[AiScrollViewCell alloc] initWithFrame:CGRectMake(_scrollViewWidth + deltaX, i*(height+deltaY), width, height) cellType:kViewCellTypeRecommend];
            scrollViewCellRecommend.scrollView = aiScrollView;
            scrollViewCellRecommend.aiVideoObject = [videoDatas objectAtIndex:bigVideoNum + i];
            [self addSubview:scrollViewCellRecommend];
        }
    }
    return self;
}

//-(void)pageChanged:(UIPageControl*)pc{
//    NSArray *subViews = pc.subviews;
//    for (int i = 0; i < [subViews count]; i++) {
//        UIView* subView = [subViews objectAtIndex:i];
//        if ([NSStringFromClass([subView class]) isEqualToString:NSStringFromClass([UIImageView class])]) {
//            ((UIImageView*)subView).image = (pc.currentPage == i ? [UIImage imageNamed:@"banner_focus.png"] : [UIImage imageNamed:@"banner_notfocus.png"]);
//        }
//        
//    }
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollview {
    int page = scrollview.contentOffset.x / _scrollViewWidth;
    _pageControl.currentPage = page;
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
