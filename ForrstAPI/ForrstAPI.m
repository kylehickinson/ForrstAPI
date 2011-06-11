//
//  ForrstAPI.m
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import "ForrstAPI.h"
#import "FTRequest.h"

@implementation ForrstAPI (Singleton)
ForrstAPI *_singleton;
@end

@implementation ForrstAPI
@synthesize authToken = _authToken;

+ (ForrstAPI *)engine {
    if (!_singleton) {
        _singleton = [[ForrstAPI alloc] init];
    }
    return _singleton;
}

- (id)init {
    if ((self = [super init])) {
        _authToken = nil;
    }
    return self;
}

- (NSURL *)_setupURLWithString:(NSString *)url {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", FT_API_BASEURL, url, (_authToken ? [NSString stringWithFormat:@"&access_token=%@", _authToken] : @"")]];
}

- (void)stats:(void (^)(NSUInteger rateLimit, NSInteger callsMade))completion fail:(void (^)(NSError *error))fail {
    NSURL *url = [[self _setupURLWithString:@"stats"] retain];

#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - stats:%@ fail:%@ (url=%@)", self, completion, fail, url);
#endif
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                NSUInteger _rateLimit = [[response.response objectForKey:@"rate_limit"] unsignedIntegerValue];
                NSString *_callsMade = [[response.response objectForKey:@"calls_made"] copy];
                completion(_rateLimit, [_callsMade integerValue]);
                [_callsMade release];
            }
        }
    } fail:fail];
    
    [url release];
}

- (void)authWithUser:(NSString *)user password:(NSString *)password completion:(void (^)(NSString *token))completion fail:(void (^)(NSError *error))fail {
    NSURL *url = [[self _setupURLWithString:[NSString stringWithFormat:@"auth?email_or_username=%@&password=%@", user, password]] retain];
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - authWithUser:%@ password:%@ completion:%@ fail:%@ (url=%@)", self, user, password, completion, fail, url);
#endif

    [FTRequest request:url type:FTRequestTypePost completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            _authToken = [response.response objectForKey:@"token"];
            if (completion) {
                completion(_authToken);
            }
        }
    } fail:fail];
    
    [url release];
}

- (void)userInformationForUser:(NSString *)user completion:(void (^)(FTUser *user))completion fail:(void (^)(NSError *error))fail {
    NSString *param = ([user integerValue] != 0 ? @"id" : @"username");
    NSURL *url = [[self _setupURLWithString:[NSString stringWithFormat:@"users/info?%@=%@", param, user]] retain];
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - userInformationForUser:%@ completion:%@ fail:%@ (url=%@)", self, user, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                FTUser *info = [[FTUser alloc] initWithDictionary:response.response];
                completion(info);
                [info release];
            }
        }
    } fail:fail];
    
    [url release];
}

- (void)userPostsForUser:(NSString *)user completion:(void (^)(NSArray *posts))completion fail:(void (^)(NSError *error))fail {
    [self userPostsForUser:user options:nil completion:completion fail:fail];
}

- (void)userPostsForUser:(NSString *)user options:(NSDictionary *)options completion:(void (^)(NSArray *posts))completion fail:(void (^)(NSError *error))fail {
    NSString *param = ([user integerValue] != 0 ? @"id" : @"username");
    NSMutableString *_url = [[NSMutableString alloc] initWithFormat:@"user/posts?%@=%@", param, user];
    
    if (options) {
        if ([options objectForKey:@"type"]) {
            NSString *type;
            switch ([[options objectForKey:@"type"] unsignedIntegerValue]) {
                case FTPostTypeCode: type = @"code"; break;
                case FTPostTypeLink: type = @"link"; break;
                case FTPostTypeQuestion: type = @"question"; break;
                case FTPostTypeSnap:
                default:
                    type = @"snap"; break;
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
    
    NSURL *url = [[self _setupURLWithString:_url] retain];
    
    
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
                    [_post release];
                }
                completion(_posts);
                [_posts release];
            }
        }
    } fail:fail];
    
    [_url release];
    [url release];
}

- (void)postForID:(NSString *)postID completion:(void (^)(FTPost *post))completion fail:(void (^)(NSError *error))fail {
    NSURL *url = [[self _setupURLWithString:[NSString stringWithFormat:@"posts/show?id=%@"]] retain];
    
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - postForID:%@ completion:%@ fail:%@ (url=%@)", self, postID, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                FTPost *post = [[FTPost alloc] initWithDictionary:response.response];
                completion(post);
                [post release];
            }
        }
    } fail:fail];
    
    [url release];
}

- (void)postForTinyID:(NSString *)postID completion:(void (^)(FTPost *post))completion fail:(void (^)(NSError *error))fail {
    NSURL *url = [[self _setupURLWithString:[NSString stringWithFormat:@"posts/show?tiny_id=%@"]] retain];
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%@) - postForTinyID:%@ completion:%@ fail:%@ (url=%@)", self, postID, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                FTPost *post = [[FTPost alloc] initWithDictionary:response.response];
                completion(post);
                [post release];
            }
        }
    } fail:fail];
    
    [url release];
}

- (void)listPostsForType:(FTPostType)type completion:(void (^)(NSArray *posts, NSUInteger page))completion fail:(void (^)(NSError *error))fail {
    [self listPostsForType:type options:nil completion:completion fail:fail];
}
- (void)listPostsForType:(FTPostType)type options:(NSDictionary *)options completion:(void (^)(NSArray *posts, NSUInteger page))completion fail:(void (^)(NSError *error))fail {
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
            switch ([[options objectForKey:@"sort"] unsignedIntegerValue]) {
                case FTPostSortPopular: sort = @"popular"; break;
                case FTPostSortBest: sort = @"best"; break;
                case FTPostSortRecent:
                default:
                    sort = @"recent"; break;
            }
            [_url appendFormat:@"&sort=%@", sort];
        }
        
        if ([options objectForKey:@"page"]) {
            [_url appendFormat:@"&page=%d", [[options objectForKey:@"page"] unsignedIntegerValue]];
        }
    }
    
    NSURL *url = [[self _setupURLWithString:_url] retain];
    
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
                    [_post release];
                }
                completion(_list, [[response.response objectForKey:@"page"] unsignedIntegerValue]);
                [_list release];
            }
        }
    } fail:fail];
    
    [_url release];
    [url release];
}

- (void)listPosts:(void (^)(NSArray *posts, NSUInteger page))completion fail:(void (^)(NSError *error))fail {
    [self listPostsAfter:0 completion:completion fail:fail];
}

- (void)listPostsAfter:(NSUInteger)after completion:(void (^)(NSArray *posts, NSUInteger page))completion fail:(void (^)(NSError *error))fail {
    NSMutableString *_url = [[NSMutableString alloc] initWithString:@"posts/all"];
    if (after != 0) {
        [_url appendFormat:@"&after=%d", after];
    }
    
    NSURL *url = [[self _setupURLWithString:_url] retain];
    
#if FT_API_LOG
    NSLog(@"ForrstAPI (%p) - listPostsAfter:%d completion:%@ fail:%@ (url=%@)", self, after, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *__strong response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                NSMutableArray *_list = [[NSMutableArray alloc] init];
                for (NSDictionary *post in [response.response objectForKey:@"posts"]) {
                    FTPost *_post = [[FTPost alloc] initWithDictionary:post];
                    [_list addObject:_post];
                    [_post release];
                }
                completion(_list, [[response.response objectForKey:@"page"] unsignedIntegerValue]);
                [_list release];
            }
        }
    } fail:fail];
    
    [url release];
    [_url release];
}

- (void)commentsForPostId:(NSString *)postID completion:(void (^)(NSArray *comments, NSUInteger count))completion fail:(void (^)(NSError *error))fail {
    NSURL *url = [[self _setupURLWithString:[NSString stringWithFormat:@"post/comments?id=%@"]] retain];
    
#if FT_API_LOG 
    NSLog(@"ForrstAPI (%p) - commentsForPostId:%@ completion:%@ fail:%@ (url=%@)", self, postID, completion, fail, url);
#endif
    
    [FTRequest request:url type:FTRequestTypeGet completion:^(FTResponse *response) {
        if (response.status == FTStatusOk) {
            if (completion) {
                NSMutableArray *_list = [[NSMutableArray alloc] init];
                for (NSDictionary *post in [response.response objectForKey:@"posts"]) {
                    FTPost *_post = [[FTPost alloc] initWithDictionary:post];
                    [_list addObject:_post];
                    [_post release];
                }
                completion(_list, [[response.response objectForKey:@"count"] unsignedIntegerValue]);
                [_list release];
            }
        }
    } fail:fail];
    
    [url release];
}
- (void)commentsForPostTinyId:(NSString *)postID completion:(void (^)(NSArray *comments, NSUInteger count))completion fail:(void (^)(NSError *error))fail {
    NSURL *url = [[self _setupURLWithString:[NSString stringWithFormat:@"post/comments?tiny_id=%@"]] retain];
    
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
                    [_comment release];
                }
                completion(_list, [[response.response objectForKey:@"count"] unsignedIntegerValue]);
                [_list release];
            }
        }
    } fail:fail];
    
    [url release];
}

@end
