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

@implementation AiVideoObject

-(id)initWithResourceInfo:(ResourceInfo *)resourceInfo
{
    if (self = [super init]) {
        self.title = resourceInfo.title;
        self.imageUrl = resourceInfo.img;
        self.vid = resourceInfo.url;
        self.sourceType = resourceInfo.resourceType;
        self.videoType = resourceInfo.fileType;
        self.serialId = resourceInfo.serialId;
        self.totalSectionNum = resourceInfo.SectionNum;
        self.curSectionNum = resourceInfo.curSection;
    }
    return self;
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
    if (self.sourceType == kTagPlaySourceTypeYouku) {
        NSString *urlString = [NSString stringWithFormat:@"http://v.youku.com/player/getRealM3U8/vid/%@/type/mp4/v.m3u8",self.vid];
        completion(urlString,nil);
    }
    if (self.sourceType == kTagPlaySourceType56) {
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
}

@end
