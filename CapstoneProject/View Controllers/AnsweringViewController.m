//
//  AnsweringViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/20/22.
//

#import "AnsweringViewController.h"

@interface AnsweringViewController ()

@end

@implementation AnsweringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.postToAnswerInfo.titleContent;
    //self.profileImage.image =
    self.answeringToLabel.text = [NSString stringWithFormat:@"Answering %@'s question:", self.postToAnswerInfo.user_name];
    self.descriptionLabel.text = self.postToAnswerInfo.textContent;
    
    self.answerText.layer.borderWidth = 1.0;
    self.answerText.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
