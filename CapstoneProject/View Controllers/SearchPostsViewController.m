//
//  SearchPostsViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/29/22.
//

#import "SearchPostsViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "Parse/Parse.h"
#import "SearchPostCell.h"

@interface SearchPostsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    self.filteredPostArray = [[NSMutableArray alloc] init];
    [self fetchPostsViewed];
}

- (void)fetchPostsViewed {
    [self getPostsViewedWithCompletion:^(NSArray *result, NSError *error) {
        if ([result count] != 0) {
            self.filteredPostArray = [NSMutableArray arrayWithArray:result];
            [self.tableView reloadData];
        } else if (!error) {
            // no courses viewed
            NSLog(@"No courses viewed yet!");
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)getPostsViewedWithCompletion:(void(^)(NSArray *posts, NSError *error))completion {
    NSString *current_user_id = [FBSDKAccessToken currentAccessToken].userID;
    NSString *userInParse = [NSString stringWithFormat:@"%@%@", @"user", current_user_id];
    
    PFQuery *query = [PFQuery queryWithClassName:userInParse];
    query.limit = 20;

    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            NSLog(@"Posts viewed: %@", posts);
            completion(posts, nil);
        } else {
            NSLog(@"%@", error.localizedDescription);
            completion(nil, error);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredPostArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchPostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchPostCell"
                                                                 forIndexPath:indexPath];
    [cell setSearchPostCell:self.filteredPostArray[indexPath.row]];
    
    return cell;
}

@end
