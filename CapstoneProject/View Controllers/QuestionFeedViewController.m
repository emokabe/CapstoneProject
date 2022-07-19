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
#import "Parse/Parse.h"

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
    
    [self getCoursePostsWithCompletion:course_id completion:^(NSArray *posts, NSError *error) {
        if (!error) {
            self.postArray = [Post postsWithArray:posts];
            NSLog(@"postArray in fetchPosts: %@", posts);
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)getCoursePostsWithCompletion:(NSString *)course_id completion:(void(^)(NSArray *posts, NSError *error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *allPosts = [[NSMutableArray alloc] init];
        [self getPostMappingsFromCourseWithCompletion:course_id completion:^(NSArray *postMappingsFromCourse, NSError *error) {
            if (!error) {
                for (NSDictionary *dict in postMappingsFromCourse) {
                    NSLog(@"dict: %@", dict);
                    NSLog(@"id of dict: %@", dict[@"post_id"]);
                    
                    [self getPostFromIdWithCompletion:dict[@"post_id"] completion:^(NSDictionary *post, NSError *error) {
                        if (!error) {
                            [allPosts addObject:post];
                            NSLog(@"allPosts so far = %@", allPosts);
                        } else {
                            NSLog(@"Error getting post: %@", error.localizedDescription);
                            completion(nil, error);
                        }
                    }];
                }
                NSLog(@"allPosts final = %@", allPosts);
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"allPosts after dispatch block = %@", allPosts);
            completion(allPosts, nil);
        });
    });
}

- (void)getPostFromIdWithCompletion:(NSString *)post_id completion:(void(^)(NSDictionary *post, NSError *error))completion {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/%@", post_id]
                                  parameters:@{ @"fields": @"from, created_time, message"}
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *post = [NSDictionary dictionaryWithDictionary:result];
            completion(post, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)getPostMappingsFromCourseWithCompletion:(NSString *)course_id completion:(void(^)(NSArray *posts, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"course_objectId" equalTo:course_id];
    // TODO: add limit/load more posts

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (result != nil) {
            NSMutableArray *posts = [NSMutableArray arrayWithArray:result];
            NSLog(@"Selected Posts: %@", posts);
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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"composeSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
    }
}

@end
