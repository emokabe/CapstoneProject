//
//  APIManager.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/27/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

@property (nonatomic, strong) NSCache *postCache;

- (void)getNextSetOfPostsWithCompletion:(NSString *)until startDate:(NSString *)since completion:(void(^)(NSMutableArray *posts, NSString *lastDate, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
