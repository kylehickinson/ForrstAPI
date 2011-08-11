//
//  FTResponse.m
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import "FTResponse.h"
#import "FTConstants.h"

@implementation FTResponse
@synthesize status      = _status,
            timespan    = _timespan,
            authed      = _authed,
            authedAs    = _authedAs,
            response    = _response,
            environment = _environment;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        
        if ([[dictionary objectForKey:@"stat"] isEqualToString:@"ok"]) {
            _status = FTStatusOk;
        } else {
            _status = FTStatusFail;
        }
        
        _timespan = [[dictionary objectForKey:@"in"] floatValue];
        _authed = [[dictionary objectForKey:@"authed"] boolValue];
        if (_authed) {
            _authedAs = [dictionary objectForKey:@"authed_as"];
#if !USING_ARC
            [_authedAs retain];
#endif
        } else {
            _authedAs = nil;
        }
        
        _environment = [[dictionary objectForKey:@"env"] copy];
        _response = [[NSDictionary alloc] initWithDictionary:[dictionary objectForKey:@"resp"]];
        
#if FT_API_LOG
        NSLog(@"FTResponse (%p) - initWithDictionary:%@", self, dictionary);
#endif
    }
    return self;
}

- (void)dealloc {
    FT_RELEASE(_environment);
    FT_RELEASE(_response);
    FT_RELEASE(_authedAs);
    
    [super dealloc];
}

@end
