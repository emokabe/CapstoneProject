//
//  SearchPostsViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/29/22.
//

#import "SearchPostsViewController.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "Parse/Parse.h"
#import "SearchPostCell.h"
#import "Post.h"
#import "PostDetailsViewController.h"

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
    self.postArray = [[NSMutableArray alloc] init];
    self._apiManager = [[APIManager alloc] init];
    self.filteredPostArray = [[NSMutableArray alloc] init];
    [self fetchPostsViewed];
}

- (void)fetchPostsViewed {
    [self getPostsViewedWithCompletion:^(NSArray *result, NSError *error) {
        if ([result count] != 0) {
            self.postArray = [NSMutableArray arrayWithArray:result];
            self.filteredPostArray = self.postArray;
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

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"message CONTAINS[cd] %@", searchText];
        self.filteredPostArray = [NSMutableArray arrayWithArray:[self.postArray filteredArrayUsingPredicate:predicate]];
        [self.tableView reloadData];
    }
    else {
        self.filteredPostArray = self.postArray;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.filteredPostArray = self.postArray;
    [self.tableView reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *post_id = self.filteredPostArray[indexPath.row][@"post_id"] ;
    [self._apiManager getPostDictFromIDWithCompletion:post_id completion:^(NSDictionary * _Nonnull post, NSError * _Nonnull error) {
        if (post) {
            NSLog(@"Hello, World!");
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PostDetailsViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostDetailsViewController"];
            Post *p = [[Post alloc] initWithDictionary:post];
            rootViewController.postInfo = p;
            [self.navigationController pushViewController:rootViewController animated:YES];
            
        } else if (!error) {
            NSLog(@"Error: could not find post with matching id");
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}


@end
