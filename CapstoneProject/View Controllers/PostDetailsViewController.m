//
//  PostDetailsViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/20/22.
//

#import "PostDetailsViewController.h"
#import "AnsweringViewController.h"

@interface PostDetailsViewController ()

@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.postInfo.titleContent;
    // TODO: set profile image: self.profileImage.image = ...
    self.nameLabel.text = self.postInfo.user_name;
    self.dateLabel.text = self.postInfo.post_date_detailed;
    self.descriptionLabel.text = self.postInfo.textContent;
}

- (IBAction)pinchToZoom:(UIPinchGestureRecognizer*)sender {
    if ([sender state] == UIGestureRecognizerStateBegan) {
        NSLog(@"Began");
    }
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
    }
}

@end
