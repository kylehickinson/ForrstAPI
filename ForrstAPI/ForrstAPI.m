//
//  ForrstAPI.m
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import "ForrstAPI.h"
#import "FTRequest.h"

@interface ForrstAPI ()
@property (nonatomic, copy) NSString *viewURLFormat;
@end

@implementation ForrstAPI
@synthesize authToken = _authToken;
@synthesize viewURLFormat = _viewURLFormat;

static ForrstAPI *_singleton = nil;
+ (ForrstAPI *)engine {
    if (!_singleton) {
        _singleton = [[ForrstAPI alloc] init];
#if !USING_ARC
        [_singleton retain];
#endif
    }
    return _singleton;
}

- (id)init 
{
    if ((self = [super init])) {
        _authToken = nil;
    }
    return self;
}

#if !USING_ARC
- (void)dealloc 
{
    [_authToken release], _authToken = nil;
    [super dealloc];
}
#endif

- (NSURL *)_setupURLWithString:(NSString *)url 
{
    BOOL hasParams = NO;
    if (self.authToken) {
        for (int i = [url length]-1; i >= 0; i--) {
            if ([url characterAtIndex:i] == '?') {
                hasParams = YES;
                break;
            }
        }
    }
    
    return [NSURL URLWithString:
                [[NSString stringWithFormat:@"%@%@%@", 
                  ([url hasPrefix:@"https:"] ? @"" : FT_API_BASEURL), 
                                            url,
                                            (self.authToken ? [NSString stringWithFormat:@"%@access_token=%@", (hasParams ? @"&" : @"?"), self.authToken] : @"")] 
                stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]
            ];
}

- (void)stats:(FTStatsCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    NSURL *url = [self _setupURLWithString:@"stats"];

#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - stats:%@ fail:%@ (url=%@)", self, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                NSUInteger _rateLimit = [[response.response objectForKey:@"rate_limit"] unsignedIntegerValue];
                NSString *_callsMade = [[response.response objectForKey:@"calls_made"] copy];
                completion(_rateLimit, [_callsMade integerValue]);
#if !USING_ARC
                [_callsMade release];
#endif
            }
        }
    } fail:fail];
}

- (void)authWithUser:(NSString *)user password:(NSString *)password completion:(void (^)(NSString *token))completion fail:(FTErrorReturnBlock)fail 
{
    NSURL *url = [self _setupURLWithString:[NSString stringWithFormat:@"users/auth?email_or_username=%@&password=%@", user, password]];
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - authWithUser:%@ password:%@ completion:%@ fail:%@ (url=%@)", self, user, password, completion, fail, url);
#endif

    [FTRequest request:url type:FTRequestTypePost completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            _authToken = [[response.response objectForKey:@"token"] copy];
            if (_authToken) {
                if (completion) {
                    NSLog(@"authed_as: %@", response.authedAs);
                    completion(_authToken);
                }
            }
        }
    } fail:fail];
}

- (void)userInformationForUser:(NSString *)user completion:(FTUserCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    NSString *param = ([user integerValue] != 0 ? @"id" : @"username");
    NSURL *url = [self _setupURLWithString:[NSString stringWithFormat:@"users/info?%@=%@", param, user]];
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - userInformationForUser:%@ completion:%@ fail:%@ (url=%@)", self, user, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                FTUser *info = [[FTUser alloc] initWithDictionary:response.response];
                completion(info);
#if !USING_ARC
                [info release];
#endif
            }
        }
    } fail:fail];
}

- (void)userPostsForUser:(NSString *)user completion:(FTPostsCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    [self userPostsForUser:user options:nil completion:completion fail:fail];
}

- (void)userPostsForUser:(NSString *)user options:(NSDictionary *)options completion:(FTPostsCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    NSString *param = ([user integerValue] != 0 ? @"id" : @"username");
    NSMutableString *_url = [[NSMutableString alloc] initWithFormat:@"user/posts?%@=%@", param, user];
    
    if (options) {
        if ([options objectForKey:@"type"]) {
            NSString *type;
            if (![[options objectForKey:@"type"] isKindOfClass:[NSString class]]) {
                switch ([[options objectForKey:@"type"] unsignedIntegerValue]) {
                    case FTPostTypeCode: type = @"code"; break;
                    case FTPostTypeLink: type = @"link"; break;
                    case FTPostTypeQuestion: type = @"question"; break;
                    case FTPostTypeSnap:
                    default:
                        type = @"snap"; break;
                }
            } else {
                type = [options objectForKey:@"type"];
            }
            [_url appendFormat:@"&type=%@", type];
        }
        
        if ([options objectForKey:@"limit"]) {
            [_url appendFormat:@"&limit=%@", [options objectForKey:@"limit"]];
        }
        
        if ([options objectForKey:@"after"]) {
            [_url appendFormat:@"&after=%@", [options objectForKey:@"after"]];
        }
    }
    
    NSURL *url = [self _setupURLWithString:_url];
    
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - userPostsForUser:%@ options:%@ completion:%@ fail:%@ (url=%@)", self, user, options, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                NSMutableArray *_posts = [[NSMutableArray alloc] init];
                for (NSDictionary *post in [response.response objectForKey:@"posts"]) {
                    FTPost *_post = [[FTPost alloc] initWithDictionary:post];
                    [_posts addObject:_post];
#if !USING_ARC
                    [_post release];
#endif
                }
                completion(_posts);
#if !USING_ARC
                [_posts release];
#endif
            }
        }
    } fail:fail];
    
#if !USING_ARC
    [_url release];
#endif
}

- (void)postForID:(NSString *)postID completion:(FTPostCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    NSURL *url = [self _setupURLWithString:[NSString stringWithFormat:@"posts/show?id=%@", postID]];
    
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - postForID:%@ completion:%@ fail:%@ (url=%@)", self, postID, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                FTPost *post = [[FTPost alloc] initWithDictionary:response.response];
                completion(post);
#if !USING_ARC
                [post release];
#endif
            }
        }
    } fail:fail];   
}

- (void)postForTinyID:(NSString *)postID completion:(FTPostCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    NSURL *url = [self _setupURLWithString:[NSString stringWithFormat:@"posts/show?tiny_id=%@", postID]];
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%@) - postForTinyID:%@ completion:%@ fail:%@ (url=%@)", self, postID, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                FTPost *post = [[FTPost alloc] initWithDictionary:response.response];
                completion(post);
#if !USING_ARC
                [post release];
#endif
            }
        }
    } fail:fail];
}

- (void)listPostsForType:(FTPostType)type completion:(FTPostsAndPageCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    [self listPostsForType:type options:nil completion:completion fail:fail];
}

- (void)listPostsForType:(FTPostType)type options:(NSDictionary *)options completion:(FTPostsAndPageCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    NSString *postType;
    
    switch (type) {
        case FTPostTypeCode: postType = @"code"; break;
        case FTPostTypeLink: postType = @"link"; break;
        case FTPostTypeQuestion: postType = @"question"; break;
        case FTPostTypeSnap:
        default:
            postType = @"snap";
            break;
    }
    NSMutableString *_url = [[NSMutableString alloc] initWithFormat:@"posts/list?post_type=%@", postType];
    if (options) {
        if ([options objectForKey:@"sort"]) {
            NSString *sort;
            if (![[options objectForKey:@"sort"] isKindOfClass:[NSString class]]) {
                switch ([[options objectForKey:@"sort"] unsignedIntegerValue]) {
                    case FTPostSortPopular: sort = @"popular"; break;
                    case FTPostSortBest: sort = @"best"; break;
                    case FTPostSortRecent:
                    default:
                        sort = @"recent"; break;
                }
            } else {
                sort = [options objectForKey:@"sort"];
            }
            [_url appendFormat:@"&sort=%@", sort];
        }
        
        if ([options objectForKey:@"page"]) {
            [_url appendFormat:@"&page=%d", [[options objectForKey:@"page"] unsignedIntegerValue]];
        }
    }
    
    NSURL *url = [self _setupURLWithString:_url];
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - listPostsForType:%d (%@) options:%@ completion:%@ fail:%@ (url=%@)", self, type, postType, options, completion, fail, url);
#endif
    

    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                NSMutableArray *_list = [[NSMutableArray alloc] init];
                for (NSDictionary *post in [response.response objectForKey:@"posts"]) {
                    FTPost *_post = [[FTPost alloc] initWithDictionary:post];
                    [_list addObject:_post];
#if !USING_ARC
                    [_post release];
#endif
                }
                completion(_list, [((NSString *)[response.response objectForKey:@"page"]) integerValue]);
#if !USING_ARC
                [_list release];
#endif
            }
        }
    } fail:fail];
    
#if !USING_ARC
    [_url release];
#endif
}

- (void)listPosts:(FTPostsAndPageCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    [self listPostsAfter:0 completion:completion fail:fail];
}

- (void)listPostsAfter:(NSUInteger)after completion:(FTPostsAndPageCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    NSMutableString *_url = [[NSMutableString alloc] initWithString:@"posts/all"];
    if (after != 0) {
        [_url appendFormat:@"?after=%d", after];
    }
    
    NSURL *url = [self _setupURLWithString:_url];
    
#if FT_API_LOG
    NSLog(@"ForrstAPI (%p) - listPostsAfter:%d completion:%@ fail:%@ (url=%@)", self, after, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {                
                NSMutableArray *_list = [[NSMutableArray alloc] init];
                for (NSDictionary *post in [response.response objectForKey:@"posts"]) {
                    FTPost *_post = [[FTPost alloc] initWithDictionary:post];
                    [_list addObject:_post];
#if !USING_ARC
                    [_post release];
#endif
                }
                
                NSUInteger pageNumber = 0;
                id page = [response.response objectForKey:@"page"];
                if ([page isKindOfClass:[NSString class]]) {
                    pageNumber = [(NSString *)page integerValue]; 
                } else { 
                    pageNumber = [(NSNumber *)page integerValue];
                }
                
                completion(_list, pageNumber);
                
#if !USING_ARC
                [_list release];
#endif
            }
        }
    } fail:fail];
    
#if !USING_ARC
    [_url release];
#endif
}

- (void)commentsForPostId:(NSString *)postID completion:(FTCommentsCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    NSURL *url = [self _setupURLWithString:[NSString stringWithFormat:@"post/comments?id=%@", postID]];
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - commentsForPostId:%@ completion:%@ fail:%@ (url=%@)", self, postID, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                NSMutableArray *_list = [[NSMutableArray alloc] init];
                for (NSDictionary *comment in [response.response objectForKey:@"comments"]) {
                    FTComment *_comment = [[FTComment alloc] initWithDictionary:comment];
                    [_list addObject:_comment];
#if !USING_ARC
                    [_comment release];
#endif
                }
                completion(_list, [[response.response objectForKey:@"count"] unsignedIntegerValue]);
#if !USING_ARC
                [_list release];
#endif
            }
        }
    } fail:fail];
}

- (void)commentsForPostTinyId:(NSString *)postID completion:(FTCommentsCompletionBlock)completion fail:(FTErrorReturnBlock)fail 
{
    NSURL *url = [self _setupURLWithString:[NSString stringWithFormat:@"post/comments?tiny_id=%@", postID]];
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - commentsForPostTinyId:%@ completion:%@ fail:%@ (url=%@)", self, postID, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                NSMutableArray *_list = [[NSMutableArray alloc] init];
                for (NSDictionary *comment in [response.response objectForKey:@"comments"]) {
                    FTComment *_comment = [[FTComment alloc] initWithDictionary:comment];
                    [_list addObject:_comment];
#if !USING_ARC
                    [_comment release];
#endif
                }
                completion(_list, [[response.response objectForKey:@"count"] unsignedIntegerValue]);
#if !USING_ARC
                [_list release];
#endif
            }
        }
    } fail:fail];
}

- (void)notifications:(BOOL)grouped completion:(void (^)(NSArray *notifications, NSString *viewURLFormat))completion fail:(FTErrorReturnBlock)fail
{
    //
    // TODO: Actually complete grouping functionality.
    // 
//    __block BOOL isGrouped = grouped;
    
    NSURL *url = [self _setupURLWithString:@"notifications?grouped=false"];
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - notificaions:%d completion:%@ fail:%@ (url=%@)", self, grouped, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            NSMutableArray *_notifications = [[NSMutableArray alloc] init];
            for (NSDictionary *dictionary in [response.response objectForKey:@"items"]) {
                FTNotification *notification = [[FTNotification alloc] initWithDictionary:dictionary];
                [_notifications addObject:notification];
#if !USING_ARC
                [notification release];
#endif
            }
            
            NSString *viewURLFormat = [response.response objectForKey:@"view_url_format"];
            
            
            if (!self.viewURLFormat) {
                self.viewURLFormat = [viewURLFormat stringByReplacingCharactersInRange:NSMakeRange([viewURLFormat length]-3, 3) withString:@""];
            }
            
            if (completion) {
                completion(_notifications, viewURLFormat);
            }
#if !USING_ARC
            [_notifications release];
#endif
        }
    } fail:fail];
}

- (void)markNotificationAsRead:(NSString *)notificationID completion:(void (^)())completion fail:(FTErrorReturnBlock)fail
{
    NSLog(@"%@",[self.viewURLFormat stringByAppendingString:notificationID]);
    NSURL *url = [self _setupURLWithString:[self.viewURLFormat stringByAppendingString:notificationID]];
    
//#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - markNotificationAsRead:%@ completion:%@ fail:%@ (url=%@)", self, notificationID, completion, fail, url);
//#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (completion) {
            completion();
        }
    } fail:fail];
}

@end
