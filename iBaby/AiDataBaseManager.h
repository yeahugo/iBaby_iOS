//
//  AiDataBaseManager.h
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGODatabase.h"
#import "AiVideoObject.h"

@interface AiDataBaseManager : NSObject
{
    EGODatabase *_dataBase;
    NSOperationQueue *_queue;
}

+ (AiDataBaseManager *)shareInstance;

-(void)getRecommendListsWithCompletion:(void(^)(NSArray* videoList, NSError* error))completion;

-(void)getVideoListsWithStartLimit:(int)startLimit withCompletion:(void(^)(NSArray* videoList, NSError* error))completion;

-(void)getVideoListsWithCompletion:(void(^)(NSArray* videoList, NSError* error))completion;

-(void)addVideoRecord:(AiVideoObject *)videoObject;
@end
