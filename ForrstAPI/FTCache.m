//
//  FTCache.m
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-06.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import "FTCache.h"
#import "NSString+Crypto.h"
#import <UIKit/UIKit.h>

@interface FTCache ()
@property (strong) NSFileManager *fileManager;
@property (strong) NSMutableDictionary *memoryCache;
@end

@implementation FTCache
@synthesize fileManager = _fileManager;
@synthesize memoryCache = _memoryCache;

+ (FTCache *)cache {
    static FTCache *_cache = nil;
    if (!_cache) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _cache = [[FTCache alloc] init];
        });
    }
    return _cache;
}

- (void)clearMemoryCache {
    [self.memoryCache removeAllObjects];
}

- (id)init {
    if ((self = [super init])) {
        _fileManager = [[NSFileManager defaultManager] retain];
        _memoryCache = [[NSMutableDictionary alloc] init];
        
//        NSString *path = [[NSTemporaryDirectory() stringByAppendingPathComponent:FT_CACHE_SNAPS_DIR] retain];
//        if (![_fileManager fileExistsAtPath:path]) {
//            [_fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//        [path release];
//        path = [[NSTemporaryDirectory() stringByAppendingPathComponent:FT_CACHE_USERAVS_DIR] retain];
//        
//        if (![_fileManager fileExistsAtPath:path]) {
//            [_fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//        [path release];
    }
    return self;
}

- (void)addImage:(UIImage *)image forKey:(NSString *)key
{
    if (image && [key length] != 0) {
        NSString *path = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), key];
        if (![_fileManager fileExistsAtPath:path]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSData *pngRep = UIImagePNGRepresentation(image);
                if (pngRep) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.memoryCache setObject:pngRep forKey:key];
                    });
                }
                [pngRep writeToFile:path atomically:YES];
            });
        }
#if !USING_ARC
        [path release];
#endif
    }
}

- (void)imageForKey:(NSString *)key completion:(FTImageCompletion)completion
{
    if ([key length] != 0 && completion) {
        NSString *path = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), key];
        if ([self.memoryCache objectForKey:key]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *image = [UIImage imageWithData:[self.memoryCache objectForKey:key]];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    completion(image);
                });
            });
        } else {
            if ([self.fileManager fileExistsAtPath:path]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    NSData *_imageData = [NSData dataWithContentsOfFile:path];
                    UIImage *_image = [UIImage imageWithData:_imageData];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.memoryCache setObject:_imageData forKey:key];
                        completion(_image);
                    });
                });
            } else {
                completion(nil);
            }
        }
#if !USING_ARC
        [path release];
#endif
    }
}

#if !USING_ARC
- (void)dealloc {
    self.memoryCache = nil;
    self.fileManager = nil;
    
    [super dealloc];
}
#endif



@end
