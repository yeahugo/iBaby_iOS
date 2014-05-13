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
            NSString *historySqlString = [NSString stringWithFormat:@"CREATE TABLE PlayedVideos(Id integer PRIMARY KEY AUTOINCREMENT, Title String,ImageUrl String,SourceType integer,Vid String,PlayTime integer);"];
//            [_dataBase requestWithUpdate:historySqlString];
            [_dataBase executeUpdate:historySqlString];
            NSString *recommendSqlString = [NSString stringWithFormat:@"CREATE TABLE RecommendVideos(Id integer PRIMARY KEY AUTOINCREMENT, Title String,ImageUrl String,SourceType integer,Vid String,VideoType integer);"];
//            [_dataBase requestWithUpdate:recommendSqlString];
            [_dataBase executeUpdate:recommendSqlString];
            NSString *favouriteSqlString = [NSString stringWithFormat:@"CREATE TABLE FavouriteVideos(Id integer PRIMARY KEY AUTOINCREMENT, Title String,ImageUrl String,SourceType integer,Vid String,VideoType integer);"];
//            [_dataBase requestWithUpdate:favouriteSqlString];
            [_dataBase executeUpdate:favouriteSqlString];
        }
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
    }
    return self;
}

-(void)getRecommendListsWithCompletion:(void(^)(NSArray* videoList, NSError* error))completion{
    EGODatabaseRequest *request = [_dataBase requestWithQuery:[NSString stringWithFormat:@"SELECT * FROM `RecommendVideos`"]];
    request.completion = ^(EGODatabaseRequest* request, EGODatabaseResult* result, NSError* error){
        if (result.errorCode == 0) {
            NSMutableArray *songArray = [[NSMutableArray alloc] init];
            NSMutableArray *catoonArray = [[NSMutableArray alloc] init];
            NSMutableArray *videoArray = [[NSMutableArray alloc] init];
            for(EGODatabaseRow* row in result) {
                AiVideoObject *video = [[AiVideoObject alloc] init];
                video.title = [row stringForColumn:@"Title"];
                video.imageUrl = [row stringForColumn:@"ImageUrl"];
                video.sourceType = [row intForColumn:@"SourceType"];
                video.vid = [row stringForColumn:@"Vid"];
                video.playTime = [row intForColumn:@"PlayTime"];
                video.videoType = [row intForColumn:@"VideoType"];
                if (video.videoType == kTagButtonTypeSong) {
                    [songArray addObject:video];
                }
                if (video.videoType == kTagButtonTypeCatoon) {
                    [catoonArray addObject:video];
                }
                if (video.videoType == kTagButtonTypeVideo) {
                    [videoArray addObject:video];
                }
            }
            NSArray *allArray = [NSArray arrayWithObjects:songArray,catoonArray,videoArray, nil];
            completion(allArray,error);
        } else {
            completion(nil,error);
        }
    };

    [_queue addOperation:request];
}

-(void)getVideoListsWithStartLimit:(int)startLimit withCompletion:(void(^)(NSArray* videoList, NSError* error))completion{
    EGODatabaseRequest *request = [_dataBase requestWithQuery:[NSString stringWithFormat:@"SELECT * FROM `PlayedVideos` ORDER BY Id DESC LIMIT %d,%d",startLimit,ShowNum]];
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

-(void)getFavouriteListsWithCompletion:(void(^)(NSArray* videoList, NSError* error))completion
{
    EGODatabaseRequest *request = [_dataBase requestWithQuery:[NSString stringWithFormat:@"SELECT * FROM `FavouriteVideos` ORDER BY Id DESC LIMIT %d",HistoryNum]];
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

-(void)addRecommendVideo:(AiVideoObject *)videoObject
{
    @try {
        NSString *deleteString = [NSString stringWithFormat:@"DELETE FROM RecommendVideos WHERE SourceType=%d and Vid='%@'",videoObject.sourceType,videoObject.vid];
        EGODatabaseRequest *deleteRequest = [_dataBase requestWithUpdate:deleteString];
        [_queue addOperation:deleteRequest];
        
        NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO RecommendVideos(Id, Title,ImageUrl,SourceType,VideoType,Vid,PlayTime) VALUES (NULL,'%@','%@',%d,%d,'%@',%ld);",videoObject.title,videoObject.imageUrl,videoObject.sourceType,videoObject.videoType,videoObject.vid,(long)videoObject.playTime];
        NSLog(@"insertString is %@",sqlString);
        EGODatabaseRequest *request = [_dataBase requestWithUpdate:sqlString];
        [_queue addOperation:request];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
}

-(void)addFavouriteRecord:(AiVideoObject *)videoObject
{
    @try {
        NSString *deleteString = [NSString stringWithFormat:@"DELETE FROM FavouriteVideos WHERE SourceType=%d and Vid='%@'",videoObject.sourceType,videoObject.vid];
        NSLog(@"deleteString is %@",deleteString);
        EGODatabaseRequest *deleteRequest = [_dataBase requestWithUpdate:deleteString];
        [_queue addOperation:deleteRequest];
        
        NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO FavouriteVideos(Id, Title,ImageUrl,SourceType,Vid) VALUES (NULL,'%@','%@',%d,'%@');",videoObject.title,videoObject.imageUrl,videoObject.sourceType,videoObject.vid];
        NSLog(@"insertString is %@",sqlString);
        EGODatabaseRequest *request = [_dataBase requestWithUpdate:sqlString];
        [_queue addOperation:request];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
}

-(void)deleteFavouriteRecord:(AiVideoObject *)videoObject
{
    @try {
        NSString *deleteString = [NSString stringWithFormat:@"DELETE FROM FavouriteVideos WHERE SourceType=%d and Vid='%@'",videoObject.sourceType,videoObject.vid];
        NSLog(@"deleteString is %@",deleteString);
        EGODatabaseRequest *deleteRequest = [_dataBase requestWithUpdate:deleteString];
        [_queue addOperation:deleteRequest];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
}

-(BOOL)isFavouriteVideo:(AiVideoObject *)videoObject
{
    BOOL isFavourite = NO;
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM `FavouriteVideos` WHERE SourceType=%d and Vid='%@'",videoObject.sourceType,videoObject.vid];
    EGODatabaseResult *result = [_dataBase executeQuery:queryString];
    if (result.count > 0) {
        isFavourite = YES;
    }
    return isFavourite;
}

-(void)addVideoRecord:(AiVideoObject *)videoObject
{
    @try {
        NSString *deleteString = [NSString stringWithFormat:@"DELETE FROM PlayedVideos WHERE SourceType=%d and Vid='%@'",videoObject.sourceType,videoObject.vid];
        NSLog(@"deleteString is %@",deleteString);
        EGODatabaseRequest *deleteRequest = [_dataBase requestWithUpdate:deleteString];
        [_queue addOperation:deleteRequest];
        
        NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO PlayedVideos(Id, Title,ImageUrl,SourceType,Vid,PlayTime) VALUES (NULL,'%@','%@',%d,'%@',%ld);",videoObject.title,videoObject.imageUrl,videoObject.sourceType,videoObject.vid,(long)videoObject.playTime];
        NSLog(@"insertString is %@",sqlString);
        EGODatabaseRequest *request = [_dataBase requestWithUpdate:sqlString];
        [_queue addOperation:request];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
}

@end
