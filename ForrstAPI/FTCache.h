//
//  FTCache.h
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-06.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FT_CACHE_SNAPS_DIR       @"forrst_database/snaps/"
#define FT_CACHE_USERAVS_DIR     @"forrst_database/user_avatars/"

@class UIImage;

enum {
    FTCacheTypeSnap = 0,
    FTCacheTypeUserAvatar
};
typedef NSUInteger FTCacheType;

@interface FTCache : NSObject {
    NSFileManager *_fileManager;
}

+ (FTCache *)cache;
- (void)addImage:(UIImage *)image forKey:(NSString *)key type:(FTCacheType)type;
- (void)imageForKey:(NSString *)key type:(FTCacheType)type completion:(void (^)(UIImage *image))completion;

@end
