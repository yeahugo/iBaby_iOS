//
//  AiVideoObject.m
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiVideoObject.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworking.h"
#import "shy.h"
//#import "AiVideoPlayerManager.h"
#import "AiNormalPlayerViewController.h"
#import "AiDataRequestManager.h"
#import "AiUserManager.h"
#import "AiWebViewPlayerController.h"

#define kTagPlayerControlView 100

@implementation AiVideoObject

-(id)initWithResourceInfo:(ResourceInfo *)resourceInfo
{
    if (self = [super init]) {
        self.title = resourceInfo.title;
        self.playUrl = resourceInfo.url;
        self.imageUrl = resourceInfo.img;
        self.vid = resourceInfo.vid;
        self.sourceType = resourceInfo.sourceType;
        self.resourceType = resourceInfo.resourceType;
        self.serialId = resourceInfo.serialId;
        self.totalSectionNum = resourceInfo.sectionNum;
        self.curSectionNum = resourceInfo.curSection;
        self.status = resourceInfo.status;
        self.serialDes = resourceInfo.serialDes;
        self.serialTitle = resourceInfo.serialName;
        self.durationTime = resourceInfo.durationTime;
    }
    return self;
}

-(void)playVideo
{
    [[AiDataRequestManager shareInstance] requestReportWithString:[NSString stringWithFormat:@"P\t%d\n%@",self.sourceType,self.vid] completion:nil];
    if (self.sourceType == RESOURCE_SOURCE_TYPE_RESOURCE_SOURCE_YOUKU && ![AiDataRequestManager shareInstance].isYoukuUseUrl) {
        UIApplication *shareApplication = [UIApplication sharedApplication];
        AiWebViewPlayerController *viewController = [[AiWebViewPlayerController alloc] initWithAiVideoObject:self];
        [shareApplication.keyWindow.rootViewController presentModalViewController:viewController animated:YES];
    } else {
        [self getSongUrlWithCompletion:^(NSString *urlString,NSError *error){
            NSLog(@"url is %@",urlString);
            if (error == nil) {
                self.playUrl = urlString;
//                AiPlayerViewController *playViewController = [[AiPlayerViewController alloc] init];
                AiNormalPlayerViewController *playViewController = [[AiNormalPlayerViewController alloc] initWithAiVideoObject:self];
                UIApplication *shareApplication = [UIApplication sharedApplication];
                [shareApplication.keyWindow.rootViewController presentModalViewController:playViewController animated:YES];
            } else {
                NSLog(@"error is %@",error);
            }
        }];
    }
}

- (NSString *)md5Value:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    NSString *returnString = [NSString stringWithFormat:
                              @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                              result[0], result[1], result[2], result[3],
                              result[4], result[5], result[6], result[7],
                              result[8], result[9], result[10], result[11],
                              result[12], result[13], result[14], result[15]
                              ];
    returnString = [returnString lowercaseString];
    return returnString;
}

-(void)getSongUrlWithCompletion:(void (^)(NSString *urlString,NSError *error))completion
{
    if (self.sourceType == RESOURCE_SOURCE_TYPE_RESOURCE_SOURCE_YOUKU) {
        NSString *urlString = self.playUrl;
        completion(urlString,nil);
    }
    if (self.sourceType == RESOURCE_SOURCE_TYPE_RESOURCE_SOURCE_56) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        int timeInteval = (int)[[NSDate date] timeIntervalSince1970];
        NSString *vidString = [NSString stringWithFormat:@"vid=%@",self.vid];
        NSString *appKey56 = [AiDataRequestManager shareInstance].wuliuAppkey;
        if (appKey56 == nil) {
            appKey56 = @"3000003910";
        }
        NSString *secret56 = [AiDataRequestManager shareInstance].wuliuSecret;
        if (secret56 == nil) {
            secret56 = @"b7ed6e59906c4fa5";
        }
        NSString *signString = [NSString stringWithFormat:@"%@#%@#%@#%d",[self md5Value:vidString],appKey56,secret56,timeInteval];
        NSString *md5SignString = [self md5Value:signString];
        NSString *urlString = [NSString stringWithFormat:@"http://oapi.56.com/video/mobile.json?appkey=%@&ts=%d&vid=%@&sign=%@",appKey56,timeInteval,self.vid,md5SignString];
        NSLog(@"request url is %@",urlString);
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"result is %@",responseObject);
            NSDictionary * resourceInfo = [responseObject valueForKey:@"info"];
            int index = [[resourceInfo valueForKey:@"rfiles"] count]-1;
            NSString *urlString = [[[resourceInfo valueForKey:@"rfiles"] objectAtIndex:index] valueForKey:@"url"];
            completion(urlString,nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(urlString,error);
            NSLog(@"Error: %@", error);
        }];
    }
    if (self.sourceType == RESOURCE_SOURCE_TYPE_RESOURCE_SOURCE_SOHU) {
        NSString *urlString = self.playUrl;
        completion(urlString,nil);
    }
    if (self.sourceType == RESOURCE_SOURCE_TYPE_RESOURCE_SOURCE_CNTV) {
        NSString *urlString = self.playUrl;
        completion(urlString,nil);
    }
    if (self.sourceType == RESOURCE_SOURCE_TYPE_RESOURCE_SOURCE_SHY) {
        NSString *urlString = self.playUrl;
        completion(urlString,nil);
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    AiVideoObject * aiVideoObject = [[AiVideoObject allocWithZone:zone] init];
    aiVideoObject.playUrl = _playUrl;
    aiVideoObject.title = _title;
    aiVideoObject.imageUrl = _imageUrl;
    aiVideoObject.vid = _vid;
    aiVideoObject.sourceType = _sourceType;
    aiVideoObject.resourceType = _resourceType;
    aiVideoObject.serialId = _serialId;
    aiVideoObject.totalSectionNum = _totalSectionNum;
    aiVideoObject.playUrl = _playUrl;
    aiVideoObject.status = _status;
    aiVideoObject.serialDes = _serialDes;
    aiVideoObject.serialTitle = _serialTitle;
    aiVideoObject.curSectionNum = _curSectionNum;
    aiVideoObject.durationTime = _durationTime;
    return aiVideoObject;
}

@end
