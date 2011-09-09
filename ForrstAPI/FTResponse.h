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

@interface FTResponse : NSObject

@property (readonly) FTStatus       status;
@property (readonly) float          timespan;
@property (readonly) BOOL           authed;
@property (strong) NSArray        *authedAs;
@property (strong) NSString       *environment;
@property (strong) NSDictionary   *response;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
