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
#import "AiVideoPlayerManager.h"

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
        self.videoType = resourceInfo.resourceType;
        self.serialId = resourceInfo.serialId;
        self.totalSectionNum = resourceInfo.sectionNum;
        self.curSectionNum = resourceInfo.curSection;
        self.status = resourceInfo.status;
        self.serialDes = resourceInfo.serialDes;
        self.serialTitle = resourceInfo.serialName;
    }
    return self;
}

-(void)playVideo
{
    [self getSongUrlWithCompletion:^(NSString *urlString,NSError *error){
        if (error == nil) {
            [AiVideoPlayerManager shareInstance].currentVideoObject = self;
            AiPlayerViewController *playViewController = [[AiPlayerViewController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
            [AiVideoPlayerManager shareInstance].aiPlayerViewController = playViewController;
            self.playUrl = urlString;
            UIApplication *shareApplication = [UIApplication sharedApplication];
            [shareApplication.keyWindow.rootViewController presentMoviePlayerViewControllerAnimated:playViewController];
        } else {
            NSLog(@"error is %@",error);
        }
    }];
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
        NSString *urlString = [NSString stringWithFormat:@"http://v.youku.com/player/getRealM3U8/vid/%@/type/mp4/v.m3u8",self.vid];
        completion(urlString,nil);
    }
    if (self.sourceType == RESOURCE_SOURCE_TYPE_RESOURCE_SOURCE_56) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        int timeInteval = (int)[[NSDate date] timeIntervalSince1970];
        NSString *vidString = [NSString stringWithFormat:@"vid=%@",self.vid];
        NSString *signString = [NSString stringWithFormat:@"%@#3000003910#b7ed6e59906c4fa5#%d",[self md5Value:vidString],timeInteval];
        NSString *md5SignString = [self md5Value:signString];
        NSString *urlString = [NSString stringWithFormat:@"http://oapi.56.com/video/mobile.json?appkey=3000003910&ts=%d&vid=%@&sign=%@",timeInteval,self.vid,md5SignString];
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary * resourceInfo = [responseObject valueForKey:@"info"];
            NSLog(@"rfiles is %@ resourceInfo is %@",[resourceInfo valueForKey:@"rfiles"],resourceInfo);
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
    if (self.sourceType == RESOURCE_SOURCE_TYPE_RESOURCE_SOURCE_SHY) {
        NSLog(@"playurl is %@",self.playUrl);
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
    aiVideoObject.videoType = _videoType;
    aiVideoObject.serialId = _serialId;
    aiVideoObject.totalSectionNum = _totalSectionNum;
    aiVideoObject.playUrl = _playUrl;
    aiVideoObject.status = _status;
    aiVideoObject.serialDes = _serialDes;
    aiVideoObject.serialTitle = _serialTitle;
    aiVideoObject.curSectionNum = _curSectionNum;
    return aiVideoObject;
}

@end
