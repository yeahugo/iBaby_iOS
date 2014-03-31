//
//  AiBackgroundView.h
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AiVideoObject.h"

@interface AiGridViewCell : UIView

@property (nonatomic, strong) AiVideoObject *aiVideoObject;

@property (nonatomic, strong) UIButton *imageButton;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@interface AiGridView : UIScrollView

@property (nonatomic, strong) NSArray * videoDatas;

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) UIImageView *headerArrowView;

-(void)setVideoObjects:(NSArray *)videoObjects;

-(void)transFormArrow:(UIImageView *)imageView;

-(void)recover:(UIImageView *)imageView;

@end
