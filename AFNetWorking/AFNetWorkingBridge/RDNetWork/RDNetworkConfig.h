//
//  RDNetworkConfig.h
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDBaseRequest.h"

@protocol RDUrlFilterProtocol <NSObject>
- (NSString *)filterUrl:(NSString *)originUrl withRequest:(RDBaseRequest *)request;
@end

@protocol RDCacheDirPathFilterProtocol <NSObject>
- (NSString *)filterCacheDirPath:(NSString *)originPath withRequest:(RDBaseRequest *)request;
@end

@interface RDNetworkConfig : NSObject

+ (RDNetworkConfig *)sharedInstance;

@property (strong, nonatomic) NSString *baseUrl;
@property (strong, nonatomic) NSString *cdnUrl;
@property (strong, nonatomic, readonly) NSArray *urlFilters;
@property (strong, nonatomic, readonly) NSArray *cacheDirPathFilters;
@property (strong, nonatomic) AFSecurityPolicy *securityPolicy;

- (void)addUrlFilter:(id<RDUrlFilterProtocol>)filter;
- (void)addCacheDirPathFilter:(id <RDCacheDirPathFilterProtocol>)filter;

@end
