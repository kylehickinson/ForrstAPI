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
@property (strong) NSString       *username;
@property (strong) NSString       *name;
@property (readonly) BOOL           availableForWork;
@property (strong) NSURL          *url;
@property (readonly) NSInteger      posts;
@property (readonly) NSInteger      comments;
@property (readonly) NSInteger      likes;
@property (readonly) NSInteger      followers;
@property (readonly) NSInteger      following;
@property (strong) NSString       *bio;
@property (strong) NSString       *type;
@property (strong) NSURL          *homepage;
@property (strong) NSString       *twitter;
@property (readonly) BOOL           inDirectory;
@property (strong) NSArray        *tags;
@property (strong) FTForrstMe     *forrstMe;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)photoForSize:(FTUserPhotoSize)size completion:(void (^)(UIImage *image))completion;

@end
