//
//  FTRequest.m
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import "FTRequest.h"
#import "JSONKit.h"

@interface FTRequest (Private)
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
    
    [super dealloc];
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
            [_request setHTTPMethod:@"POST"];
            NSData *postData = [[[url parameterString] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] dataUsingEncoding:NSASCIIStringEncoding  allowLossyConversion:YES];
            [_request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
            [_request setHTTPBody:postData];
            [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [_request setURL:[url baseURL]];
            break;
        }
        case FTRequestTypePut:
            [_request setHTTPMethod:@"PUT"];
            [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
    }
#if FT_API_LOG
    NSLog(@"FTRequest (%p) - _request:%@ type:%d (%@) completion:%@ fail:%@", self, url, type, [_request HTTPMethod], completion, fail);
#endif
    
    self.onCompletion = completion;
    self.onFail = fail;
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:YES];
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

#if FT_API_LOG
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"FTRequest (%p) - connection:%@ didResceiveResponse:%@", self, connection, response);
}
#endif

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
#if FT_API_LOG
    NSLog(@"FTRequest (%p) - connectionDidFinishLoading:%@", self, connection);
#endif
    
    JSONDecoder *_decoder = [[JSONDecoder alloc] init];
    if (self.onCompletion) {
        FTResponse *response = [[FTResponse alloc] initWithDictionary:[_decoder objectWithData:_requestData]];
        dispatch_async(dispatch_get_main_queue(), ^ {
            self.onCompletion(response);
        });
        [response release];
    }
    [_decoder release];
}

@end
