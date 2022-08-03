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

- (void)getPostDictFromIDWithCompletion:(NSString *)post_id completion:(void(^)(NSDictionary *post, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
