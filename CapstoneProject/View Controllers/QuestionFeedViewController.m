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

-(void)fetchPosts {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/425184976239857/feed"
                                  parameters:@{ @"fields": @"from, created_time, message"}
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"%@", result[@"data"]);
            NSLog(@"%@", [result[@"data"] class]);
            //self.postArray = [Post postsWithArray:result[@"data"]];
            NSMutableArray *allPosts = [Post postsWithArray:result[@"data"]];
            NSInteger numPosts = [allPosts count];
            
            NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
            NSString *course_id = [saved stringForKey:@"currentCourse"];
            [self getPostsFromCourseWithCompletion:course_id completion:^(NSArray *postsFromCourse, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@", error.localizedDescription);
                } else {
                    // for every post in postsFromCourse
                    //     GET post from the post_id field
                    //     (don't need this outside get request in this case)
                    for (NSInteger i = 0; i < numPosts; i++) {
                        //if (allPosts[i][@"id"])
                    }
                }
            }];
            
            [self.tableView reloadData];
        } else {
            NSLog(@"Error posting to feed: %@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
    NSLog(@"%@", [FBSDKAccessToken currentAccessToken]);
}

- (void)getPostsFromCourseWithCompletion:(NSString *)course_id completion:(void(^)(NSArray *posts, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"course_objectId" equalTo:course_id];
    // TODO: add limit/load more posts

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (result != nil) {
            NSMutableArray *posts = [NSMutableArray arrayWithArray:result];
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
