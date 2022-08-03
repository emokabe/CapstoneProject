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

@interface SearchPostsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIContextMenuInteractionDelegate>

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
    self.filter_string = @"DEFAULT";
    
    UIContextMenuInteraction *interaction = [[UIContextMenuInteraction alloc] initWithDelegate:self];
    [self.searchBar addInteraction:interaction];
}

- (void)viewWillAppear:(BOOL)animated {
    [self fetchPostsViewed];
    NSLog(@"Filter: %@", self.filter_string);
}

- (void)fetchPostsViewed {
    [self getPostsViewedWithCompletion:^(NSArray *result, NSError *error) {
        if ([result count] != 0) {
            self.postArray = [NSMutableArray arrayWithArray:result];
            self.filteredPostArray = self.postArray;
            [self.tableView reloadData];
        } else if (!error) {   // no courses viewed
            NSLog(@"No courses viewed yet!");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle: @ "No posts viewed!"
                                                                              message: @"View posts in your feed to search by keyword" preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle: @ "Dismiss"
                                                              style: UIAlertActionStyleDefault handler: ^ (UIAlertAction *action) {}];
            [alert addAction: action];
            [self presentViewController: alert animated: true completion: nil];
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
    NSPredicate *finalPredicate;
    if (searchText.length != 0) {
        if ([self.filter_string isEqualToString:@"DEFAULT"]) {
            NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchText];
            NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"message CONTAINS[cd] %@", searchText];
            finalPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred1, pred2]];
        } else {
            finalPredicate = [NSPredicate predicateWithFormat:self.filter_string, searchText];
        }
        self.filteredPostArray = [NSMutableArray arrayWithArray:[self.postArray filteredArrayUsingPredicate:finalPredicate]];
    }
    else {
        self.filteredPostArray = self.postArray;
    }
    [self.tableView reloadData];
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


- (nullable UIContextMenuConfiguration *)contextMenuInteraction:(nonnull UIContextMenuInteraction *)interaction configurationForMenuAtLocation:(CGPoint)location {
    
    UIContextMenuConfiguration *config = [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
        
        UIAction *defaultFilter = [UIAction actionWithTitle:@"All text (default)" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            self.filter_string = @"DEFAULT";
        }];
        
        UIAction *messageFilter = [UIAction actionWithTitle:@"Message" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            self.filter_string = @"message CONTAINS[cd] %@";
        }];
        
        UIAction *titleFilter = [UIAction actionWithTitle:@"Title" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            self.filter_string = @"title CONTAINS[cd] %@";
        }];
        
        UIAction *usernameFilter = [UIAction actionWithTitle:@"Name" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            self.filter_string = @"user_name CONTAINS[cd] %@";
        }];
        
        UIAction *courseFilter = [UIAction actionWithTitle:@"Course" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            self.filter_string = @"course CONTAINS[cd] %@";
        }];
        
        return [UIMenu menuWithTitle:@"Filter By:" children:@[defaultFilter, messageFilter, titleFilter, usernameFilter, courseFilter]];
    }];
    
    return config;
}

@end
