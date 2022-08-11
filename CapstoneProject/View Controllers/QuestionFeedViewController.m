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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFetchPosts:)
                                                 name:@"DidFetchNotification"
                                               object:nil];
    
    // Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void) didFetchPosts:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.

    if ([[notification name] isEqualToString:@"DidFetchNotification"]) {
        self.postArray = self.sharedManager.postArray;
        self.isMoreDataLoading = NO;
        [self.tableView reloadData];
        [self stopLoadingView];
        [self.refreshControl endRefreshing];
    }
}

- (IBAction)didTapLogout:(id)sender {
    FBSDKLoginManager *logoutManager = [[FBSDKLoginManager alloc] init];
    [logoutManager logOut];
    
    NSLog(@"%@", [FBSDKAccessToken currentAccessToken]);
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FBLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"FBLoginViewController"];
    self.view.window.rootViewController = loginViewController; // substitute, less elegant
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
            [self.sharedManager fetchMorePosts];
        }
    }
}

- (void)didPost:(nonnull Post *)post {
    [self.sharedManager fetchPosts:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    self.loading = [[Activity alloc] initWithStyle:ActivityStyleAmethyst];
    self.loading.frame = CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height/2 - 50, 100, 100);
    self.loading.ringSize = 100;
    self.loading.ringThickness = 3;
    [self.view addSubview:self.loading];
    [self.loading startAnimating];
    
    [self.sharedManager fetchPosts:YES];
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
