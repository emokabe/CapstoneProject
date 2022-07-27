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
    self.postArray = [[NSMutableArray alloc] init];
    
    // Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        self.firstFetchCall = YES;
    }
    return self;
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
    
    [self.postArray removeAllObjects];
    [self fetchPostsRec:course_id endDate:nil startDate:nil];
}

- (void)fetchPostsRec:(NSString *)course_id endDate:(NSString *)until startDate:(NSString *)since {
    [self getNextSetOfPostsWithCompletion:until startDate:since completion:^(NSMutableArray *posts, NSString *lastDate, NSError *error) {
        if (!error) {
            if ([posts count] == 0) {
                [self.tableView reloadData];
                return;
            }
            for (Post *post in posts) {
                // TODO: add post to cache
                if ([post.courses isEqualToString:course_id]) {
                    [self.postArray addObject:post];
                }
            }
            NSLog(@"after for loop");
            if ([self.postArray count] < 5) {
                NSLog(@"count = %lu", (unsigned long)[self.postArray count]);
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ssZ"];
                NSLog(@"Date = %@", [dateFormat stringFromDate:((Post *)[self.postArray lastObject]).post_date]);
                [self fetchPostsRec:course_id endDate:lastDate startDate:nil];
            } else {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf) {
                        [self.tableView reloadData];
                        self.firstFetchCall = YES;
                    }
                });
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)getNextSetOfPostsWithCompletion:(NSString *)until startDate:(NSString *)since completion:(void(^)(NSMutableArray *posts, NSString *lastDate, NSError *error))completion {
    
    NSString *untilDateStr = until;
    NSString *sinceDateStr = since;
    
    if (untilDateStr == nil) {   // set 'until' to end of today
        NSDate *endOfToday = [NSDate dateWithTimeIntervalSinceNow:86400]; // tomorrow @ 0:00am
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
        untilDateStr = [dateFormat stringFromDate:endOfToday];
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
    if (self.firstFetchCall) {
        [self fetchPosts];
        [self.tableView reloadData];
        self.firstFetchCall = NO;
    }
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
