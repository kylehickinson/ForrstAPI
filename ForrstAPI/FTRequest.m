//
//  FTRequest.m
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import "FTRequest.h"
#import "JSONKit.h"
#import "FTConstants.h"

#import <UIKit/UIApplication.h>

@interface FTRequest ()
- (void)_request:(NSURL *)url type:(FTRequestType)type completion:(void (^)(FTResponse *response))completion fail:(void (^)(NSError *error))fail;
@end

@implementation FTRequest
@synthesize connection  = _connection,
            request     = _request,
            onCompletion = _onCompletion,
            onFail      = _onFail;

- (id)init {
    if ((self = [super init])) {        
        _requestData    = [[NSMutableData alloc] init];
        _onCompletion   = nil;
        _onFail         = nil;
    }
    return self;
}

- (void)dealloc {
    FT_RELEASE(_connection);
    FT_RELEASE(_request);
    FT_RELEASE(_requestData);
    
    self.onCompletion = nil;
    self.onFail = nil;
    
#if !USING_ARC
    [super dealloc]; 
#endif
}

- (void)_request:(NSURL *)url type:(FTRequestType)type completion:(NSCompletionBlock)completion fail:(void (^)(NSError *error))fail {
    _request = [[NSMutableURLRequest alloc] init];
    [_request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_request setValue:FT_API_USERAGENT forHTTPHeaderField:@"User-Agent"];
    
    switch (type) {
        case FTRequestTypeGet:
            [_request setHTTPMethod:@"GET"];
            [_request setURL:url];
            break;
        case FTRequestTypePost: {
            // Apparently the URL isn't formatted properly? Wtf.  Oh well, manually getting the parameters and base url.
            [_request setHTTPMethod:@"POST"];
            
            NSString *s = [url absoluteString];
            NSRange r = [s rangeOfString:@"?"];
            
            NSString *parameters = [[s substringFromIndex:r.location+1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            NSString *base = [s substringToIndex:r.location];
            
            NSData *postData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            [_request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
            [_request setHTTPBody:postData];
            [_request setURL:[NSURL URLWithString:base]];
            break;
        }
        case FTRequestTypePut:
            // Not going to implement this until the API actually needs it.
            [_request setHTTPMethod:@"PUT"];
            [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
    }
#if FT_API_LOG
    NSLog(@"FTRequest (%p) - _request:%@ type:%d (%@) completion:%@ fail:%@", self, url, type, [_request HTTPMethod], completion, fail);
#endif
    
    self.onCompletion = completion;
    self.onFail = fail;
    
    if ([NSURLConnection canHandleRequest:_request]) {
        _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:YES];
        if (_connection) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    } else {
        self.onFail([NSError errorWithDomain:FTErrorDomainFailedRequest code:FTErrorDomainFailedRequestCode userInfo:nil]);
    }
}

+ (void)request:(NSURL *)url type:(FTRequestType)type completion:(NSCompletionBlock)completion fail:(void (^)(NSError *error))fail {
    FTRequest *request = [[FTRequest alloc] init];
    [request _request:url type:type completion:completion fail:fail];
    [request autorelease];
}

#pragma mark - NSConnection

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.onFail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.onFail(error);
        });
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
#if FT_API_LOG
    NSLog(@"FTRequest (%p) - connection:%@ didFailWithError:%@", self, connection, error);
#endif
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_requestData appendData:data];
#if FT_API_LOG
    NSLog(@"FTRequest (%p) - connection:%@ didReceiveData:%@", self, connection, data);
#endif
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
#if FT_API_LOG
    NSLog(@"FTRequest (%p) - connection:%@ didResceiveResponse:%@", self, connection, response);
#endif
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
#if FT_API_LOG
    NSLog(@"FTRequest (%p) - connectionDidFinishLoading:%@", self, connection);
#endif
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    JSONDecoder *_decoder = [[JSONDecoder alloc] init];
    NSDictionary *results = [_decoder objectWithData:_requestData];
    
    if (!results) { 
        if (self.onFail) {
            self.onFail([NSError errorWithDomain:FTErrorDomainInvalidResults code:FTErrorDomainInvalidResultsCode userInfo:results]);
        }
#if !USING_ARC
        [_decoder release];
#endif
        return;
    }
    
    FTResponse *response = [[FTResponse alloc] initWithDictionary:results];
    
    if (response.status == FTStatusFail) {
        if (self.onFail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.onFail([NSError errorWithDomain:FTErrorDomainStatusFail code:FTErrorDomainStatusFailCode userInfo:results]);
            });
        }
    } else {
        if (self.onCompletion) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                self.onCompletion(response);
            });
        }
    }
    
#if !USING_ARC
    [response autorelease];
    [_decoder release];
#endif

}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

@end
