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
    
    [self fetchComments];
    NSLog(@"Posts in cache from details: %@", [self.apiManagerFromFeed.postCache objectForKey:@"posts"]);
}

- (void)fetchComments {
    NSMutableArray *posts = [self.apiManagerFromFeed.postCache objectForKey:@"posts"];
    for (Post *post in posts) {
        if ([post.parent_post_id isEqualToString:self.postInfo.post_id]) {
            [self.commentArray addObject:post];
        }
    }
    [self.tableView reloadData];
}

- (void)didComment:(nonnull Post *)post {
    NSLog(@"Did comment!");
    [self.commentArray insertObject:post atIndex:0];
    [self.tableView reloadData];
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
