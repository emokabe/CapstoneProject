//
//  APIManager.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/27/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

@property (class, strong, readonly) APIManager *sharedManager;

@property (nonatomic, strong) NSCache *postCache;

@property (nonatomic, strong) NSMutableArray *postsToBeCached;

@property (nonatomic, strong) NSMutableArray *postArray;

- (void)fetchPosts:(BOOL)isFirst;

- (void)fetchPostsRec:(NSString *)course_id endDate:(nullable NSString *)until startDate:(nullable NSString *)since firstFetch:(BOOL)isFirst;

- (void)fetchMorePosts;

- (void)getPostDictFromIDWithCompletion:(NSString *)post_id completion:(void(^)(NSDictionary *post, NSError *error))completion;

- (void)getPostObjectFromIDWithCompletion:(NSString *)post_id completion:(void (^)(Post *, NSError *))completion;

- (void)getNextSetOfPostsWithCompletion:(NSString *)until startDate:(NSString *)since completion:(void(^)(NSMutableArray *posts, NSString *lastDate, NSError *error))completion;

- (NSArray *)getWordMappingFromText:(NSString *)text;

- (NSDictionary *)getWordProbabilitiesFromText:(NSString *)text;

- (void)createNewWordMappingForCurrentUser:(NSMutableDictionary *)dict incrementBy:(NSNumber *)count;

- (void)updateSearchedWordFrequencies:(NSString *)text;

- (void)getSearchedWordFrequenciesWithCompletion:(void(^)(NSMutableDictionary *wordCounts, NSError *error))completion;

- (void)getSearchDataWithCompletion:(void(^)(PFObject *data, NSError *error))completion;

- (void)composeAnswerWithCompletion:(NSString *)text postToAnswer:(NSString *)post_id completion:(void(^)(NSDictionary *post, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
