//
//  FTNotification.m
//  Leef
//
//  Created by Kyle Hickinson on 11-09-08.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FTNotification.h"

#define FTAssertDictionary() (!self.dictionary)

@interface FTNotification ()
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@end

@implementation FTNotification
@synthesize dictionary = _dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init])) {
        _dictionary = [dictionary mutableCopy];
    }
    return self;
}

#if !USING_ARC
- (void)dealloc
{
    self.dictionary = nil;
    
    [super dealloc];
}
#endif

- (NSInteger)notificationID
{
    if (FTAssertDictionary()) return 0;
    
    return [[self.dictionary objectForKey:@"id"] integerValue];
}

- (NSDate *)timestamp
{
    if (FTAssertDictionary()) return nil;
    
    NSInteger _timestamp = [[self.dictionary objectForKey:@"timestamp"] integerValue];
    return [NSDate dateWithTimeIntervalSince1970:_timestamp];
}

- (NSString *)behavior
{
    if (FTAssertDictionary()) return nil;
    
    return [self.dictionary objectForKey:@"behavior"];
}

- (NSInteger)userID
{
    if (FTAssertDictionary()) return 0;
    return [[self.dictionary objectForKey:@"for_user_id"] integerValue];
}

- (NSString *)objectType
{
    if (FTAssertDictionary()) return nil;
    return [self.dictionary objectForKey:@"object_type"];
}

- (NSInteger)objectID
{
    if (FTAssertDictionary()) return 0;
    return [[self.dictionary objectForKey:@"object_id"] integerValue];
}

- (NSString *)actor
{
    if (FTAssertDictionary()) return nil;
    return [[self.dictionary objectForKey:@"data"] objectForKey:@"actor"];
}

- (NSURL *)actorURL
{
    if (FTAssertDictionary()) return nil;
    return [NSURL URLWithString:[[self.dictionary objectForKey:@"data"] objectForKey:@"actor_url"]];
}

- (NSURL *)objectURL
{
    if (FTAssertDictionary()) return nil;
    return [NSURL URLWithString:[[self.dictionary objectForKey:@"data"] objectForKey:@"object_url"]];
}

- (NSString *)postType
{
    if (FTAssertDictionary()) return nil;
    return [[self.dictionary objectForKey:@"data"] objectForKey:@"post_type"];
}

- (NSString *)postTitle
{
    if (FTAssertDictionary()) return nil;
    return [[self.dictionary objectForKey:@"data"] objectForKey:@"post_title"];
}

- (NSURL *)actorAvatarThumbURL
{
    if (FTAssertDictionary()) return nil;
    return [NSURL URLWithString:[[self.dictionary objectForKey:@"data"] objectForKey:@"photo"]];
}

@end
