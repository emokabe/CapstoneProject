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
        self.postArray = [[NSMutableArray alloc] init];
        self.postsToBeCached = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)sharedManager {
    static id sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)fetchPosts:(BOOL)isFirst {
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    NSString *course_id = [saved stringForKey:@"currentCourse"];
    NSLog(@"course_id = %@", course_id);
    
    if (isFirst) {
        [self.postArray removeAllObjects];
        [self.postsToBeCached removeAllObjects];
    }
    
    [self fetchPostsRec:course_id endDate:nil startDate:nil firstFetch:isFirst];
}

- (void)fetchPostsRec:(NSString *)course_id endDate:(NSString *)until startDate:(NSString *)since firstFetch:(BOOL)isFirst {
    __block NSInteger numPosts = 0;
    [self getNextSetOfPostsWithCompletion:until startDate:since completion:^(NSMutableArray *posts, NSString *lastDate, NSError *error) {
        if (!error) {
            if ([posts count] == 0) {   // no more posts left in Facebook Group: load posts to tableView
                if (isFirst) {
                    [self.postCache setObject:self.postsToBeCached forKey:@"posts"];
                }
                // Notify question feed
                [[NSNotificationCenter defaultCenter]
                        postNotificationName:@"DidFetchNotification"
                        object:self];
                return;
            }
            
            for (Post *post in posts) {   // filter posts by current course
                [self.postsToBeCached addObject:post];
                if ([post.parent_post_id isEqualToString:@""] && [post.courses isEqualToString:course_id]) {
                    [self.postArray addObject:post];
                    numPosts++;
                }
            }

            if (numPosts < 5) {   // not enough posts displayed
                NSLog(@"count = %lu", (unsigned long)[self.postArray count]);
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ssZ"];
                NSLog(@"Date = %@", [dateFormat stringFromDate:((Post *)[self.postArray lastObject]).post_date]);
                [self fetchPostsRec:course_id endDate:lastDate startDate:nil firstFetch:isFirst];
            } else {   // enough posts: load posts to tableView
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf) {
                        if (isFirst) {
                            [self.postCache setObject:self.postsToBeCached forKey:@"posts"];
                        }
                        // Notify question feed
                        [[NSNotificationCenter defaultCenter]
                                postNotificationName:@"DidFetchNotification"
                                object:self];
                        return;
                    }
                });
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)fetchMorePosts {
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    NSString *course_id = [saved stringForKey:@"currentCourse"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ssZ"];
    NSString *dateStr = [dateFormat stringFromDate:((Post *)[self.postArray lastObject]).post_date];
    [self fetchPostsRec:course_id endDate:dateStr startDate:nil firstFetch:NO];
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

- (void)getNextSetOfPostsWithCompletion:(NSString *)until startDate:(NSString *)since completion:(void(^)(NSMutableArray *posts, NSString *lastDate, NSError *error))completion {
    
    NSString *untilDateStr = until;
    NSString *sinceDateStr = since;
    
    if (untilDateStr == nil) {
        untilDateStr = @"now";
    }
    
    if (sinceDateStr == nil) {   // set 'since' to two weeks before until
        double daysinInterval = 7;  // number of days into the past to get posts up to
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

- (NSArray *)getWordMappingFromText:(NSString *)text {
    NSMutableDictionary *wordCountDict = [[NSMutableDictionary alloc] init];
    NSArray *words = [text componentsSeparatedByString:@" "];
    NSInteger count = 0;
    for (NSString* substr in words) {
        NSCharacterSet *toRemove = [NSCharacterSet characterSetWithCharactersInString:@".,?!'$&#"];
        NSString *word = [[substr componentsSeparatedByCharactersInSet:toRemove] componentsJoinedByString:@""];
        
        if (![word isEqualToString:@""]) {
            if ([wordCountDict objectForKey:word]) {
                NSInteger count = (NSInteger)[wordCountDict valueForKey:word] + 1;
                [wordCountDict setObject:[NSNumber numberWithInt:(int)count] forKey:word];
            } else {
                [wordCountDict setObject:@1 forKey:word];
            }
        }
        count++;
    }
    return @[wordCountDict, [NSNumber numberWithInteger:count]];
}

- (NSDictionary *)getWordProbabilitiesFromText:(NSString *)text {
    NSArray *arr = [self getWordMappingFromText:text];
    NSMutableDictionary *wordsMap = arr[0];
    float count = [arr[1] floatValue];
    NSMutableDictionary *toReturn = [[NSMutableDictionary alloc] init];
    
    for (NSString* word in wordsMap) {
        float probability = [wordsMap[word] floatValue] / count;
        [toReturn setObject:[NSNumber numberWithFloat:probability] forKey:word];
    }
    return toReturn;
}

- (void)createNewWordMappingForCurrentUser:(NSMutableDictionary *)dict incrementBy:(NSNumber *)count {
    PFObject *searchedPost = [[PFObject alloc] initWithClassName:@"SearchedPosts"];
    searchedPost[@"user_id"] = [FBSDKAccessToken currentAccessToken].userID;
    searchedPost[@"word_counts"] = dict;
    searchedPost[@"total_wordcount"] = count;
    
    [searchedPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Object saved!");
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}

- (void)updateSearchedWordFrequencies:(NSString *)text {
    NSArray *mapInfo = [self getWordMappingFromText:text];
    NSMutableDictionary *wordCountDict = mapInfo[0];
    NSNumber *total_count = mapInfo[1];
    
    PFQuery *query = [PFQuery queryWithClassName:@"SearchedPosts"];
    [query whereKey:@"user_id" equalTo:[FBSDKAccessToken currentAccessToken].userID];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if ([users count] != 0) {
            NSLog(@"User found!");
            PFObject *userMapping = (PFObject *)users[0];
            
            NSDictionary *originalCounts = userMapping[@"word_counts"];
            for (NSString* key in wordCountDict) {
                if ([originalCounts objectForKey:key]) {
                    NSInteger updatedCount = [originalCounts[key] intValue] + [wordCountDict[key] intValue];
                    [originalCounts setValue:[NSNumber numberWithInteger:updatedCount] forKey:key];
                } else {
                    [originalCounts setValue:@1 forKey:key];
                }
            }
            
            NSLog(@"Original counts: %@", originalCounts);
            [userMapping setValue:originalCounts forKey:@"word_counts"];
            [userMapping incrementKey:@"total_wordcount" byAmount:total_count];
            [userMapping saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Success!");
                } else {
                    NSLog(@"Error: %@", error.localizedDescription);
                }
            }];
        } else if (!error) {
            NSLog(@"New user map!");
            [self createNewWordMappingForCurrentUser:wordCountDict incrementBy:total_count];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)getSearchedWordFrequenciesWithCompletion:(void(^)(NSMutableDictionary *wordCounts, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"SearchedPosts"];
    [query whereKey:@"user_id" equalTo:[FBSDKAccessToken currentAccessToken].userID];
    query.limit = 1;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (result != nil) {
            completion(result[0][@"word_counts"], nil);
        } else if (!error) {
            NSLog(@"No posts searched yet!");
            completion(nil, nil);
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
            completion(nil, error);
        }
    }];
}

- (void)getSearchDataWithCompletion:(void(^)(PFObject *data, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"SearchedPosts"];
    [query whereKey:@"user_id" equalTo:[FBSDKAccessToken currentAccessToken].userID];
    query.limit = 1;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (result != nil) {
            completion(result[0], nil);
        } else if (!error) {
            NSLog(@"No posts searched yet!");
            completion(nil, nil);
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
            completion(nil, error);
        }
    }];
}

- (void)composeAnswerWithCompletion:(NSString *)text postToAnswer:(NSString *)post_id completion:(void(^)(NSDictionary *post, NSError *error))completion {
    NSString *messageWithDelimiters = [NSString stringWithFormat:@"%@%@%@", text, @"/0\n\n", post_id];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/425184976239857/feed"
                                  parameters:@{ @"message": messageWithDelimiters}
                                  HTTPMethod:@"POST"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Success!");
            completion(result, nil);
        } else {
            NSLog(@"Error posting to feed: %@", error.localizedDescription);
            completion(nil, error);
        }
    }];
}

- (void)composeQuestionWithCompletion:(NSString *)title bodyText:(NSString *)body completion:(void(^)(NSDictionary *post, NSError *error))completion {
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    NSString *courseId = [saved stringForKey:@"currentCourse"];
    
    NSString *messageWithDelimiters = [NSString stringWithFormat:@"%@%@%@%@%@", title, @"/0\n\n", body, @"/0\n\n", courseId];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/425184976239857/feed"
                                  parameters:@{ @"message": messageWithDelimiters}
                                  HTTPMethod:@"POST"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            completion(result, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)getPostsViewedWithCompletion:(void(^)(NSArray *posts, NSError *error))completion {
    NSString *current_user_id = [FBSDKAccessToken currentAccessToken].userID;
    NSString *userInParse = [NSString stringWithFormat:@"%@%@", @"user", current_user_id];
    
    PFQuery *query = [PFQuery queryWithClassName:userInParse];
    [query orderByDescending:@"read_date"];
    query.limit = 10;

    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            completion(posts, nil);
        } else {
            NSLog(@"%@", error.localizedDescription);
            completion(nil, error);
        }
    }];
}

- (void)getCoursesWithCompletion:(void(^)(NSArray *courses, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Course"];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (result != nil) {
            NSMutableArray *courses = [NSMutableArray arrayWithArray:result];
            completion(courses, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
