//
//  FTPost.h
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FTUser;
@class UIImage;

enum {
    FTPostTypeSnap = 1,
    FTPostTypeCode,
    FTPostTypeQuestion,
    FTPostTypeLink
};
typedef NSUInteger FTPostType;

enum {
    FTPostSortRecent = 0,
    FTPostSortPopular,
    FTPostSortBest
};
typedef NSUInteger FTPostSort;

@interface FTPost : NSObject {
    NSUInteger      _postID;
    NSString        *_tinyID;
    NSURL           *_url;

    FTPostType      _type;
    
    NSString        *_createdAt;
    NSString        *_updatedAt;
    
    FTUser          *_user;
    BOOL            _published;
    BOOL            _public;
    NSString        *_title;
    NSURL           *_attachedURL;
    
    NSString        *_content;
    NSString        *_description;
    NSString        *_formattedDescription;
    
    NSInteger       _likeCount;
    NSInteger       _commentCount;
    
    NSURL           *_snapMegaURL;
    NSURL           *_snapKeithURL;
    NSURL           *_snapLargeURL;
    NSURL           *_snapMediumURL;
    NSURL           *_snapSmallURL;
    NSURL           *_snapThumbURL;
    NSURL           *_snapOriginalURL;
    
    UIImage         *_snapMega;
    UIImage         *_snapKeith;
    UIImage         *_snapLarge;
    UIImage         *_snapMedium;
    UIImage         *_snapSmall;
    UIImage         *_snapThumb;
    UIImage         *_snapOriginal;
}

@property (readonly) NSUInteger     postID;
@property (readonly) NSString       *tinyID;
@property (readonly) NSURL          *url;
@property (readonly) FTPostType     type;
@property (readonly) NSString       *createdAt;
@property (readonly) NSString       *updatedAt;
@property (readonly) FTUser         *user;
@property (readonly) BOOL           published;
@property (readonly) BOOL           isPublic;
@property (readonly) NSString       *title;
@property (readonly) NSURL          *attachedURL;
@property (readonly) NSString       *content;
@property (readonly) NSString       *description;
@property (readonly) NSString       *formattedDescription;
@property (readonly) NSInteger      likeCount;
@property (readonly) NSInteger      commentCount;

@property (readonly) UIImage        *snapMega;
@property (readonly) UIImage        *snapKeith;
@property (readonly) UIImage        *snapLarge;
@property (readonly) UIImage        *snapMedium;
@property (readonly) UIImage        *snapSmall;
@property (readonly) UIImage        *snapThumb;
@property (readonly) UIImage        *snapOriginal;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
