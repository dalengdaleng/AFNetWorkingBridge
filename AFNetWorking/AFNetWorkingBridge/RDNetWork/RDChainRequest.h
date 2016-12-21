//
//  RDChainRequest.h
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDBaseRequest.h"

@class RDChainRequest;
@protocol RDChainRequestDelegate <NSObject>

@optional
- (void)chainRequestFinished:(RDChainRequest *)chainRequest;

- (void)chainRequestFailed:(RDChainRequest *)chainRequest failedBaseRequest:(RDBaseRequest*)request;

@end

typedef void (^ChainCallback)(RDChainRequest *chainRequest, RDBaseRequest *baseRequest);

@interface RDChainRequest : NSObject
@property (weak, nonatomic) id<RDChainRequestDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *requestAccessories;

/// start chain request
- (void)start;

/// stop chain request
- (void)stop;

- (void)addRequest:(RDBaseRequest *)request callback:(ChainCallback)callback;

- (NSArray *)requestArray;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<RDRequestAccessory>)accessory;
@end

@interface RDChainRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

