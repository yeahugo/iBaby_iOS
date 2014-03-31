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
    }
    return self;
}

-(void)getVideoListsWithCompletion:(void(^)(NSArray* videoList, NSError* error))completion
{
    EGODatabaseRequest *request = [_dataBase requestWithQuery:@"SELECT * FROM `PlayedVideos`"];
    request.completion = ^(EGODatabaseRequest* request, EGODatabaseResult* result, NSError* error){
        if (result.errorCode == 0) {
            NSMutableArray *videoArray = [NSMutableArray array];
            for(EGODatabaseRow* row in result) {
                NSLog(@"title: %@", [row stringForColumn:@"Title"]);
                NSLog(@"imageUrl: %@", [row stringForColumn:@"ImageUrl"]);
                NSLog(@"sourceType: %d", [row intForColumn:@"SourceType"]);
                NSLog(@"vid: %@", [row stringForColumn:@"Vid"]);
                NSLog(@"playtime: %d",[row intForColumn:@"PlayTime"]);
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
    NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO PlayedVideos(Id, Title,ImageUrl,SourceType,Vid,PlayTime) VALUES (NULL,'%@','%@',%d,'%@',%d);",videoObject.title,videoObject.imageUrl,videoObject.sourceType,videoObject.vid,videoObject.playTime];
    EGODatabaseRequest *request = [_dataBase requestWithUpdate:sqlString];
    [_queue addOperation:request];
}

@end
