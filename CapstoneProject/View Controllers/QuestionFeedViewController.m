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
#import "Activity/Activity.h"

@interface QuestionFeedViewController () <ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) Activity *loading;
@property (weak, nonatomic) IBOutlet UIView *topBackground;
@property (weak, nonatomic) IBOutlet UIView *bottomBackground;


@end

@implementation QuestionFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.postArray = [[NSMutableArray alloc] init];
    self.postsToBeCached = [[NSMutableArray alloc] init];
    self.sharedManager = [APIManager sharedManager];
    self.isMoreDataLoading = NO;
    
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    NSString *course_id = [saved stringForKey:@"currentCourseAbbr"];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Home", course_id];
    
    // Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts:) forControlEvents:UIControlEventValueChanged];
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

- (void)fetchPosts:(BOOL)isFirst{
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    NSString *course_id = [saved stringForKey:@"currentCourse"];
    NSLog(@"course_id = %@", course_id);
    
    if (isFirst) {
        [self.postArray removeAllObjects];
        [self.postsToBeCached removeAllObjects];
    }
    
    [self fetchPostsRec:course_id endDate:nil startDate:nil numAdded:0 firstFetch:isFirst];
}

- (void)fetchPostsRec:(NSString *)course_id endDate:(NSString *)until startDate:(NSString *)since numAdded:(NSInteger)count firstFetch:(BOOL)isFirst {
    __block NSInteger numPosts = 0;
    [self.sharedManager getNextSetOfPostsWithCompletion:until startDate:since completion:^(NSMutableArray *posts, NSString *lastDate, NSError *error) {
        if (!error) {
            if ([posts count] == 0) {   // no more posts left in Facebook Group: load posts to tableView
                if (isFirst) {
                    [self.sharedManager.postCache setObject:self.postsToBeCached forKey:@"posts"];
                }
                self.isMoreDataLoading = NO;
                [self.tableView reloadData];
                [self stopLoadingView];
                [self.refreshControl endRefreshing];
                return;
            }
            
            for (Post *post in posts) {   // filter posts by current course
                [self.postsToBeCached addObject:post];
                if ([post.parent_post_id isEqualToString:@""] && [post.courses isEqualToString:course_id]) {
                    [self.postArray addObject:post];
                    numPosts++;
                }
            }

            if (numPosts < 10) {   // not enough posts displayed
                NSLog(@"count = %lu", (unsigned long)[self.postArray count]);
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ssZ"];
                NSLog(@"Date = %@", [dateFormat stringFromDate:((Post *)[self.postArray lastObject]).post_date]);
                [self fetchPostsRec:course_id endDate:lastDate startDate:nil numAdded:(count + numPosts) firstFetch:isFirst];
            } else {   // enough posts: load posts to tableView
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf) {
                        if (isFirst) {
                            [self.sharedManager.postCache setObject:self.postsToBeCached forKey:@"posts"];
                        }
                        self.isMoreDataLoading = NO;
                        [self.tableView reloadData];
                        [self stopLoadingView];
                        [self.refreshControl endRefreshing];
                    }
                });
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
            // TODO: get posts from cache instead
        }
    }];
}

- (void)stopLoadingView {
    [self.loading stopAnimating];
    [self.loading setHidden:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    
    [cell setPost:self.postArray[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.postArray.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!self.isMoreDataLoading){
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = true;
            NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
            NSString *course_id = [saved stringForKey:@"currentCourse"];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ssZ"];
            NSString *dateStr = [dateFormat stringFromDate:((Post *)[self.postArray lastObject]).post_date];
            [self fetchPostsRec:course_id endDate:dateStr startDate:nil numAdded:0 firstFetch:NO];
        }
    }
}

- (void)didPost:(nonnull Post *)post {
    [self fetchPosts:YES];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.loading = [[Activity alloc] initWithStyle:ActivityStyleAmethyst];
    self.loading.frame = CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height/2 - 50, 100, 100);
    self.loading.ringSize = 100;
    self.loading.ringThickness = 3;
    [self.view addSubview:self.loading];
    [self.loading startAnimating];
    
    [self fetchPosts:YES];
    [self.tableView reloadData];
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
        
        // 2 Get post and API manager to pass
        Post *postToPass = self.postArray[indexPath.row];
        APIManager *apiManagerToPass = self.sharedManager;
        
        // 3 Get reference to destination controller
        PostDetailsViewController *detailsVC = [segue destinationViewController];
        
        // 4 Pass the local dictionary to the view controller property
        detailsVC.postInfo = postToPass;
        detailsVC.sharedManager = apiManagerToPass;
    }
}

@end
