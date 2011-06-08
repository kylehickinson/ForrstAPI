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

- (id)init {
    if ((self = [super init])) {
        _fileManager = [[NSFileManager defaultManager] retain];
        
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
    switch (type) {
        case FTCacheTypeSnap: {
            NSString *path = [[NSTemporaryDirectory() stringByAppendingFormat:@"%@%@", FT_CACHE_SNAPS_DIR, key] retain];
            if (![_fileManager fileExistsAtPath:path]) {
                [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
            }
            [path release];
            break;
        }  
        case FTCacheTypeUserAvatar: {
            NSString *path = [[NSTemporaryDirectory() stringByAppendingFormat:@"%@%@", FT_CACHE_USERAVS_DIR, key] retain];
            if (![_fileManager fileExistsAtPath:path]) {
                [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
            }
            [path release];
            break;
        }
        default:
            break;
    }
}

- (UIImage *)imageForKey:(NSString *)key type:(FTCacheType)type {
    switch (type) {
        case FTCacheTypeSnap: {
            NSString *path = [[NSTemporaryDirectory() stringByAppendingFormat:@"%@%@", FT_CACHE_SNAPS_DIR, key] retain];
            if ([_fileManager fileExistsAtPath:path]) {
                [path release];
                return [UIImage imageWithContentsOfFile:path];
            }
            [path release];
            break;
        }
        case FTCacheTypeUserAvatar: {
            NSString *path = [[NSTemporaryDirectory() stringByAppendingFormat:@"%@%@", FT_CACHE_USERAVS_DIR, key] retain];
            if ([_fileManager fileExistsAtPath:path]) {
                [path release];
                return [UIImage imageWithContentsOfFile:path];
            }
            [path release];
            break;
        }
            
    }
    return nil;
}

- (void)dealloc {
    [_fileManager release];
    
    [super dealloc];
}


@end
