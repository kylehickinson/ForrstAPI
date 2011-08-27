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
#import "FTDownloadQueue.h"
#import "NSString+Crypto.h"
#import "FTConstants.h"

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
            formattedContent        = _formattedContent,
            description             = _description,
            formattedDesc           = _formattedDesc,
            likeCount               = _likeCount,
            commentCount            = _commentCount,
            viewCount               = _viewCount,
            tags                    = _tags;

- (void)snapForSize:(FTPostSnapSize)size completion:(void (^)(UIImage *image))completion {
    __block NSURL *_photoURL;
    
    switch (size) {
        case FTPostSnapSizeMega: _photoURL = _snapMegaURL; break;
        case FTPostSnapSizeKeith: _photoURL = _snapKeithURL; break;
        case FTPostSnapSizeLarge: _photoURL = _snapLargeURL; break;
        case FTPostSnapSizeMedium: _photoURL = _snapMediumURL; break;
        case FTPostSnapSizeSmall: _photoURL = _snapSmallURL; break;
        case FTPostSnapSizeThumb: _photoURL = _snapThumbURL; break;
        case FTPostSnapSizeOriginal: _photoURL = _snapOriginalURL; break;
    }
    
    NSString *key = [[_photoURL absoluteString] MD5];
#if !USING_ARC
    if (key)
        [key retain];
#endif
    [[FTCache cache] imageForKey:key completion:^(UIImage *image) {
        if (image == nil) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [[FTDownloadQueue defaultManager] enqueueDownload:_photoURL completed:^(UIImage *image) {
                [[FTCache cache] addImage:image forKey:key];
                completion(image);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
#if !USING_ARC
                if (key)
                    [key release];
#endif
            }];
        } else {
            completion(image);
        }
    }];
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
        _formattedContent = [[dictionary objectForKey:@"formatted_content"] copy];
        _description = [[dictionary objectForKey:@"description"] copy];
        _formattedDesc = [[dictionary objectForKey:@"formatted_description"] copy];

        _likeCount = [((NSString *)[dictionary objectForKey:@"like_count"]) integerValue];
        _commentCount = [((NSString *)[dictionary objectForKey:@"comment_count"]) integerValue];
        _viewCount = [((NSString *)[dictionary objectForKey:@"view_count"]) integerValue];
        
        if (_type == FTPostTypeSnap) {
            NSDictionary *snaps = [[NSDictionary alloc] initWithDictionary:[dictionary objectForKey:@"snaps"]];
            _snapMegaURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"mega_url"]];
            _snapKeithURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"keith_url"]];
            _snapLargeURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"large_url"]];
            _snapMediumURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"medium_url"]];
            _snapSmallURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"small_url"]];
            _snapThumbURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"thumb_url"]];
            _snapOriginalURL = [[NSURL alloc] initWithString:[snaps objectForKey:@"original_url"]];
#if !USING_ARC
            [snaps release];
#endif
        }
        
        if ([dictionary objectForKey:@"tags"]) {
            _tags = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"tags"] copyItems:YES];
        } else {
            _tags = nil;
        }
    }
    return self;
}

#if !USING_ARC
- (void)dealloc {
    FT_RELEASE(_tinyID);
    FT_RELEASE(_url);
    FT_RELEASE(_createdAt);
    FT_RELEASE(_updatedAt);
    FT_RELEASE(_user);
    FT_RELEASE(_title);
    FT_RELEASE(_attachedURL);
    FT_RELEASE(_content);
    FT_RELEASE(_formattedContent);
    FT_RELEASE(_description);
    FT_RELEASE(_formattedDesc);
    
    if (_type == FTPostTypeSnap) {
        FT_RELEASE(_snapMegaURL);
        FT_RELEASE(_snapKeithURL);
        FT_RELEASE(_snapLargeURL);
        FT_RELEASE(_snapMediumURL);
        FT_RELEASE(_snapSmallURL);
        FT_RELEASE(_snapThumbURL);
        FT_RELEASE(_snapOriginalURL);
    }
    
    if (_tags) {
        FT_RELEASE(_tags);
    }
    
    [super dealloc];
}
#endif

@end
