//
//  AiDataManager.m
//  iBaby
//
//  Created by yeahugo on 14-3-27.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiDataRequestManager.h"
#import "AiThriftManager.h"
#import "AiUserManager.h"

@implementation AiDataRequestManager

@synthesize searchKeyVer = _searchKeyVer;

+ (AiDataRequestManager *)shareInstance {
    static AiDataRequestManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

-(id)init{
    self = [super init];
    if (self) {
        _reConnectNum = 0;
        int babyId = [AiUserManager shareInstance].babyId;
        NSString *openUdid = [AiUserManager shareInstance].openUdid;
        self.queue = [[NSOperationQueue alloc] init];
        
//        NSLog(@"baby id is %d",babyId);
        if (babyId == -1) {
            [[AiUserManager shareInstance] userRegistWithCompletion:^(RegisterResp *result, NSError *error) {
                if (error == nil) {
                    int babyId = [AiUserManager shareInstance].babyId;
                    _reqHead = [[ReqHead alloc] initWithBabyId:babyId guid:openUdid version:VERSION];
                    
                    [[AiUserManager shareInstance] userLogin:^(int result) {
                        [self updateConfig];
                    }];
                }
            }];
        } else {
            _reqHead = [[ReqHead alloc] initWithBabyId:babyId guid:openUdid version:VERSION];
            [[AiUserManager shareInstance] userLogin:^(int result) {
                [self updateConfig];
//                NSLog(@"user login is %d",result);
            }];
        }

    }
    return self;
}

-(void)updateConfig
{
    [[AiUserManager shareInstance] updateConfig:^(UserConfig *config) {
        self.wuliuAppkey = config.appKey56;
        self.isReportFlag = config.reportFlag;
        self.searchDefaultVer = config.searchImgVer;
        if (self.searchKeyVer != config.searchKeysVer) {
            [[AiUserManager shareInstance] getSearchSuggestKeys:^(int result) {
//                NSLog(@"result is %d",result);
            }];
        }
        self.searchKeyVer = config.searchKeysVer;
    }];
}

-(void)setSearchKeyVer:(int)searchKeyVertion
{
    _searchKeyVer = searchKeyVertion;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:_searchKeyVer] forKey:@"searchKeyVer"];
}

-(int)searchKeyVer
{
    int returnKeyVer = 0;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"searchKeyVer"]) {
        returnKeyVer = [[[NSUserDefaults standardUserDefaults] valueForKey:@"searchKeyVer"] intValue];
    }
    return returnKeyVer;
}

-(void)doRequestAlbumWithSericalId:(NSString *)serialId startId:(int)startId recordNum:(int)recordNum videoTitle:(NSString *)videoTitle completion:(void (^)(NSArray *resultArray,NSError *error))completion
{
    AlbumReq *albumReq = [[AlbumReq alloc] initWithHead:_reqHead serialId:serialId startId:startId recordNum:recordNum sectionName:videoTitle];
//    NSLog(@"albumreq is %@",albumReq);
    ResourceResp *resouceResp = [[AiThriftManager shareInstance].resourceClient getAlbum:albumReq];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (resouceResp.resCode == ResponseCodeSuccess) {
//            NSLog(@"result is %@",resouceResp);
            completion(resouceResp.resList,nil);
        } else {
            if (resouceResp.resCode == -1) {
                [[AiUserManager shareInstance] userLogin:^(int result){
                    if (result == 0) {
                        [self doRequestAlbumWithSericalId:serialId startId:startId recordNum:recordNum videoTitle:videoTitle completion:completion];
                        return ;
                    }
                }];
            }
            NSError *error = [NSError errorWithDomain:@"server error" code:resouceResp.resCode userInfo:nil];
            completion(nil,error);
        }
    });
}

-(void)requestAlbumWithSerialId:(NSString *)serialId startId:(int)startId recordNum:(int)recordNum videoTitle:(NSString *)videoTitle completion:(void (^)(NSArray *resultArray,NSError *error))completion
{
    [[AiThriftManager shareInstance].queue addOperationWithBlock:^{
        @try {
            [self doRequestAlbumWithSericalId:serialId startId:startId recordNum:recordNum videoTitle:videoTitle completion:completion];
        }
        @catch (NSException *exception) {
            [[AiThriftManager shareInstance] reConnect];
            @try {
                [self doRequestAlbumWithSericalId:serialId startId:startId recordNum:recordNum videoTitle:videoTitle completion:completion];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
        }
    }];
}

-(void)requestReportWithString:(NSString *)reportString completion:(void (^)(NSArray *resultArray , NSError * error))completion
{
    if (self.isReportFlag == 0) {
        return;
    }
    ReportReq *reportReq = [[ReportReq alloc] initWithHead:_reqHead rptItem:reportString];
    [[AiThriftManager shareInstance].queue addOperationWithBlock:^{
        @try {
            NSLog(@"reportReq is %@",reportReq);
            [[AiThriftManager shareInstance].reportClient report:reportReq];
        }
        @catch (NSException *exception) {
            [[AiThriftManager shareInstance] reConnect];
            @try {
                [[AiThriftManager shareInstance].reportClient report:reportReq];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
        }
    }];
}


-(void)doRecommendWithType:(int)resourceType startId:(int)startId completion:(void (^)(NSArray *resultArray , NSError * error))completion
{
//    NSLog(@"doRecommendWithType is %d",resourceType);
    RecommendReq * recommendReq = [[RecommendReq alloc] initWithHead:_reqHead startId:startId recordNum:RecommendNum];
//    NSLog(@"recommendReq is %@",recommendReq);
    ResourceResp *resp = nil;
    if (resourceType == RESOURCE_TYPE_SONG) {
        resp = [[AiThriftManager shareInstance].resourceClient getRecommendSongs:recommendReq];
    }
    if (resourceType == RESOURCE_TYPE_CARTOON) {
        resp = [[AiThriftManager shareInstance].resourceClient getRecommendCartoons:recommendReq];
    }
    if (resourceType == RESOURCE_TYPE_TV) {
        resp = [[AiThriftManager shareInstance].resourceClient getRecommendTVs:recommendReq];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (resp.resCode == ResponseCodeSuccess) {
            NSArray * resultArray = resp.resList;
            if (completion) {
                completion(resultArray,nil);
            }
        } else {
            NSLog(@"error resp is %@",resp);
            NSError *error = [NSError errorWithDomain:@"server error" code:resp.resCode userInfo:nil];
            if (resp.resCode == -1) {
                [[AiUserManager shareInstance] userLogin:^(int result){
                    if (result == 0) {
                        [self doRecommendWithType:resourceType startId:startId completion:completion];
                        return ;
                    }
                }];
            }
            if (completion) {
                completion(nil,error);
            }
        }
    });
}

-(void)requestRecommendWithType:(int)resourceType startId:(int)startId completion:(void (^)(NSArray *resultArray , NSError * error))completion
{
    [[AiThriftManager shareInstance].queue addOperationWithBlock:^{
//        NSLog(@"startId is %d",startId);
        @try {
            [self doRecommendWithType:resourceType startId:startId completion:completion];
        }
        @catch (NSException *exception) {
            [[AiThriftManager shareInstance] reConnect];
            @try {
                [self doRecommendWithType:resourceType startId:startId completion:completion];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
        }
    }];
}

-(void)doResouceWithRequest:(SearchReq *)resourcesReq completion:(void (^)(NSArray *, NSError *))completion
{
    ResourceResp *resp = [[AiThriftManager shareInstance].resourceClient search:resourcesReq];
    if (resp.resCode == ResponseCodeSuccess) {
        NSArray * resultArray = resp.resList;
        completion(resultArray,nil);
    } else {
        NSError *error = [NSError errorWithDomain:@"server error" code:resp.resCode userInfo:nil];
        completion(nil,error);
    }
}

-(void)requestGetResourcesWithKeyWords:(NSString *)keyWords startId:(NSNumber *)startId totalSectionNum:(int)sectionNum completion:(void (^)(NSArray *, NSError *))completion
{
    [[AiThriftManager shareInstance].queue addOperationWithBlock:^(void){
        SearchReq * searchReq = [[SearchReq alloc] initWithHead:_reqHead searchKeys:keyWords startId:0 recordNum:sectionNum resourceType:RESOURCE_TYPE_CARTOON serialId:nil];
        @try {
            [self doResouceWithRequest:searchReq completion:completion];
        }
        @catch (NSException *exception) {
            [[AiThriftManager shareInstance] reConnect];
            @try {
                [self doResouceWithRequest:searchReq completion:completion];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
        }
    }];
}

-(void)doSearchWithRequest:(SearchReq *)searchReq completion:(void (^)(NSArray *, NSError *))completion
{
    ResourceResp *resp = [[AiThriftManager shareInstance].resourceClient search:searchReq];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (resp.resCode == ResponseCodeSuccess) {
            NSLog(@"resp is %@",resp);
            NSArray * resultArray = resp.resList;
            if (completion) {
                completion(resultArray,nil);
            }
        } else {
            if (resp.resCode == -1) {
                [[AiUserManager shareInstance] userLogin:^(int result){
                    if (result == 0) {
                        [self doSearchWithRequest:searchReq completion:completion];
                        return ;
                    }
                }];
            }
            NSError *error = [NSError errorWithDomain:@"server error" code:resp.resCode userInfo:nil];
            if (completion) {
                completion(nil,error);
            }
        }
    });
}

-(void)requestSearchWithKeyWords:(NSString *)keyWords startId:(NSNumber *)startId resourceType:(int)resourceType completion:(void (^)(NSArray *, NSError *))completion
{
    [[AiThriftManager shareInstance].queue addOperationWithBlock:^(void){
        SearchReq *searchReq = [[SearchReq alloc] initWithHead:_reqHead searchKeys:keyWords startId:[startId intValue] recordNum:SearchNum resourceType:resourceType serialId:nil];
        NSLog(@"------ search Req is %@",searchReq);
        @try {
            [self doSearchWithRequest:searchReq completion:completion];
        }
        @catch (NSException *exception) {
            [[AiThriftManager shareInstance] reConnect];
            @try {
                [self doSearchWithRequest:searchReq completion:completion];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
        }
    }];
}

-(void)doSearchRecommend:(void (^)(NSArray * resultArray,NSError *error))completion{
    ResourceResp *resp = [[AiThriftManager shareInstance].resourceClient getSearchRecommend:_reqHead];
//    NSLog(@"requestSearchRecommend is %@",resp);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (resp.resCode == ResponseCodeSuccess) {
            if (completion) {
                completion(resp.resList,nil);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"server error" code:resp.resCode userInfo:nil];
            if (completion) {
                completion(nil,error);
            }
        }
    });
}

-(void)requestSearchRecommend:(void (^)(NSArray * resultArray,NSError *error))completion
{
    [[AiThriftManager shareInstance].queue addOperationWithBlock:^(void){
        @try {
            NSLog(@"requestSearchRecommend!!");
            [self doSearchRecommend:completion];
        }
        @catch (NSException *exception) {
            [[AiThriftManager shareInstance] reConnect];
            @try {
                [self doSearchRecommend:completion];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
        }
    }];
}
@end
