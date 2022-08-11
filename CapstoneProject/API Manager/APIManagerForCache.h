//
//  APIManagerForCache.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 8/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManagerForCache : NSObject

@property (class, strong, readonly) APIManagerForCache *sharedCacheManager;

@property (nonatomic, strong) NSCache *sharedCache;

- (void)getProfilePicURLFromIDWithCompletion:(NSString *)user_id completion:(void(^)(NSString *profilePic, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
