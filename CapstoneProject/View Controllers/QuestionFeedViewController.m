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
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(leftSwipe:)];
        [leftSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self.tableView addGestureRecognizer:leftSwipeRecognizer];
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
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longPressRecognizer];
    
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
    [self fetchPosts];
    [self.tableView reloadData];
}

- (void)leftSwipe:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSLog(@"left swipe");
}

- (void)longPress:(UILongPressGestureRecognizer*)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                                   message:@"This is an alert."
                                   preferredStyle:UIAlertControllerStyleAlert];
     
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * action) {
        NSLog(@"Cancel");
    }];
    
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * action) {
        NSLog(@"Delete");
        CGPoint tapPoint = [sender locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapPoint];
        
        PostCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self.postArray removeObjectAtIndex:indexPath.row];//or something similar to this based on your data source array structure
        //remove the corresponding object from your data source array before this or else you will get a crash
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
     
    [alert addAction:defaultAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)getPostWithID:(NSString *)post_id completion:(void (^)(Post *, NSError *))completion {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/%@", post_id]
                                  parameters:@{ @"fields": @"from, created_time, message"}
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"%@", result);
            Post *post = [[Post alloc] initWithDictionary:result];
            completion(post, nil);
        } else {
            NSLog(@"Error posting to feed: %@", error.localizedDescription);
            completion(nil, error);
        }
    }];
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
