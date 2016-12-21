//
//  RDBatchRequestAgent.m
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "RDBatchRequestAgent.h"

@interface RDBatchRequestAgent()
@property (strong, nonatomic) NSMutableArray *requestArray;
@end

@implementation RDBatchRequestAgent
+ (RDBatchRequestAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (id)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addBatchRequest:(RDBatchRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeBatchRequest:(RDBatchRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}
@end
