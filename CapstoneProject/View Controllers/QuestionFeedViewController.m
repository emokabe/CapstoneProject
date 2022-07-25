//
//  QuestionFeedViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/8/22.
//

#import "QuestionFeedViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "FBLoginViewController.h"
#import "PostCell.h"
#import "Post.h"
#import "ComposeViewController.h"
#import "SelectCourseViewController.h"
#import "Parse/Parse.h"
#import "PostDetailsViewController.h"

@interface QuestionFeedViewController () <ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation QuestionFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self fetchPosts];
    
    // Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}


- (IBAction)didTapLogout:(id)sender {
    FBSDKLoginManager *logoutManager = [[FBSDKLoginManager alloc] init];
    [logoutManager logOut];
    
    NSLog(@"%@", [FBSDKAccessToken currentAccessToken]);
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FBLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"FBLoginViewController"];
    self.view.window.rootViewController = loginViewController; // substitute, less elegant
}

- (void)fetchPosts {
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    NSString *course_id = [saved stringForKey:@"currentCourse"];
    NSLog(@"course_id = %@", course_id);
    
    /*
    [self getAllPostsWithCompletion:^(NSMutableArray *posts, NSError *error) {
        if (!error) {
            NSMutableArray *postsToBeQueried = [NSMutableArray array];
            for (Post *post in posts) {
                if ([post.courses isEqualToString:course_id]) {
                    [postsToBeQueried addObject:post];
                }
            }
            self.postArray = postsToBeQueried;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
     */
    
    /*
    [self getNextSetOfPostsWithCompletion:nil startDate:nil completion:^(NSMutableArray *posts, NSError *error) {
        if (!error) {
            NSMutableArray *postsToBeQueried = [NSMutableArray array];
            for (Post *post in posts) {
                if ([post.courses isEqualToString:course_id]) {
                    // add post to cache
                    [postsToBeQueried addObject:post];
                }
            }
            
            if ([postsToBeQueried count] < 2) {
                
            }
            
            self.postArray = postsToBeQueried;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
     */
    [self fetchPostsRec:course_id];
}

- (void)fetchPostsRec:(NSString *)course_id {
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(receiveTestNotification:)
            name:@"TestNotification"
            object:nil];
    
    [self getNextSetOfPostsWithCompletion:nil startDate:nil completion:^(NSMutableArray *posts, NSError *error) {
        if (!error) {
            for (Post *post in posts) {
                if ([post.courses isEqualToString:course_id]) {
                    // add post to cache
                    [self.postArray addObject:post];
                }
            }
            
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        //[self.refreshControl endRefreshing];
        [[NSNotificationCenter defaultCenter]
                postNotificationName:@"TestNotification"
                object:self];
    }];

}

- (void) receiveTestNotification:(NSNotification *) notification {
    if ([self.postArray count] < 2) {
        NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
        NSString *course_id = [saved stringForKey:@"currentCourse"];
        [self fetchPostsRec:course_id];
    } else {
        [self.tableView reloadData];
    }
}

- (void)getNextSetOfPostsWithCompletion:(nullable NSString *)until startDate:(NSString *)since completion:(void(^)(NSMutableArray *posts, NSError *error))completion {
    
    NSString *untilDateStr = until;
    NSString *sinceDateStr = since;
    
    if (untilDateStr == nil) {   // set 'until' to end of today
        NSDate *endOfToday = [NSDate dateWithTimeIntervalSinceNow:86400]; // tomorrow @ 0:00am
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ssZ"];
        
        untilDateStr = [dateFormat stringFromDate:endOfToday];
    }
    
    if (sinceDateStr == nil) {   // set 'since' to two weeks before until
        NSInteger daysinInterval = 2;  // number of days into the past to get posts up to
        NSTimeInterval twoWeekInterval = (NSTimeInterval)(daysinInterval * -86400);
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ssZ"];
        
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
            completion(posts, nil);
        } else {
            completion(nil, error);
        }
    }];
}

/*
- (void)getNextSetOfPostsWithCompletion:(NSInteger)afterNthInterval completion:(void(^)(NSMutableArray *posts, NSError *error))completion {

    NSDate *now = [NSDate date];
    NSDate *tomorrow = [NSDate dateWithTimeInterval:86400 sinceDate:now];
    
    NSInteger daysinInterval = 7; // number of days into the past to get posts up to
    NSTimeInterval startInterval = (NSTimeInterval)((afterNthInterval + 1) * daysinInterval * -86400);
    NSTimeInterval endInterval = (NSTimeInterval)(afterNthInterval * daysinInterval * -86400);
    
    NSDate *start = [NSDate dateWithTimeInterval:startInterval sinceDate:tomorrow];
    NSDate *end = [NSDate dateWithTimeInterval:endInterval sinceDate:tomorrow];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ssZ"];
    
    NSString *startDateStr = [dateFormat stringFromDate:start];
    NSString *endDateStr = [dateFormat stringFromDate:end];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/425184976239857/feed"
                                  parameters:@{ @"fields": @"from,created_time,message",@"until": endDateStr,@"since": startDateStr}
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray *posts = [Post postsWithArray:result[@"data"]];
            completion(posts, nil);
        } else {
            completion(nil, error);
        }
    }];
}
*/

- (void)getAllPostsWithCompletion:(void(^)(NSMutableArray *posts, NSError *error))completion {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/425184976239857/feed"
                                  parameters:@{ @"fields": @"from, created_time, message"}
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray *posts = [Post postsWithArray:result[@"data"]];
            completion(posts, nil);
        } else {
            completion(nil, error);
        }
    }];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    
    [cell setPost:self.postArray[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.postArray.count;
}

- (void)didPost:(nonnull Post *)post {
    [self fetchPosts];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    //NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    //NSString *course_id = [saved stringForKey:@"currentCourse"];
    
    [self fetchPosts];
    [self.tableView reloadData];
    //NSLog(@"Current course id: %@", course_id);
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"composeSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"detailsSegue"]) {
        // 1 Get indexpath
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        // 2 Get movie dictionary
        Post *dataToPass = self.postArray[indexPath.row];
        
        // 3 Get reference to destination controller
        PostDetailsViewController *detailsVC = [segue destinationViewController];
        
        // 4 Pass the local dictionary to the view controller property
        detailsVC.postInfo = dataToPass;
    }
}

@end
