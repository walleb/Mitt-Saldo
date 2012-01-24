//
//  MSNetworkingClient.m
//  MittSaldo
//
//  Created by  on 12/4/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import "MSNetworkingClient.h"

@implementation MSNetworkingClient
@synthesize operationQueue = _operationQueue;

+ (MSNetworkingClient *)sharedClient 
{
    static MSNetworkingClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
    if ((self = [super init])) {
        self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
    }
    
    return self;
}

- (void)setDefaultHeadersForRequest:(NSMutableURLRequest *)request
{
    [request setValue:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	// Apply request cookies
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[request.URL absoluteURL]];
	if ([cookies count] > 0) {
		NSHTTPCookie *cookie;
		NSString *cookieHeader = nil;
		for (cookie in cookies) {
			if (!cookieHeader) {
				cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie value]];
			} else {
				cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
			}
		}
		if (cookieHeader) {
			[request setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
		}
	}
}

- (void)enqueueRequest:(NSMutableURLRequest *)request completionBlock:(void (^)(AFHTTPRequestOperation *requestOperation))block
{
    AFHTTPRequestOperation *postOperation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
    postOperation.completionBlock = ^ {
        // Handle cookies and store them in the global persistent store
        NSArray *newCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[postOperation.response allHeaderFields] forURL:postOperation.request.URL];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:newCookies forURL:postOperation.request.URL mainDocumentURL:nil];
        
        if (block) {
            block(postOperation);
        }
    };
    
    [self.operationQueue addOperation:postOperation];
}

- (void)postRequestWithURL:(NSURL *)url andParameters:(NSDictionary *)parameters completionBlock:(void (^)(AFHTTPRequestOperation *requestOperation))block
{
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
    [postRequest setHTTPMethod:@"POST"];
    [self setDefaultHeadersForRequest:postRequest];
    [postRequest setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))] forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPBody:[AFQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding) dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self enqueueRequest:postRequest completionBlock:block];
}

- (void)getRequestWithURL:(NSURL *)url completionBlock:(void (^)(AFHTTPRequestOperation *requestOperation))block
{
    NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL:url];
    [getRequest setHTTPMethod:@"GET"];
    [self setDefaultHeadersForRequest:getRequest];
    
    [self enqueueRequest:getRequest completionBlock:block];    
}

@end
