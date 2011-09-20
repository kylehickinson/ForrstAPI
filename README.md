## ForrstAPI

ForrstAPI is a fully integrated iOS objective-C wrapper for the Forrst API.  All API that Forrst has to offer is integrated into this wrapper, including: 

* User authentication
* User information
* User posts
* Viewing a single post
* Viewing all posts in chronological order (currently, limited by the API to only be sorted by recent)
* Viewing all posts of a given type (snap/code/link/question)
* Viewing comments of a given post
* Notifications & marking them as read

## Dependencies

JSONKit is the only external project required.

## Using ForrstAPI

The project is a cocoa static link library, and upon compile will result in libForrstAPI.a, you can link your project to this and then copy the header files: ForrstAPI.h, FTPost.h, FTComment.h, and FTUser.h to your project as reference.  Alternatively you may also drag all the files in at once.

ForrstAPI only requires you to import ForrstAPI.h and then can be initialized by calling `[ForrstAPI engine]`.  Once you have an instance of ForrstAPI you can now call methods, where each method contains completion and failure blocks.  For example, the function to lookup your rate limit and how many calls you made: 

`- (void)stats:(void (^)(NSUInteger rateLimit, NSInteger callsMade))completion fail:(void (^)(NSError *error))fail`

Can be called as so:

    [[ForrstAPI engine] stats:^(NSUInteger rateLimit, NSInteger callsMade) {
        NSLog(@"%d/%d; calls out of total limit", callsMade, rateLimit);
    } fail:^(NSError *error) {
        NSLog(@"Failed with an error: %@", error);
    }];

## Posts, Comments, Users

Information that ForrstAPI grabs is parsed and returned to the caller as an object.  These objects are **FTPost**, **FTUser** and **FTComment**.  Calling `listPosts:(void (^)(NSArray *posts, NSUInteger page))completion fail:(void (^)(NSError *error))fail;` for example, will give you a NSArray that contains FTPost objects.  Typically a way to deal with this would be:

    NSMutableArray *_posts = [[NSMutableArray alloc] init];
    
    [[ForrstAPI engine] listPosts:^(NSArray *posts, NSUInteger page) {
        // All at once:
        [_posts addObjectsFromArray:posts]
    
        // Or even individually if you want to grab only some data:
        // for (FTPost *post in posts) {
        
        // }
        
        // Update your content.
    } fail:^(NSError *error) {
        NSLog(@"Failed to fetch recent posts with error: %@", error);
    }];

#### Authentication

It is only required that you call `authWithUser:password:completion:fail:` once, and after that the auth token will automatically be appended to all other calls.
The token may also be saved upon the completion block, and then later assigned using the `authToken` property in ForrstAPI.

#### Logging

ForrstAPI comes with logging for all calls and requests.  It can be turned on and off from `FTConstants.h`

#### Cache

ForrstAPI has a built in cache for images (both snaps and avatars), they're automatic upon requesting any snap or avatar from their respective instances.