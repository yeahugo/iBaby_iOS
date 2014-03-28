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
    kTagButtonTypeSong,
    kTagButtonTypeCatoon,
    kTagButtonTypeVideo
} kTagButtonType;

typedef enum {
    kTagPlaySourceTypeYouku,
    kTagPlaySourceType56,
} kTagPlaySourceType;

#define kTagVideoCellStartIndex 100

#define AI_HOST_IP @"115.28.213.143"

#define AI_HOST_PORT 9090

#define SearchNum 20

#define RecommendNum 20

#endif
