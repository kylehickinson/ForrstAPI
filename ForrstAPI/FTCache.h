//
//  FTCache.h
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-06.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FTImageCompletion)(UIImage *image);

@class UIImage;

enum {
    FTCacheTypeSnap = 0,
    FTCacheTypeUserAvatar
};
typedef NSUInteger FTCacheType;

@interface FTCache : NSObject

+ (FTCache *)cache;
- (void)addImage:(UIImage *)image forKey:(NSString *)key;
- (void)imageForKey:(NSString *)key completion:(FTImageCompletion)completion;
- (void)flush;
- (void)clearMemoryCache;

@end
