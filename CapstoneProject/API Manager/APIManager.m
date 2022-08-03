//
//  APIManager.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/27/22.
//

#import "APIManager.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"

@implementation APIManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.postCache = [[NSCache alloc] init];
    }
    return self;
}


- (void)getPostDictFromIDWithCompletion:(NSString *)post_id completion:(void(^)(NSDictionary *post, NSError *error))completion {
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/%@", post_id]
                                  parameters:@{ @"fields": @"from,created_time,message"}
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            completion(result, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
