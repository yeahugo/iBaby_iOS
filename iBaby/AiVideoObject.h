//
//  AiVideoObject.h
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiDefine.h"

@interface AiVideoObject : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *imageUrl;

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, assign) NSInteger playTime;

@property (nonatomic, assign) kTagPlaySourceType sourceType;

@property (nonatomic, assign) kTagButtonType videoType;

-(void)getSongUrlWithCompletion:(void (^)(NSString *urlString,NSError *error))completion;

@end
