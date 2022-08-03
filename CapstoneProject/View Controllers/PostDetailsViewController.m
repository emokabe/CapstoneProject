//
//  PostDetailsViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/20/22.
//

#import "PostDetailsViewController.h"
#import "AnsweringViewController.h"
#import "CommentCell.h"
#import "Post.h"
#import "Parse/Parse.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"

@interface PostDetailsViewController () <AnsweringViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.commentArray = [[NSMutableArray alloc] init];
    
    self.titleLabel.text = self.postInfo.titleContent;
    // TODO: set profile image: self.profileImage.image = ...
    self.nameLabel.text = self.postInfo.user_name;
    self.dateLabel.text = self.postInfo.post_date_detailed;
    self.descriptionLabel.text = self.postInfo.textContent;
    
    NSString *current_user_id = [NSString stringWithFormat:@"%@%@", @"user", [FBSDKAccessToken currentAccessToken].userID];
    
    // Check for duplicates
    PFQuery *query = [PFQuery queryWithClassName:current_user_id];
    [query whereKey:@"post_id" equalTo:self.postInfo.post_id];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if ([posts count] != 0) {
            NSLog(@"Already viewed: %@", posts);
            NSString *objectId = ((PFObject *)posts[0]).objectId;
            
            [query getObjectInBackgroundWithId:objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if (object != nil) {
                    NSLog(@"Duplicate object: %@", object);
                    [object incrementKey:@"times_viewed"];
                    [object setValue:[NSDate date] forKey:@"read_date"];
                    [object saveInBackground];
                    [self fetchComments];
                } else if (error == nil) {
                    NSLog(@"Error: No matching object found");
                } else {
                    NSLog(@"Error: %@", error.description);
                }
            }];
        } else {
            [self createNewReadPost:current_user_id];
            [self fetchComments];
        }
    }];
}

- (void)createNewReadPost:(NSString *)current_user_id {
    PFObject *postInParse = [[PFObject alloc] initWithClassName:current_user_id];
    postInParse[@"post_id"] = self.postInfo.post_id;
    postInParse[@"user_id"] = self.postInfo.user_id;
    postInParse[@"user_name"] = self.postInfo.user_name;
    postInParse[@"title"] = self.postInfo.titleContent;
    postInParse[@"message"] = self.postInfo.textContent;
    postInParse[@"course"] = self.postInfo.courses;
    postInParse[@"read_date"] = [NSDate date];
    postInParse[@"times_viewed"] = [NSNumber numberWithInt:1];
    
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    NSString *course_abbr = [saved stringForKey:@"currentCourseAbbr"];
    postInParse[@"course"] = course_abbr;
    
    [postInParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Object saved!");
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}

- (void)fetchComments {
    NSMutableArray *posts = [self.apiManagerFromFeed.postCache objectForKey:@"posts"];
    
    NSDate *lastCachedDate = ((Post *)[posts lastObject]).post_date;
    NSDate *thisPostDate = self.postInfo.post_date;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ssZ"];
    
    NSString *startDate = [dateFormat stringFromDate:thisPostDate];
    NSString *endDate = [dateFormat stringFromDate:lastCachedDate];
    
    if ([thisPostDate compare:lastCachedDate] == NSOrderedAscending) {   // Fetch more posts
        [self.apiManagerFromFeed getNextSetOfPostsWithCompletion:endDate startDate:startDate completion:^(NSMutableArray * _Nonnull result, NSString * _Nonnull lastDate, NSError * _Nonnull error) {
            [posts addObjectsFromArray:result];
            [self addCommentsToArray:posts];
        }];
    } else {
        [self addCommentsToArray:posts];
    }
}

- (void)addCommentsToArray:(NSMutableArray *)posts {
    for (Post *post in posts) {
        if ([post.parent_post_id isEqualToString:self.postInfo.post_id]) {
            [self.commentArray addObject:post];
        }
    }
    [self.tableView reloadData];
}

- (void)didComment:(nonnull Post *)post {
    [self.commentArray insertObject:post atIndex:0];
    [self.tableView reloadData];
}

- (IBAction)pinchToZoom:(UIPinchGestureRecognizer*)sender {
    if ([sender state] == UIGestureRecognizerStateChanged) {
        NSLog(@"%f", [sender scale]);
        CGFloat originalSize = self.descriptionLabel.font.pointSize;
        if (originalSize < 32 && [sender velocity] > 0) {
            [self.descriptionLabel setFont:[UIFont systemFontOfSize:self.descriptionLabel.font.pointSize + 1]];
        } else if (originalSize > 17 && [sender velocity] < 0) {
            [self.descriptionLabel setFont:[UIFont systemFontOfSize:self.descriptionLabel.font.pointSize - 1]];
        }
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"answerSegue"]) {
        
        Post *dataToPass = self.postInfo;
        
        // Get reference to destination controller
        AnsweringViewController *answeringVC = (AnsweringViewController *)(((UINavigationController *)[segue destinationViewController]).topViewController);
        
        // Pass the local dictionary to the view controller property
        answeringVC.postToAnswerInfo = dataToPass;
        
        answeringVC.delegate = self;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    
    [cell setComment:self.commentArray[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentArray.count;
}


@end
