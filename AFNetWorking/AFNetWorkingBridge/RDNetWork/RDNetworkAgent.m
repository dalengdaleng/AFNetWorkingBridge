//
//  RDNetworkAgent.m
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "RDNetworkAgent.h"
#import "RDNetworkConfig.h"
#import "RDNetworkPrivate.h"
#import "AFDownloadRequestOperation.h"

@implementation RDNetworkAgent
{
    AFHTTPRequestOperationManager *_manager;
    RDNetworkConfig *_config;
    NSMutableDictionary *_requestsRecord;
}

+ (RDNetworkAgent *)sharedInstance {
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
        _config = [RDNetworkConfig sharedInstance];
        _manager = [AFHTTPRequestOperationManager manager];
        _requestsRecord = [NSMutableDictionary dictionary];
        _manager.operationQueue.maxConcurrentOperationCount = 4;
        _manager.securityPolicy = _config.securityPolicy;
    }
    return self;
}

- (NSString *)buildRequestUrl:(RDBaseRequest *)request
{
    NSString *detailUrl = [request requestUrl];
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    // filter url
    NSArray *filters = [_config urlFilters];
    for (id<RDUrlFilterProtocol> f in filters) {
        detailUrl = [f filterUrl:detailUrl withRequest:request];
    }
    
    NSString *baseUrl;
    if ([request useCDN]) {
        if ([request cdnUrl].length > 0) {
            baseUrl = [request cdnUrl];
        } else {
            baseUrl = [_config cdnUrl];
        }
    } else {
        if ([request baseUrl].length > 0) {
            baseUrl = [request baseUrl];
        } else {
            baseUrl = [_config baseUrl];
        }
    }
    return [NSString stringWithFormat:@"%@%@", baseUrl, detailUrl];
}

- (void)addRequest:(RDBaseRequest *)request {
    RDRequestMethod method = [request requestMethod];
    NSString *url = [self buildRequestUrl:request];
    id param = request.requestArgument;
    AFConstructingBlock constructingBlock = [request constructingBodyBlock];
    
    if (request.requestSerializerType == RDRequestSerializerTypeHTTP)
    {
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    else if(request.requestSerializerType == RDRequestSerializerTypeJSON)
    {
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    //返回的数据结构
    if(request.responseSerializerType == RDResponseSerializerTypeHTTP)
    {
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    else if(request.responseSerializerType == RDResponseSerializerTypeJSON)
    {
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    else if(request.responseSerializerType == RDResponseSerializerTypeXML)
    {
        _manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    }
    
    _manager.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    // if api need server username and password
    NSArray *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [_manager.requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString *)authorizationHeaderFieldArray.firstObject
                                                                   password:(NSString *)authorizationHeaderFieldArray.lastObject];
    }
    
    // if api need add custom value to HTTPHeaderField
    NSDictionary *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [_manager.requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                NSLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    
    // if api build custom url request
    NSURLRequest *customUrlRequest= [request buildCustomUrlRequest];
    if (customUrlRequest) {
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:customUrlRequest];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleRequestResult:operation];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleRequestResult:operation];
        }];
        request.requestOperation = operation;
        operation.responseSerializer = _manager.responseSerializer;
        [_manager.operationQueue addOperation:operation];
    } else {
        if (method == RDRequestMethodGet) {
            if (request.resumableDownloadPath) {
                // add parameters to URL;
                NSString *filteredUrl = [RDNetworkPrivate urlStringWithOriginUrlString:url appendParameters:param];
                
                NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:filteredUrl]];
                AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:requestUrl
                                                                                                 targetPath:request.resumableDownloadPath shouldResume:YES];
                [operation setProgressiveDownloadProgressBlock:request.resumableDownloadProgressBlock];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self handleRequestResult:operation];
                }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self handleRequestResult:operation];
                }];
                request.requestOperation = operation;
                [_manager.operationQueue addOperation:operation];
            } else {
                request.requestOperation = [_manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self handleRequestResult:operation];
                }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self handleRequestResult:operation];
                }];
            }
        } else if (method == RDRequestMethodPost) {
            if (constructingBlock != nil) {
                request.requestOperation = [_manager POST:url parameters:param constructingBodyWithBlock:constructingBlock
                                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                      [self handleRequestResult:operation];
                                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                      [self handleRequestResult:operation];
                                                  }];
            } else {
                request.requestOperation = [_manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self handleRequestResult:operation];
                }                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self handleRequestResult:operation];
                }];
            }
        } else if (method == RDRequestMethodHead) {
            request.requestOperation = [_manager HEAD:url parameters:param success:^(AFHTTPRequestOperation *operation) {
                [self handleRequestResult:operation];
            }                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self handleRequestResult:operation];
            }];
        } else if (method == RDRequestMethodPut) {
            request.requestOperation = [_manager PUT:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self handleRequestResult:operation];
            }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self handleRequestResult:operation];
            }];
        } else if (method == RDRequestMethodDelete) {
            request.requestOperation = [_manager DELETE:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self handleRequestResult:operation];
            }                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self handleRequestResult:operation];
            }];
        } else if (method == RDRequestMethodPatch) {
            request.requestOperation = [_manager PATCH:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self handleRequestResult:operation];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self handleRequestResult:operation];
            }];
        } else {
            NSLog(@"Error, unsupport method type");
            return;
        }
    }
    
    NSLog(@"Add request: %@", NSStringFromClass([request class]));
    [self addOperation:request];
}

- (void)cancelRequest:(RDBaseRequest *)request {
    [request.requestOperation cancel];
    [self removeOperation:request.requestOperation];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        RDBaseRequest *request = copyRecord[key];
        [request stop];
    }
}

- (BOOL)checkResult:(RDBaseRequest *)request {
    BOOL result = [request statusCodeValidator];
    if (!result) {
        return result;
    }
    id validator = [request jsonValidator];
    if (validator != nil) {
        id json = [request responseJSONObject];
        result = [RDNetworkPrivate checkJson:json withValidator:validator];
    }
    return result;
}

- (void)handleRequestResult:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    RDBaseRequest *request = _requestsRecord[key];
    NSLog(@"Finished Request: %@", NSStringFromClass([request class]));
    if (request) {
        BOOL succeed = [self checkResult:request];
        if (succeed) {
            [request toggleAccessoriesWillStopCallBack];
            [request requestCompleteFilter];
            if (request.delegate != nil) {
                [request.delegate requestFinished:request];
            }
            if (request.successCompletionBlock) {
                request.successCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        } else {
            NSLog(@"Request %@ failed, status code = %ld",
                   NSStringFromClass([request class]), (long)request.responseStatusCode);
            [request toggleAccessoriesWillStopCallBack];
            [request requestFailedFilter];
            if (request.delegate != nil) {
                [request.delegate requestFailed:request];
            }
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        }
    }
    [self removeOperation:operation];
    [request clearCompletionBlock];
}

- (NSString *)requestHashKey:(AFHTTPRequestOperation *)operation {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[operation hash]];
    return key;
}

- (void)addOperation:(RDBaseRequest *)request {
    if (request.requestOperation != nil) {
        NSString *key = [self requestHashKey:request.requestOperation];
        @synchronized(self) {
            _requestsRecord[key] = request;
        }
    }
}

- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
    }
    NSLog(@"Request queue size = %lu", (unsigned long)[_requestsRecord count]);
}

@end
