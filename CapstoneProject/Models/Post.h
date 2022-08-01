//
//  Post.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : NSObject

@property (nonatomic, strong) NSMutableString *titleContent; // Title of post
@property (nonatomic, strong) NSMutableString *textContent; // Text content of post
@property (nonatomic, strong) NSMutableString *courses; // Courses, separated by comma
@property (nonatomic, strong) NSString *user_id; // App-scoped id of user
@property (nonatomic, strong) NSString *post_id; // Post id of Facebook post
@property (nonatomic, strong) NSMutableString *parent_post_id; // Post id of post being commented, if applicable
@property (nonatomic, strong) NSString *user_name; // User's Facebook username
@property (nonatomic, strong) NSString *post_createdAt; // Date of post: MM/DD/YY
@property (nonatomic, strong) NSString *post_date_detailed; // Detailed date of post for details view
@property (nonatomic, strong) NSDate *post_date; // Date of post as NSDate
@property (nonatomic, strong) NSString *profilePic_url; // URL of profile image
@property (nonatomic, strong) NSArray *links; // links within text

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (NSMutableArray *)postsWithArray:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
