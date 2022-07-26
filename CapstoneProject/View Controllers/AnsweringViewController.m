//
//  AnsweringViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/20/22.
//

#import "AnsweringViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"

@interface AnsweringViewController ()

@end

@implementation AnsweringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.postToAnswerInfo.titleContent;
    self.answeringToLabel.text = [NSString stringWithFormat:@"Answering %@'s question:", self.postToAnswerInfo.user_name];
    self.descriptionLabel.text = self.postToAnswerInfo.textContent;
    
    self.answerText.layer.borderWidth = 1.0;
    self.answerText.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTapRespond:(id)sender {
    [self composeAnswer];
}


- (void)composeAnswer {
    NSString *messageWithDelimiters = [NSString stringWithFormat:@"%@%@%@", self.answerText.text, @"/0\n\n", self.postToAnswerInfo.post_id];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/425184976239857/feed"
                                  parameters:@{ @"message": messageWithDelimiters}
                                  HTTPMethod:@"POST"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Success!");
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"Error posting to feed: %@", error.localizedDescription);
        }
    }];
}


@end
