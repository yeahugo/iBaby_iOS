//
//  AiBannerView.h
//  iBaby
//
//  Created by yeahugo on 14-5-17.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiScrollView.h"

@interface AiBannerView : UIView<UIScrollViewDelegate>
{
    UIPageControl *_pageControl;
    float _scrollViewWidth;
}

- (id)initWithFrame:(CGRect)frame videoDatas:(NSArray *)videoDatas scrollView:(AiScrollView *)aiScrollView;

@end
