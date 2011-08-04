//
//  ForrstAPI.h
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FTUser.h"
#import "FTPost.h"
#import "FTComment.h"

typedef void (^FTStatsCompletionBlock)(NSUInteger rateLimit, NSInteger callsMade);
typedef void (^FTUserCompletionBlock)(FTUser *user);
typedef void (^FTPostCompletionBlock)(FTPost *post);
typedef void (^FTPostsCompletionBlock)(NSArray *posts);
typedef void (^FTPostsAndPageCompletionBlock)(NSArray *posts, NSUInteger page);
typedef void (^FTCommentsCompletionBlock)(NSArray *comments, NSUInteger count);

typedef void (^FTErrorReturnBlock)(NSError *error);

@interface ForrstAPI : NSObject {
    NSString *_authToken;
}
@property (nonatomic, copy) NSString *authToken;

+ (ForrstAPI *)engine;

- (void)stats:(void (^)(NSUInteger rateLimit, NSInteger callsMade))completion fail:(void (^)(NSError *error))fail;
- (void)authWithUser:(NSString *)user password:(NSString *)password completion:(void (^)(NSString *token))completion fail:(void (^)(NSError *error))fail;

- (void)userInformationForUser:(NSString *)user completion:(void (^)(FTUser *user))completion fail:(void (^)(NSError *error))fail;
- (void)userPostsForUser:(NSString *)user completion:(void (^)(NSArray *posts))completion fail:(void (^)(NSError *error))fail;
- (void)userPostsForUser:(NSString *)user options:(NSDictionary *)options completion:(void (^)(NSArray *posts))completion fail:(void (^)(NSError *error))fail;

- (void)postForID:(NSString *)postID completion:(void (^)(FTPost *post))completion fail:(void (^)(NSError *error))fail;
- (void)postForTinyID:(NSString *)postID completion:(void (^)(FTPost *post))completion fail:(void (^)(NSError *error))fail;\

- (void)listPostsForType:(FTPostType)type completion:(void (^)(NSArray *posts, NSUInteger page))completion fail:(void (^)(NSError *error))fail;
- (void)listPostsForType:(FTPostType)type options:(NSDictionary *)options completion:(void (^)(NSArray *posts, NSUInteger page))completion fail:(void (^)(NSError *error))fail;
- (void)listPosts:(void (^)(NSArray *posts, NSUInteger page))completion fail:(void (^)(NSError *error))fail;
- (void)listPostsAfter:(NSUInteger)after completion:(void (^)(NSArray *posts, NSUInteger page))completion fail:(void (^)(NSError *error))fail;

- (void)commentsForPostId:(NSString *)postID completion:(void (^)(NSArray *comments, NSUInteger count))completion fail:(void (^)(NSError *error))fail;
- (void)commentsForPostTinyId:(NSString *)postID completion:(void (^)(NSArray *comments, NSUInteger count))completion fail:(void (^)(NSError *error))fail;

@end
