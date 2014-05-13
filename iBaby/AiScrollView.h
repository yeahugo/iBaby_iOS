//
//  AiScrollView.h
//  iBaby
//
//  Created by yeahugo on 14-5-10.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiVideoObject.h"
#import "SwipeView.h"
#import "EGORefreshTableHeaderView.h"

@class AiScrollViewController;

@interface AiScrollView : UIScrollView<SwipeViewDataSource,EGORefreshTableHeaderDelegate,UIScrollViewDelegate>
{
    EGORefreshTableHeaderView * _egoFooterView;
    int _cellHeight;
    int _cellOffSet;
}

@property (nonatomic, strong) NSMutableArray * videoDatas;

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, assign) AiScrollViewController * scrollViewController;

-(void)setAiVideoObjects:(NSArray *)aiVideoObjects;

-(void)addAiVideoObjects:(NSArray *)aiVideoObjects;

-(void)reloadData;
@end

@interface AiAlbumView : UIView

@end

@interface AiScrollViewCell : UIView

@property (nonatomic, strong) AiVideoObject *aiVideoObject;

@property (nonatomic, strong) UIButton *imageButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) AiScrollView *scrollView;

@end