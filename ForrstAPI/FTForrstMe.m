//
//  FTForrstMe.m
//  Leef
//
//  Created by Kyle Hickinson on 11-08-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import "FTForrstMe.h"
#import "FTConstants.h"


@interface FTForrstMe ()
@property (strong) NSDictionary *data;
@end

@implementation FTForrstMe
@synthesize contact = _contact;
@synthesize domain = _domain;

@synthesize data = _data;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init])) {
        self.data = dictionary;
    }
    return self;
}

#if !USING_ARC
- (void)dealloc
{
    self.data = nil;
    [_domain release], _domain = nil;
    
    [super dealloc];
}
#endif

- (void)socialInfoFor:(FTMeSocial)network info:(FTSocialInfoReturnBlock)info 
{   
    NSArray *social = [[NSArray alloc] initWithObjects:@"aim", @"digg", @"dribbble", @"facebook", @"flickr", 
                       @"foursquare", @"github", @"gowalla", @"gtalk", @"linkedin", @"rdio", @"tumblr",
                       @"vimeo", @"yahoo", nil];
    
    NSDictionary *_info = [[self.data objectForKey:@"social"] objectForKey:[social objectAtIndex:network]];
    if (_info && info) {
        info([_info objectForKey:@"name"], [NSURL URLWithString:[_info objectForKey:@"url"]]);
    }
    
#if !USING_ARC
    [social release];
#endif
}

@end
