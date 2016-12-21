//
//  RDDownloadFontListTask.m
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/15.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "RDDownloadFontListTask.h"

@implementation RDDownloadFontListTask
- (NSString *)requestUrl {
    return @"/fonts.atom";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    return @{@"Content-Type":@"application/atom+xml"};
}

- (RDResponseSerializerType)responseSerializerType{
    return RDResponseSerializerTypeXML;
}
@end
