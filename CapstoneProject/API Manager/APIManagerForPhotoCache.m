//
//  APIManagerForPhotoCache.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 8/11/22.
//

#import "APIManagerForPhotoCache.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"

@implementation APIManagerForPhotoCache

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sharedCache = [[NSCache alloc] init];
    }
    return self;
}

+ (instancetype)sharedCacheManager {
    static id sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)getProfilePicURLFromIDWithCompletion:(NSString *)user_id completion:(void(^)(NSString *profilePic, NSError *error))completion {

    NSString *picUrlInCache = [self.sharedCache objectForKey:user_id];
    if (picUrlInCache == nil) {
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:[NSString stringWithFormat:@"/%@", user_id]
                                      parameters:@{ @"fields": @"picture",}
                                      HTTPMethod:@"GET"];

        [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
            if (!error) {
                NSString *pictureURL = result[@"picture"][@"data"][@"url"];
                [self.sharedCache setObject:pictureURL forKey:user_id];
                completion(pictureURL, nil);
            } else {
                completion(nil, error);
            }
        }];
    } else {
        completion(picUrlInCache, nil);
    }
}

@end
