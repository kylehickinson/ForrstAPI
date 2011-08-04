//
//  FTForrstMe.h
//  Leef
//
//  Created by Kyle Hickinson on 11-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FTSocialInfoReturnBlock)(NSString *name, NSURL *url);

enum {
    FTMeSocialAIM = 0,
    FTMeSocialDigg,
    FTMeSocialDribbble,
    FTMeSocialFacebook,
    FTMeSocialFlickr,
    FTMeSocialFoursquare,
    FTMeSocialGithub,
    FTMeSocialGowalla,
    FTMeSocialGTalk,
    FTMeSocialLinkedIn,
    FTMeSocialRdio,
    FTMeSocialTumblr,
    FTMeSocialVimeo,
    FTMeSocialYahoo
};

typedef NSUInteger FTMeSocial;

@interface FTForrstMe : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)socialInfoFor:(FTMeSocial)network info:(FTSocialInfoReturnBlock)info;

@property (readonly) BOOL       contact;
@property (readonly) NSString   *domain;

@end
