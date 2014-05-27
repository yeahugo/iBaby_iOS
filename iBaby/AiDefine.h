//
//  AiDefine.h
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#ifndef iBaby_AiDefine_h
#define iBaby_AiDefine_h

typedef enum {
    kReportTypeSong,
    kReportTypeCatoon,
    kReportTypeVideo,
    kReportTypeSearch,
    kReportTypeHistory,
    kReportTypeFavourite,
    kReportTypeFeedback
} kReportType;

typedef enum {
    kTagButtonTypeSong,
    kTagButtonTypeCatoon,
    kTagButtonTypeVideo
} kTagButtonType;

typedef enum {
    kViewCellTypeHot,
    kViewCellTypeRecommend,
    kViewCellTypeNormal,
    kViewCellTypeSearchRecommend
}kViewCellType;

typedef enum {
    kTagViewTypeIndex,
    kTagViewTypeSearch,
    kTagViewTypeHistory,
    kTagViewTypeFavourite,
    kTagViewTypeAlbum
} kTagViewType;

typedef enum {
    kSearchViewTypeAll,
    kSearchViewTypeSong,
    kSearchViewTypeCatoon,
    kSearchViewTypeVideo
}kSearchViewType;

#define ResponseCodeSuccess 0

#define kTagVideoCellStartIndex 1000

//#define AI_HOST_IP @"115.28.213.143"

#define AI_HOST_IP @"www.aijingang.com"

#define UmengAppkey @"537d712556240b75fb0a2645"

#define AI_HOST_PORT 9013

#define ShowNum 12

#define SearchNum 12*3

#define AlbumNum 12

#define RecommendNum SearchNum

#define ColNum 4

#define RowNum 2

#define ScrollOffSet 100

#define VideoTypeNum 3

#define HistoryNum 12*3

#define VERSION @"1.0"

#endif
