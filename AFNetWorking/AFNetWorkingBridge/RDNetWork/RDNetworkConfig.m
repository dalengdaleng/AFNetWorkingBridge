//
//  RDNetworkConfig.m
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "RDNetworkConfig.h"

@implementation RDNetworkConfig
{
    NSMutableArray *_urlFilters;
    NSMutableArray *_cacheDirPathFilters;
}


+ (RDNetworkConfig *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _urlFilters = [NSMutableArray array];
        _cacheDirPathFilters = [NSMutableArray array];
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        
        self.baseUrl = @"http://easyread.163.com";
    }
    return self;
}

- (void)addUrlFilter:(id<RDUrlFilterProtocol>)filter {
    [_urlFilters addObject:filter];
}

- (void)addCacheDirPathFilter:(id<RDCacheDirPathFilterProtocol>)filter {
    [_cacheDirPathFilters addObject:filter];
}

- (NSArray *)urlFilters
{
    return [_urlFilters copy];
}

- (NSArray *)cacheDirPathFilters
{
    return [_cacheDirPathFilters copy];
}

@end
