//
//  AnsweringViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/20/22.
//

#import "AnsweringViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "PostDetailsViewController.h"
#import "HTPressableButton.h"
#import "UIColor+HTColor.h"

@interface AnsweringViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *answerPlaceholder;

@property (strong, nonatomic) HTPressableButton *answerButton;

@end

@implementation AnsweringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sharedManager = [APIManager sharedManager];
    
    self.titleLabel.text = self.postToAnswerInfo.titleContent;
    self.answeringToLabel.text = [NSString stringWithFormat:@"Answering %@'s question:", self.postToAnswerInfo.user_name];
    self.descriptionLabel.text = self.postToAnswerInfo.textContent;
    
    self.answerText.delegate = self;
    self.answerText.layer.borderWidth = 1.0;
    self.answerText.layer.borderColor = [[UIColor ht_leadColor] CGColor];
    self.answerText.layer.cornerRadius = 5;
    self.answerText.clipsToBounds = YES;
  
    self.answerButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.answerButton = [[HTPressableButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 175, 500, 350, 40) buttonStyle:HTPressableButtonStyleRounded];
        self.answerButton.buttonColor = [UIColor ht_wetAsphaltColor];
        self.answerButton.shadowColor = [UIColor ht_midnightBlueColor];
        [self.answerButton setTitle:@"Post" forState:UIControlStateNormal];
    [self.answerButton addTarget:self action:@selector(didTapRespond:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.answerButton];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == self.answerText) {
        [self.answerPlaceholder setHidden:YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == self.answerText &&
        [self.answerText.text isEqualToString:@""]) {
        [self.answerPlaceholder setHidden:NO];
    }
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTapRespond:(id)sender {
    [self composeAnswer];
}


- (void)composeAnswer {
    [self.sharedManager composeAnswerWithCompletion:self.answerText.text postToAnswer:self.postToAnswerInfo.post_id completion:^(NSDictionary * _Nonnull post, NSError * _Nonnull error) {
        if (!error) {
            NSLog(@"Success!");
            [self.sharedManager getPostDictFromIDWithCompletion:post[@"id"] completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
                if (!error) {
                    Post *post = [[Post alloc] initWithDictionary:result];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self.delegate didComment:post];
                } else {
                    NSLog(@"Error posting answer: %@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Error posting to feed: %@", error.localizedDescription);
        }
    }];
}

@end
