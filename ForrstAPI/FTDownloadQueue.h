//
//  FTDownload.h
//  Leef
//
//  Created by Kyle Hickinson on 11-08-02.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FTImageDownloaded)(UIImage *);

@interface FTDownloadQueue : NSObject

+ (FTDownloadQueue *)defaultManager;
- (void)enqueueDownload:(NSURL *)imageURL completed:(FTImageDownloaded)downloaded;

@end
