//
//  FTResponse.h
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    FTStatusOk = 0,
    FTStatusFail
};
typedef NSUInteger FTStatus;

@interface FTResponse : NSObject {
    FTStatus        _status;
    float           _timespan;
    BOOL            _authed;
    id              _authedAs;
    
    NSString        *_environment;
    
    NSDictionary    *_response;
}

@property (readonly) FTStatus       status;
@property (readonly) float          timespan;
@property (readonly) BOOL           authed;
@property (readonly) id             authedAs;
@property (readonly) NSString       *environment;
@property (readonly) NSDictionary   *response;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
