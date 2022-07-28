//
//  Comment.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/28/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Comment : NSObject

@property (nonatomic, strong) NSString *user_id; // App-scoped id of user
@property (nonatomic, strong) NSString *comment_id; // Post id of Facebook post (comment in app)
@property (nonatomic, strong) NSString *post_id; // Post id of Facebook post that comment belogs to
@property (nonatomic, strong) NSString *answerText; // Comment body
@property (nonatomic, strong) NSString *user_name; // User's Facebook username
@property (nonatomic, strong) NSDate *post_date; // Date of post as NSDate

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (NSMutableArray *)commentsWithArray:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
