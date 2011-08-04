//
//  FTDownload.m
//  Leef
//
//  Created by Kyle Hickinson on 11-08-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTDownloadQueue.h"
#import "NSString+Crypto.h"

#define FTStackCapacity 10

@interface FTDownloadQueue ()
@property (strong) NSMutableDictionary *downloads;
@property (strong) NSMutableArray *hashes;
@property (assign) NSUInteger numberOfConnections;

- (void)_dequeueDownloadWithURL:(NSURL *)url;
- (void)_downloadImage;
@end

@implementation FTDownloadQueue
@synthesize downloads = _downloads;
@synthesize hashes = _hashes;
@synthesize numberOfConnections;

+ (FTDownloadQueue *)defaultManager
{
    static FTDownloadQueue *_default = nil;
    if (!_default) {
        _default = [[FTDownloadQueue alloc] init];
    }
    return _default;
}

- (id)init
{
    if ((self = [super init])) {
        _downloads = [[NSMutableDictionary alloc] init];
        _hashes = [[NSMutableArray alloc] init];
        self.numberOfConnections = 0;
    }
    return self;
}

#if !USING_ARC
- (void)dealloc
{
    self.downloads = nil;
    [super dealloc];
}
#endif

- (void)enqueueDownload:(NSURL *)imageURL completed:(FTImageDownloaded)downloaded
{
    NSString *urlHash = [[imageURL absoluteString] MD5];
    
#if !USING_ARC
    [urlHash retain];
#endif
    
    NSDictionary *dict = nil;
    
    if (![self.downloads objectForKey:urlHash]) {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:imageURL, @"url", [downloaded copy], @"block", nil];
        [self.downloads setObject:dict forKey:urlHash];
        [self.hashes insertObject:urlHash atIndex:0];
    }
    
    [self _downloadImage];
    
#if !USING_ARC
    if (dict) [dict release];
    [urlHash release];
#endif
}

- (void)_dequeueDownloadWithURL:(NSURL *)url
{
    NSString *urlHash = [[url absoluteString] MD5];
    [self.downloads removeObjectForKey:urlHash];
    [self.hashes removeObject:urlHash];
}

- (void)_downloadImage
{
    if ([self.downloads count] > 0 && [self.hashes count] > 0 && self.numberOfConnections < FTStackCapacity) {
        
        self.numberOfConnections++;
        
        NSString *urlHash = [self.hashes lastObject];
        NSURL *urlToDownload = [[self.downloads objectForKey:urlHash] objectForKey:@"url"];
        FTImageDownloaded block = [[[self.downloads objectForKey:urlHash] objectForKey:@"block"] copy];
        
#if !USING_ARC
        [urlToDownload retain];
        [urlHash retain];
#endif
        
        [self _dequeueDownloadWithURL:urlToDownload];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlToDownload]];
            if (image) {
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(image);
                    });
                }
            }
            self.numberOfConnections--;
            
#if !USING_ARC
            [urlToDownload release];
            [urlHash release];
            [block release];
#endif
        });
    }
}

@end
