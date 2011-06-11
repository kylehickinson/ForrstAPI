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

enum {
    FTPostSnapSizeMega = 0,
    FTPostSnapSizeKeith,
    FTPostSnapSizeLarge,
    FTPostSnapSizeMedium,
    FTPostSnapSizeSmall,
    FTPostSnapSizeThumb,
    FTPostSnapSizeOriginal
};
typedef NSUInteger FTPostSnapSize;

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
    NSString        *_formattedContent;
    NSString        *_description;
    NSString        *_formattedDescription;
    
    NSInteger       _likeCount;
    NSInteger       _commentCount;
    
    NSArray         *_tags;
    
    NSURL           *_snapMegaURL;
    NSURL           *_snapKeithURL;
    NSURL           *_snapLargeURL;
    NSURL           *_snapMediumURL;
    NSURL           *_snapSmallURL;
    NSURL           *_snapThumbURL;
    NSURL           *_snapOriginalURL;
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
@property (readonly) NSString       *formattedContent;
@property (readonly) NSString       *description;
@property (readonly) NSString       *formattedDescription;
@property (readonly) NSInteger      likeCount;
@property (readonly) NSInteger      commentCount;

@property (readonly) NSArray        *tags;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)snapForSize:(FTPostSnapSize)size completion:(void (^)(UIImage *image))completion;

@end
