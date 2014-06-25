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

@protocol AiScrollViewDelegate <NSObject>

-(int)scrollViewReload;

-(void)getMoreData:(int)num;

-(BOOL)reloadEgoFooterView:(NSArray *)resourceInfos totalNum:(int)totalNum egoView:(EGORefreshTableHeaderView *)footView;

-(NSArray *)showVideoArray:(NSArray *)videoArray;

@end

@class AiIndexViewController;

@interface AiScrollView : UIScrollView
<UIScrollViewDelegate>
{
//    EGORefreshTableHeaderView * _egoFooterView;
    int _cellHeight;
    int _cellOffSetY;
    int _cellOffSetX;
    int _showdNum;
//    int _leftNum;
//    int _getMoreDataNum;
}

@property (nonatomic, assign) kTagViewType viewType;

@property (nonatomic, strong) NSArray *leftDatas;  //第一次没有显示完的数据

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, assign) int pageCount;

@property (nonatomic, weak) id<AiScrollViewDelegate> scrollViewDelegate;

@property (nonatomic, strong) EGORefreshTableHeaderView *egoFooterView;

-(void)setAiVideoObjects:(NSArray *)aiVideoObjects;

-(void)addAiVideoObjects:(NSArray *)aiVideoObjects;

@end

@interface AiAlbumView : UIView

@property (nonatomic, strong) IBOutlet UILabel *albumTitle;

@end

@interface AiSearchRecommendView : UIView

@property (nonatomic, strong) IBOutlet UILabel *albumTitle;

@property (nonatomic, strong) IBOutlet UIImageView *albumImage;

@property (nonatomic, strong) IBOutlet UILabel *introText;

@property (nonatomic, strong) AiVideoObject *videoObject;

@property (nonatomic, copy) NSString *keyWords;

-(IBAction)playVideo:(id)sender;
@end

