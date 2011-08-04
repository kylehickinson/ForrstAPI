//
//  FTUser.h
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTForrstMe.h"

@class UIImage;

enum {
    FTUserPhotoSizeXL = 0,
    FTUserPhotoSizeLarge,
    FTUserPhotoSizeMedium,
    FTUserPhotoSizeSmall,
    FTUserPhotoSizeThumb
};
typedef NSUInteger FTUserPhotoSize;

@interface FTUser : NSObject {
    NSURL           *_photosXLURL;
    NSURL           *_photosLargeURL;
    NSURL           *_photosMediumURL;
    NSURL           *_photosSmallURL;
    NSURL           *_photosThumbURL;
}

@property (readonly) NSUInteger     userID;
@property (readonly) NSString       *username;
@property (readonly) NSString       *name;
@property (readonly) BOOL           availableForWork;
@property (readonly) NSURL          *url;
@property (readonly) NSInteger      posts;
@property (readonly) NSInteger      comments;
@property (readonly) NSInteger      likes;
@property (readonly) NSInteger      followers;
@property (readonly) NSInteger      following;
@property (readonly) NSString       *bio;
@property (readonly) NSString       *type;
@property (readonly) NSURL          *homepage;
@property (readonly) NSString       *twitter;
@property (readonly) BOOL           inDirectory;
@property (readonly) NSArray        *tags;
@property (readonly) FTForrstMe     *forrstMe;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)photoForSize:(FTUserPhotoSize)size completion:(void (^)(UIImage *image))completion;

@end
