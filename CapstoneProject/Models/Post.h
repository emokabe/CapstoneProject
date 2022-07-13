//
//  Post.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : NSObject

@property (nonatomic, strong) NSString *textContent; // Text content of post
@property (nonatomic, strong) NSString *user_id; // App-scoped id of user
@property (nonatomic, strong) NSString *post_id; // App-scoped id of user
@property (nonatomic, strong) NSString *user_name; // App-scoped id of user
@property (nonatomic, strong) NSString *post_createdAt; // App-scoped id of user
@property (nonatomic, strong) NSDate *post_date; // App-scoped id of user

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (NSMutableArray *)postsWithArray:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
