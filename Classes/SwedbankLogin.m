//
//  Created by Björn Sållarp on 2011-04-12.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "SwedbankLogin.h"
#import "MSNetworkingClient.h"
#import "MittSaldoSettings.h"
#import "SwedbankLoginParser.h"

NSString * const kMSSwedbankLoginURL = @"https://mobilbank.swedbank.se/banking/swedbank/login.html";

@interface SwedbankLogin ()
- (void)loginStepTwo;
- (void)loginStepThree;
- (void)postLoginWithCompletionBlock:(void (^)(AFHTTPRequestOperation *requestOperation))block;
- (void)reportFailure:(NSString *)failure;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) SwedbankLoginParser *loginParser;
@property (nonatomic, copy) MSBankLoginSuccessBlock successBlock;
@property (nonatomic, copy) MSBankLoginFailureBlock failureBlock;
@end

@implementation SwedbankLogin
@synthesize username = _username;
@synthesize password = _password;
@synthesize loginParser = _loginParser;
@synthesize successBlock = _successBlock;
@synthesize failureBlock = _failureBlock;

-(void)dealloc
{
    [_successBlock release];
    [_failureBlock release];
    [_password release];
    [_username release];
    [_loginParser release];
	[super dealloc];
}

+ (id)swedbankLoginWithUsername:(NSString *)username andPassword:(NSString *)password
{
    SwedbankLogin *login = [[self alloc] init];
    login.username = username;
    login.password = password;
    
    return [login autorelease];
}

- (void)performLoginWithSuccessBlock:(MSBankLoginSuccessBlock)success failure:(MSBankLoginFailureBlock)failure 
{
    self.loginParser = [[[SwedbankLoginParser alloc] init] autorelease];
    self.successBlock = success;
    self.failureBlock = failure;
    
    NSURL *loginUrl = [NSURL URLWithString:kMSSwedbankLoginURL];
    [[MSNetworkingClient sharedClient] getRequestWithURL:loginUrl completionBlock:^(AFHTTPRequestOperation *requestOperation) {
        if ([requestOperation hasAcceptableStatusCode]) {
            
            if ([self.loginParser parseXMLData:requestOperation.responseData parseError:nil]) {
                if (self.loginParser.csrf_token == nil || [self.loginParser.csrf_token isEqualToString:@""]) {
                    [self reportFailure:@"Kunde inte avkoda inloggningsformuläret"];
                }
                else {                    
                    [self loginStepTwo];                    

                }
            }
        }
        else {
            [self reportFailure:[requestOperation.error localizedDescription]];
        }
    }];
}

- (void)loginStepTwo
{
   [self postLoginWithCompletionBlock:^(AFHTTPRequestOperation *requestOperation) {
       if ([requestOperation hasAcceptableStatusCode]) {
           [self.loginParser parseXMLData:requestOperation.responseData parseError:nil];
           
           if (self.loginParser.passwordField) {
               [self loginStepThree];
           }
           else {
               [self reportFailure:@"Kunde inte avkoda inloggningsformuläret"];
           }
       } 
       else {
           [self reportFailure:[requestOperation.error localizedDescription]];
       }
   }];
}

- (void)loginStepThree
{
    [self postLoginWithCompletionBlock:^(AFHTTPRequestOperation *requestOperation) {
        if ([requestOperation hasAcceptableStatusCode]) {
            
            if ([requestOperation.responseString rangeOfString:@"_csrf_token"].length > 0) {
                [self reportFailure:nil];
            }
            else {
                if (self.successBlock) {
                    self.successBlock();
                }
            }
        } 
        else {
            [self reportFailure:[requestOperation.error localizedDescription]];
        }
    }];
}

- (void)postLoginWithCompletionBlock:(void (^)(AFHTTPRequestOperation *requestOperation))block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.username forKey:self.loginParser.usernameField];
    [params setValue:self.loginParser.csrf_token forKey:@"_csrf_token"];
    [params setValue:@"code" forKey:@"auth-method"];
    
    if (self.loginParser.passwordField) {
        [params setValue:self.password forKey:self.loginParser.passwordField];
    }
    
    NSURL *postUrl = [NSURL URLWithString:self.loginParser.nextLoginStepUrl relativeToURL:[NSURL URLWithString:kMSSwedbankLoginURL]];
    [[MSNetworkingClient sharedClient] postRequestWithURL:postUrl andParameters:params completionBlock:block];
}

- (void)reportFailure:(NSString *)failure
{
    if (self.failureBlock) {
        self.failureBlock(failure);
    }
}

@end
