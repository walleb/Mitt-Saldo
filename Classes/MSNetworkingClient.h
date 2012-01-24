//
//  MSNetworkingClient.h
//  MittSaldo
//
//  Created by  on 12/4/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface MSNetworkingClient : NSObject
+ (MSNetworkingClient *)sharedClient;
- (void)postRequestWithURL:(NSURL *)url andParameters:(NSDictionary *)parameters completionBlock:(void (^)(AFHTTPRequestOperation *requestOperation))block;
- (void)getRequestWithURL:(NSURL *)url completionBlock:(void (^)(AFHTTPRequestOperation *requestOperation))block;

@property (nonatomic, retain) NSOperationQueue *operationQueue;
@end
