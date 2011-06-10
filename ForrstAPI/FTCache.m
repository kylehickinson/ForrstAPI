//
//  FTCache.m
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-06.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import "FTCache.h"
#import <UIKit/UIKit.h>

@implementation FTCache (Singleton)
FTCache *_cache;
@end

@implementation FTCache

+ (FTCache *)cache {
    if (!_cache) {
        _cache = [[FTCache alloc] init];
    }
    return _cache;
}

- (void)clearMemoryCache {
    [_memoryCache removeAllObjects];
}

- (id)init {
    if ((self = [super init])) {
        _fileManager = [[NSFileManager defaultManager] retain];
        _memoryCache = [[NSMutableDictionary alloc] init];
        
        NSString *path = [[NSTemporaryDirectory() stringByAppendingPathComponent:FT_CACHE_SNAPS_DIR] retain];
        if (![_fileManager fileExistsAtPath:path]) {
            [_fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [path release];
        path = [[NSTemporaryDirectory() stringByAppendingPathComponent:FT_CACHE_USERAVS_DIR] retain];
        
        if (![_fileManager fileExistsAtPath:path]) {
            [_fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [path release];
    }
    return self;
}

- (void)addImage:(UIImage *)image forKey:(NSString *)key type:(FTCacheType)type {
    NSString *path = [[NSTemporaryDirectory() stringByAppendingFormat:@"%@%@", (type == FTCacheTypeSnap ? FT_CACHE_SNAPS_DIR : FT_CACHE_USERAVS_DIR), key] retain];
    if (![_fileManager fileExistsAtPath:path]) {
        [_memoryCache setObject:image forKey:path];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
        });
    }
    [path release];
}

- (void)imageForKey:(NSString *)key type:(FTCacheType)type completion:(void (^)(UIImage *image))completion {
    NSString *path = [[NSTemporaryDirectory() stringByAppendingFormat:@"%@%@", (type == FTCacheTypeSnap ? FT_CACHE_SNAPS_DIR : FT_CACHE_USERAVS_DIR), key] retain];
    if ([_memoryCache objectForKey:path]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([_memoryCache objectForKey:path]);
        });
    } else {
        if ([_fileManager fileExistsAtPath:path]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *_image = [UIImage imageWithContentsOfFile:path];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    completion(_image);
                });
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }
    [path release];
}

- (void)dealloc {
    FT_RELEASE(_fileManager);
    FT_RELEASE(_memoryCache);
    
    [super dealloc];
}


@end
