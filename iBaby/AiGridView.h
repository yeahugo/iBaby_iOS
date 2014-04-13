//
//  AiBackgroundView.h
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipView/SwipeView.h"
#import "AiVideoObject.h"

@interface AiGridView  : UIView

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSArray * videoDatas;

-(void)setVideoObjects:(NSArray *)videoObjects;

@end

@interface AiSwipeView : SwipeView

@property (nonatomic, strong) UIImageView *footerArrowView;

@property (nonatomic, strong) UIImageView *headerArrowView;

@property (nonatomic, strong) AiGridView * gridView;

-(void)transFormArrow:(UIImageView *)imageView;

-(void)recover:(UIImageView *)imageView;

@end

@interface AiGridViewCell : UIView

@property (nonatomic, strong) AiVideoObject *aiVideoObject;

@property (nonatomic, strong) UIButton *imageButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) AiGridView *gridView;

@end
