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
#import "APIManager.h"

@interface SearchPostsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIContextMenuInteractionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;


@end

@implementation SearchPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    self.postArray = [[NSMutableArray alloc] init];
    self.filteredPostArray = [[NSMutableArray alloc] init];
    self.filter_string = @"DEFAULT";
    self.wordCountDict = [[NSMutableDictionary alloc] init];
    self.toSort = [[NSMutableDictionary alloc] init];
    
    UIContextMenuInteraction *interaction = [[UIContextMenuInteraction alloc] initWithDelegate:self];
    [self.searchBar addInteraction:interaction];
    
    [self setSortButtonMenu];
}

- (void)viewWillAppear:(BOOL)animated {
    self.sharedManager = [APIManager sharedManager];
    NSMutableArray *posts = [self.sharedManager.postCache objectForKey:@"posts"];
    NSLog(@"Posts here: %@", posts);
    [self fetchPostsViewed];
    NSLog(@"Filter: %@", self.filter_string);
}

- (void)fetchPostsViewed {
    [self getPostsViewedWithCompletion:^(NSArray *result, NSError *error) {
        if ([result count] != 0) {
            self.postArray = [NSMutableArray arrayWithArray:result];
            self.filteredPostArray = self.postArray;
            [self sortByRecommendation];
            
            NSArray *dictKeys = [self.toSort allKeys];
            NSArray *sortedKeys = [dictKeys sortedArrayUsingComparator:^NSComparisonResult(id dict1, id dict2) {
                NSString *first = [self.toSort objectForKey:dict1];
                NSString *second = [self.toSort objectForKey:dict2];
                return [@([second floatValue]) compare:@([first floatValue])];
            }];
            self.filteredPostArray = [NSMutableArray arrayWithArray:sortedKeys];
            [self.tableView reloadData];
            //[self sortBy:@"read_date"];   [self.tableView reloadData] called here
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
    [query orderByDescending:@"read_date"];
    query.limit = 10;

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

- (void)createNewReadPost:(NSMutableDictionary *)dict {
    PFObject *searchedPost = [[PFObject alloc] initWithClassName:@"SearchedPosts"];
    
    //NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    //NSString *course_abbr = [saved stringForKey:@"currentCourseAbbr"];
    searchedPost[@"user_id"] = [FBSDKAccessToken currentAccessToken].userID;
    searchedPost[@"word_counts"] = dict;
    
    [searchedPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Object saved!");
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}

- (float)getWordMatchScore:(NSDictionary *)dict1 firstCount:(float)count1 secondDictionary:(NSDictionary *)dict2 secondCount:(float)count2 {
    float score = 0;
    for (NSString* word in dict2) {
        if ([dict1 objectForKey:word]) {   // found matching word in first dictionary
            float pointVal = ([dict1[word] floatValue]/count1) * ([dict2[word] floatValue]/count2);  // P(word | dict1) * P(word | dict2)
            score += pointVal;
        }
    }
    NSLog(@"Score = %f", score);
    return score;
}

// Instead of sortBy in fetchPostsViewed
- (void)sortByRecommendation {
    //NSMutableDictionary *toSort = [[NSMutableDictionary alloc] init];
    //NSInteger finalCount = [self.filteredPostArray count];
    for (PFObject* post in self.filteredPostArray) {
        NSString *allText = [NSString stringWithFormat:@"%@%@%@",
                             post[@"title"], @" ",
                             post[@"message"]];
        NSArray *viewedPostWords = [self.sharedManager getWordMappingFromText:allText];
        NSDictionary *viewedWordMappings = viewedPostWords[0];
        float viewedCount = [viewedPostWords[1] floatValue];
        
        [self.sharedManager getSearchDataWithCompletion:^(PFObject * _Nonnull data, NSError * _Nonnull error) {
            if (!error) {
                NSDictionary *searchedWordMappings = data[@"word_counts"];
                float searchedCount = [data[@"total_wordcount"] floatValue];
                
                float scoreForPost = [self getWordMatchScore:viewedWordMappings firstCount:viewedCount secondDictionary:searchedWordMappings secondCount:searchedCount];
                
                [self.toSort setValue:post forKey:[NSString stringWithFormat:@"%f", scoreForPost]];

            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
}


- (void)sortBy:(NSString *)field {
    self.filteredPostArray = [NSMutableArray arrayWithArray:[self.filteredPostArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2[field] compare:obj1[field]];
    }]];
    [self.tableView reloadData];
}

- (void)setSortButtonMenu {
    [self.sortButton setShowsMenuAsPrimaryAction:YES];
    UIAction *readDateSort = [UIAction actionWithTitle:@"Read date (default)" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self sortBy:@"read_date"];
    }];
    UIAction *postDateSort = [UIAction actionWithTitle:@"Post Date" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self sortBy:@"createdAt"];
    }];
    UIAction *timesViewedSort = [UIAction actionWithTitle:@"Times You Viewed" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self sortBy:@"times_viewed"];
    }];
    UIAction *customizedSort = [UIAction actionWithTitle:@"Customized" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        // TODO: implement customized sorting algorithm
    }];
    self.sortButton.menu = [UIMenu menuWithTitle:@"Sort by: " children:@[readDateSort, postDateSort, timesViewedSort, customizedSort]];
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
    NSString *allText = [NSString stringWithFormat:@"%@%@%@",
                         self.filteredPostArray[indexPath.row][@"title"], @" ",
                         self.filteredPostArray[indexPath.row][@"message"]];
    [self.sharedManager updateSearchedWordFrequencies:allText];
    [self.sharedManager getPostDictFromIDWithCompletion:post_id completion:^(NSDictionary * _Nonnull post, NSError * _Nonnull error) {
        if (post) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PostDetailsViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostDetailsViewController"];
            Post *p = [[Post alloc] initWithDictionary:post];
            rootViewController.postInfo = p;
            rootViewController.sharedManager = self.sharedManager;
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
