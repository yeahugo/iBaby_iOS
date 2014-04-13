//
//  AiDataBaseManager.m
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiDataBaseManager.h"

@implementation AiDataBaseManager

+ (AiDataBaseManager *)shareInstance {
    static AiDataBaseManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

-(id)init
{
    self = [super init];
    if (self) {
        NSString *defaultDBPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"];
        _dataBase = [EGODatabase databaseWithPath:defaultDBPath];
        
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM `PlayedVideos`"];
        EGODatabaseResult *result = [_dataBase executeQuery:queryString];
        if (result.errorCode == 1) {
            NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE PlayedVideos(Id integer PRIMARY KEY AUTOINCREMENT, Title String,ImageUrl String,SourceType integer,Vid String,PlayTime integer);"];
            [_dataBase executeUpdate:sqlString];
        }
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
    }
    return self;
}

-(void)getVideoListsWithCompletion:(void(^)(NSArray* videoList, NSError* error))completion
{
    EGODatabaseRequest *request = [_dataBase requestWithQuery:[NSString stringWithFormat:@"SELECT * FROM `PlayedVideos` ORDER BY Id DESC LIMIT %d",HistoryNum]];
    request.completion = ^(EGODatabaseRequest* request, EGODatabaseResult* result, NSError* error){
        if (result.errorCode == 0) {
            NSMutableArray *videoArray = [NSMutableArray array];
            for(EGODatabaseRow* row in result) {
                AiVideoObject *video = [[AiVideoObject alloc] init];
                video.title = [row stringForColumn:@"Title"];
                video.imageUrl = [row stringForColumn:@"ImageUrl"];
                video.sourceType = [row intForColumn:@"SourceType"];
                video.vid = [row stringForColumn:@"Vid"];
                video.playTime = [row intForColumn:@"PlayTime"];
                [videoArray addObject:video];
            }
            completion(videoArray,error);
        } else {
            completion(nil,error);
        }
    };
    [_queue addOperation:request];
}

-(void)addVideoRecord:(AiVideoObject *)videoObject
{
    @try {
        NSString *deleteString = [NSString stringWithFormat:@"DELETE FROM PlayedVideos WHERE SourceType=%d and Vid='%@'",videoObject.sourceType,videoObject.vid];
        NSLog(@"deleteString is %@",deleteString);
        EGODatabaseRequest *deleteRequest = [_dataBase requestWithUpdate:deleteString];
        [_queue addOperation:deleteRequest];
        
        NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO PlayedVideos(Id, Title,ImageUrl,SourceType,Vid,PlayTime) VALUES (NULL,'%@','%@',%d,'%@',%d);",videoObject.title,videoObject.imageUrl,videoObject.sourceType,videoObject.vid,videoObject.playTime];
        NSLog(@"insertString is %@",sqlString);
        EGODatabaseRequest *request = [_dataBase requestWithUpdate:sqlString];
        [_queue addOperation:request];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
}

@end
