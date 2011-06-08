//
//  FTPost.m
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import "FTPost.h"
#import "FTUser.h"
#import "FTCache.h"

#import <UIKit/UIKit.h>

@implementation FTPost
@synthesize postID                  = _postID,
            tinyID                  = _tinyID,
            url                     = _url,
            type                    = _type,
            createdAt               = _createdAt,
            updatedAt               = _updatedAt,
            user                    = _user,
            published               = _published,
            isPublic                = _public,
            title                   = _title,
            attachedURL             = _attachedURL,
            content                 = _content,
            description             = _description,
            formattedDescription    = _formattedDescripton,
            likeCount               = _likeCount,
            commentCount            = _commentCount;

- (UIImage *)_checkCacheForKey:(NSString *)key {
    return [[FTCache cache] imageForKey:key type:FTCacheTypeSnap];
}

- (UIImage *)snapMega {
    if (!_snapMega) {
        _snapMega = [self _checkCacheForKey:[NSString stringWithFormat:@"%d_mega", self.postID]];
        if (!_snapMega) {
            _snapMega = [UIImage imageWithData:[NSData dataWithContentsOfURL:_snapMegaURL]];
        }
    }
    return _snapMega;
}
- (UIImage *)snapKeith {
    if (!_snapKeith) {
        _snapKeith = [self _checkCacheForKey:[NSString stringWithFormat:@"%d_keith", self.postID]];
        if (!_snapKeith) {
            _snapKeith = [UIImage imageWithData:[NSData dataWithContentsOfURL:_snapKeithURL]];
        }
    }
    return _snapKeith;
}
- (UIImage *)snapLarge {
    if (!_snapLarge) {
        _snapLarge = [self _checkCacheForKey:[NSString stringWithFormat:@"%d_large", self.postID]];
        if (!_snapLarge) {
            _snapLarge = [UIImage imageWithData:[NSData dataWithContentsOfURL:_snapLargeURL]];
        }
    }
    return _snapLarge;
}
- (UIImage *)snapMedium {
    if (!_snapMedium) {
        _snapMedium = [self _checkCacheForKey:[NSString stringWithFormat:@"%d_medium", self.postID]];
        if (!_snapMedium) {
            _snapMedium = [UIImage imageWithData:[NSData dataWithContentsOfURL:_snapMediumURL]];
        }
    }
    return _snapMedium;
}
- (UIImage *)snapSmall {
    if (!_snapSmall) {
        _snapSmall = [self _checkCacheForKey:[NSString stringWithFormat:@"%d_small", self.postID]];
        if (!_snapSmall) {
            _snapSmall = [UIImage imageWithData:[NSData dataWithContentsOfURL:_snapSmallURL]];
        }
    }
    return _snapSmall;
}
- (UIImage *)snapThumb {
    if (!_snapThumb) {
        _snapThumb = [self _checkCacheForKey:[NSString stringWithFormat:@"%d_thumb", self.postID]];
        if (!_snapThumb) {
            _snapThumb = [UIImage imageWithData:[NSData dataWithContentsOfURL:_snapThumbURL]];
        }
    }
    return _snapThumb;
}
- (UIImage *)snapOriginal {
    if (!_snapOriginal) {
        _snapOriginal = [self _checkCacheForKey:[NSString stringWithFormat:@"%d_original", self.postID]];
        if (!_snapOriginal) {
            _snapOriginal = [UIImage imageWithData:[NSData dataWithContentsOfURL:_snapOriginalURL]];
        }
    }
    return _snapOriginal;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        
        _postID = [[dictionary objectForKey:@"id"] unsignedIntegerValue];
        _tinyID = [[dictionary objectForKey:@"tiny_id"] copy];
        _url = [[NSURL alloc] initWithString:[dictionary objectForKey:@"post_url"]];
        
        NSMutableString *_temp = [[dictionary objectForKey:@"post_type"] copy];
        if ([_temp characterAtIndex:0] == 's') {
            _type = FTPostTypeSnap;
        } else if ([_temp characterAtIndex:0] == 'c') {
            _type = FTPostTypeCode;
        } else if ([_temp characterAtIndex:0] == 'l') {
            _type = FTPostTypeLink;
        } else {
            _type = FTPostTypeQuestion;
        }
        [_temp release];
        
        _createdAt = [[dictionary objectForKey:@"created_at"] copy];
        _updatedAt = [[dictionary objectForKey:@"updated_at"] copy];
        _user = [[FTUser alloc] initWithDictionary:[dictionary objectForKey:@"user"]];
        _published = [[dictionary objectForKey:@"published"] boolValue];
        _public = [[dictionary objectForKey:@"public"] boolValue];
        _title = [[dictionary objectForKey:@"title"] copy];
        _attachedURL = [[NSURL alloc] initWithString:[dictionary objectForKey:@"url"]];
        _content = [[dictionary objectForKey:@"content"] copy];
        _description = [[dictionary objectForKey:@"description"] copy];
        _formattedDescription = [[dictionary objectForKey:@"formatted_description"] copy];
        _likeCount = [((NSString *)[dictionary objectForKey:@"like_count"]) integerValue];
        _commentCount = [((NSString *)[dictionary objectForKey:@"comment_count"]) integerValue];
        
        if (_type == FTPostTypeSnap) {
            NSDictionary *snaps = [[NSDictionary alloc] initWithDictionary:[dictionary objectForKey:@"snaps"]];
            _snapMegaURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"mega_url"]];
            _snapKeithURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"keith_url"]];
            _snapLargeURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"large_url"]];
            _snapMediumURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"medium_url"]];
            _snapSmallURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"small_url"]];
            _snapThumbURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"thumb_url"]];
            _snapOriginalURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"original_url"]];
        }
    }
    return self;
}

- (void)dealloc {
    FT_RELEASE(_tinyID);
    FT_RELEASE(_url);
    FT_RELEASE(_createdAt);
    FT_RELEASE(_updatedAt);
    FT_RELEASE(_user);
    FT_RELEASE(_title);
    FT_RELEASE(_attachedURL);
    FT_RELEASE(_content);
    FT_RELEASE(_description);
    FT_RELEASE(_formattedDescription);
    
    if (_type == FTPostTypeSnap) {
        FT_RELEASE(_snapMegaURL);
        FT_RELEASE(_snapKeithURL);
        FT_RELEASE(_snapLargeURL);
        FT_RELEASE(_snapMediumURL);
        FT_RELEASE(_snapSmallURL);
        FT_RELEASE(_snapThumbURL);
        FT_RELEASE(_snapOriginalURL);
    }
    
    [super dealloc];
}

@end
