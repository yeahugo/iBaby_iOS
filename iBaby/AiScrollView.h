//
//  AiScrollView.h
//  iBaby
//
//  Created by yeahugo on 14-5-10.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiVideoObject.h"

@interface AiScrollView : UIScrollView

@property (nonatomic, strong) NSArray * videoDatas;

@property (nonatomic, strong) NSOperationQueue *queue;

-(void)setAiVideoObjects:(NSArray *)aiVideoObjects;

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