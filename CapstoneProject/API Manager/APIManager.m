//
//  APIManager.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/27/22.
//

#import "APIManager.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "Post.h"

@implementation APIManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.postCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)getNextSetOfPostsWithCompletion:(NSString *)until startDate:(NSString *)since completion:(void(^)(NSMutableArray *posts, NSString *lastDate, NSError *error))completion {
    
    NSString *untilDateStr = until;
    NSString *sinceDateStr = since;
    
    if (untilDateStr == nil) {
        untilDateStr = @"now";
    }
    
    if (sinceDateStr == nil) {   // set 'since' to two weeks before until
        double daysinInterval = 2;  // number of days into the past to get posts up to
        NSTimeInterval twoWeekInterval = (NSTimeInterval)(daysinInterval * -86400);
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *startDate = [NSDate dateWithTimeInterval:twoWeekInterval sinceDate:[dateFormat dateFromString:untilDateStr]];
        
        sinceDateStr = [dateFormat stringFromDate:startDate];
    }
    
    NSLog(@"untilDateStr = %@", untilDateStr);
    NSLog(@"sinceDateStr = %@", sinceDateStr);
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/425184976239857/feed"
                                  parameters:@{ @"fields": @"from,created_time,message",@"until": untilDateStr,@"since": sinceDateStr}
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray *posts = [Post postsWithArray:result[@"data"]];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ssZ"];
            
            completion(posts, [dateFormat stringFromDate:((Post *)[posts lastObject]).post_date], nil);
        } else {
            completion(nil, nil, error);
        }
    }];
}

@end
