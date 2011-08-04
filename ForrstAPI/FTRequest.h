//
//  FTRequest.h
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTResponse.h"

#define FTErrorDomainStatusFail             @"FTErrorDomainStatusFail"
#define FTErrorDomainStatusFailCode         -1

#define FTErrorDomainInvalidResults         @"FTERrorDomainInvalidResults" 
#define FTErrorDomainInvalidResultsCode     -2

#define FTErrorDomainFailedRequest          @"FTErrorDomainFailedRequest"
#define FTErrorDomainFailedRequestCode      -3

enum {
    FTRequestTypeGet = 0,
    FTRequestTypePost,
    FTRequestTypePut
};
typedef NSUInteger FTRequestType;

typedef void (^NSFailBlock)(NSError *error);
typedef void (^NSCompletionBlock)(FTResponse *response);

@interface FTRequest : NSObject {
    NSURLConnection         *_connection;
    NSMutableURLRequest     *_request;
    
    NSMutableData           *_requestData;

    NSCompletionBlock       _onCompletion;
    NSFailBlock             _onFail;
}

@property (readonly) NSURLConnection    *connection;
@property (readonly) NSURLRequest       *request;

@property (nonatomic, copy) NSCompletionBlock onCompletion;
@property (nonatomic, copy) NSFailBlock onFail;

+ (void)request:(NSURL *)url type:(FTRequestType)type completion:(void (^)(FTResponse *response))completion fail:(void (^)(NSError *error))fail;

@end
