//
//  FTNotification.h
//  Leef
//
//  Created by Kyle Hickinson on 11-09-08.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Response Snippet -> When Grouped
 ------------------------
 
 {
 "resp":{
    "items":{
        "like":{
             "7711438e4370b4e705a792532a1c63663hwcQn21pNYV":{
             "id":"7711438e4370b4e705a792532a1c63663hwcQn21pNYV", 
             "timestamp":1315511539, 
             "behavior":"like",
             "for_user_id":21, 
             "object_type":"Post",
                "object_id":79097,
                "data":{
                    "actor":"kyle",
                    "actor_url":"\/people\/kyle",
                    "object_url":"\/posts\/Announcing_Attachments-9Vc",
                    "post_type":"question",
                    "post_title":"Announcing Attachments.",
                    "photo":"https:\/\/forrst-development.s3.amazonaws.com\/users\/photos\/1\/thumb.png?1302056245"
                }
            }
        }
    },
    "view_url_format":"https:\/\/forrst.com\/feed\/view\/:id"
 },
 ...
 */

@interface FTNotification : NSObject
@property (readonly) NSInteger notificationID;   // Self-explainatory
@property (readonly) NSString *behavior;         // Action: like, new_comment, new_follow, etc.
@property (readonly) NSDate *timestamp;          // Timestamp converted into an NSDate
@property (readonly) NSInteger userID;           // The logged-in user id
@property (readonly) NSString *objectType;       // Type of content being affected: Comment, User, Post
@property (readonly) NSInteger objectID;         // The ID of that content: Could be a user_id who followed you, post_id of post liked, or comment_id for the comment
@property (readonly) NSString *actor;            // User (username) who caused notification
@property (readonly) NSURL *actorURL;            // URL for user.
@property (readonly) NSURL *objectURL;           // URL for the object, same as actorURL on a follow notification.
@property (readonly) NSString *postType;         // Typical snap, link, question or code type.
@property (readonly) NSString *postTitle;        // Title of post.
@property (readonly) NSURL *actorAvatarThumbURL; // URL of a thumbnail of the user

- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
