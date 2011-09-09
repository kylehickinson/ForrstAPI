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
    NSURL *_snapMegaURL;
    NSURL *_snapKeithURL;
    NSURL *_snapLargeURL;
    NSURL *_snapMediumURL;
    NSURL *_snapSmallURL;
    NSURL *_snapThumbURL;
    NSURL *_snapOriginalURL;
}

@property (readonly) NSUInteger     postID;
@property (strong) NSString       *tinyID;
@property (strong) NSURL          *url;
@property (readonly) FTPostType     type;
@property (strong) NSString       *createdAt;
@property (strong) NSString       *updatedAt;
@property (strong) FTUser         *user;
@property (readonly) BOOL           published;
@property (readonly) BOOL           isPublic;
@property (strong) NSString       *title;
@property (strong) NSURL          *attachedURL;
@property (strong) NSString       *content;
@property (strong) NSString       *formattedContent;
@property (strong) NSString       *description;
@property (strong) NSString       *formattedDesc;
@property (readonly) NSInteger      likeCount;
@property (readonly) NSInteger      commentCount;
@property (readonly) NSInteger      viewCount;

@property (strong) NSArray        *tags;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)snapForSize:(FTPostSnapSize)size completion:(void (^)(UIImage *image))completion;

@end
