//
//  PostDetailsViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/20/22.
//

#import "PostDetailsViewController.h"
#import "AnsweringViewController.h"
#import "CommentCell.h"
#import "Comment.h"

@interface PostDetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.titleLabel.text = self.postInfo.titleContent;
    // TODO: set profile image: self.profileImage.image = ...
    self.nameLabel.text = self.postInfo.user_name;
    self.dateLabel.text = self.postInfo.post_date_detailed;
    self.descriptionLabel.text = self.postInfo.textContent;
    
    NSLog(@"Posts in cache from details: %@", [self.apiManagerFromFeed.postCache objectForKey:@"posts"]);
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"answerSegue"]) {
        
        Post *dataToPass = self.postInfo;
        
        // Get reference to destination controller
        AnsweringViewController *answeringVC = (AnsweringViewController *)(((UINavigationController *)[segue destinationViewController]).topViewController);
        
        // Pass the local dictionary to the view controller property
        answeringVC.postToAnswerInfo = dataToPass;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    <#code#>
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    <#code#>
}

@end
