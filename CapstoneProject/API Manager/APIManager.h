//
//  APIManager.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/27/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

@property (class, strong, readonly) APIManager *sharedManager;

@property (nonatomic, copy, nullable) NSString *myString;

@property (nonatomic, strong) NSCache *postCache;

- (void)getPostDictFromIDWithCompletion:(NSString *)post_id completion:(void(^)(NSDictionary *post, NSError *error))completion;

- (void)getNextSetOfPostsWithCompletion:(NSString *)until startDate:(NSString *)since completion:(void(^)(NSMutableArray *posts, NSString *lastDate, NSError *error))completion;

- (NSMutableDictionary *)getWordMappingFromText;

- (void)createNewWordMappingForCurrentUser:(NSMutableDictionary *)dict;

- (void)updateSearchedWordFrequencies:(NSString *)text;

- (void)getSearchedWordFrequenciesWithCompletion:(void(^)(NSMutableDictionary *wordCounts, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
